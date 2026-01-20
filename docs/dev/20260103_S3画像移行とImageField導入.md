# S3画像移行とImageField導入

**作成日**: 2026年1月3日
**ステータス**: 設計中
**担当**: 開発チーム

---

## 1. 概要

### 1.1 目的
現在ローカルアセットとして管理されているコース画像をAWS S3に移行し、DjangoのImageFieldを使用して画像を管理する仕組みを構築する。

### 1.2 背景
- 現在、コース画像はFlutterアプリ内の`lib/assets/invi_course_pic/`にローカルファイルとして配置
- アプリの再ビルド・再デプロイなしに画像を変更できない
- DBには`asset_image_path`（CharField）が存在するが、ローカルパスを保存している
- S3を使用することで、画像管理を動的かつ柔軟にしたい

### 1.3 期待される効果
- ✅ アプリの再ビルド不要で画像変更が可能
- ✅ Django Adminから簡単に画像アップロード可能
- ✅ 画像の一元管理（S3バケット上）
- ✅ CDN経由での高速配信が可能（将来的にCloudFront導入時）
- ✅ スケーラブルなストレージ
- ✅ 画像のバージョン管理・バックアップが容易
- ✅ 開発環境で追加した画像がそのまま本番環境でも使用可能

---

## 2. 現状分析

### 2.1 現在の画像管理

#### 2.1.1 Flutterアプリ側
```
lib/assets/invi_course_pic/
├── invi_yoga.png
├── invi_pilates.png
├── invi_music.png
├── invi_dance.png
├── invi_karate.png
├── female_fitness.png
├── male_fitness.png
├── private_yoga.png
└── ... (合計15個程度)
```

**課題**:
- 画像ファイルがアプリに埋め込まれている
- 画像変更にはアプリの再ビルド・再デプロイが必要
- アプリサイズが増加

#### 2.1.2 Djangoモデル

**現在のCourseモデル** ([wellbee/attendances/models.py](wellbee/attendances/models.py)):
```python
class Course(models.Model):
    course_name = models.CharField(verbose_name="course_name", max_length=25, default='Yoga', blank=False, null=False)
    is_private = models.BooleanField(verbose_name='is_private', default=False, null=False, blank=False)
    is_open = models.BooleanField(verbose_name='is_open', default=True, null=False, blank=False)
    asset_image_path = models.CharField(
        verbose_name="asset_image_path",
        max_length=255,
        blank=True,
        null=True,
    )
```

**課題**:
- `asset_image_path`はCharFieldでローカルパスを保存
- 画像のバリデーションがない
- 画像アップロード機能がない

---

## 3. 新設計

### 3.1 アーキテクチャ

```
┌─────────────────────────────────────────────────────────┐
│                  Django Admin                            │
│  スタッフが画像をアップロード                              │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│              Django + django-storages                    │
│  ImageField → 自動的にS3にアップロード                     │
│  DB には S3のURL(またはキー)を保存                         │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│                  AWS S3 Bucket                           │
│  s3-wellbee-images (開発・本番共通)                       │
│  ├── courses/                                           │
│  │   ├── yoga_abc123.jpg                               │
│  │   ├── pilates_def456.jpg                            │
│  │   └── ...                                           │
└───────────────────┬─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│              Flutter App (iOS/Android/Web)               │
│  Image.network(S3のURL) で画像表示                        │
└─────────────────────────────────────────────────────────┘
```

### 3.2 環境構成（重要）

**S3バケット**: 1つのみ（`s3-wellbee-images`）
- 開発環境と本番環境で同じバケットを使用
- 開発環境でアップロードした画像がそのまま本番環境でも使用可能
- コスト削減とシンプルな構成

**フォルダ構造**:
```
s3-wellbee-images/
└── courses/
    ├── yoga_abc123.jpg
    ├── pilates_def456.jpg
    ├── dance_ghi789.jpg
    └── ...
```

### 3.3 変更後のCourseモデル

```python
from django.db import models

class Course(models.Model):
    course_name = models.CharField(
        verbose_name="course_name",
        max_length=25,
        default='Yoga',
        blank=False,
        null=False
    )
    is_private = models.BooleanField(
        verbose_name='is_private',
        default=False,
        null=False,
        blank=False
    )
    is_open = models.BooleanField(
        verbose_name='is_open',
        default=True,
        null=False,
        blank=False
    )
    course_image = models.ImageField(
        verbose_name="course_image",
        upload_to='courses/',  # S3上のパス: courses/ファイル名
        blank=True,
        null=True,
        help_text="コース画像をアップロードしてください"
    )

    # 後方互換性のため一時的に残す（移行後に削除予定）
    # asset_image_path = models.CharField(...)

    def __str__(self):
        return self.course_name

    @property
    def image_url(self):
        """画像のURLを取得（S3のURL）"""
        if self.course_image:
            return self.course_image.url
        return None
```

---

## 4. 実装詳細

### 4.1 AWS S3の設定

#### 4.1.1 S3バケットの作成

**バケット名**: `s3-wellbee-images`

**設定**:
```
リージョン: me-south-1 (Middle East - Bahrain) ※既存のAWS設定と合わせる
パブリックアクセス: ブロックを解除（画像を公開する必要があるため）
バージョニング: 有効化（推奨 - 誤削除からの復元が可能）
暗号化: 有効化（AES-256）
```

**バケットポリシー**（パブリック読み取りを許可）:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::s3-wellbee-images/courses/*"
        }
    ]
}
```

#### 4.1.2 IAMユーザー・ポリシーの作成

**IAMユーザー**: `wellbee-s3-uploader`（新規作成）

**アタッチするポリシー**:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::s3-wellbee-images",
                "arn:aws:s3:::s3-wellbee-images/*"
            ]
        }
    ]
}
```

**アクセスキーの発行**:
- アクセスキーID: `AKIA...`
- シークレットアクセスキー: `...`（`.env`と`.env.prod`に保存）

#### 4.1.3 CORS設定（S3バケット）

Flutterアプリ（Web版）からS3の画像を読み込むために必要:

```json
[
    {
        "AllowedHeaders": [
            "*"
        ],
        "AllowedMethods": [
            "GET",
            "HEAD"
        ],
        "AllowedOrigins": [
            "*"
        ],
        "ExposeHeaders": []
    }
]
```

---

### 4.2 Django側の設定

#### 4.2.1 必要なパッケージのインストール

**requirements.txt**に追加:
```
django-storages==1.14.2
boto3==1.35.49  # 既にインストール済み
Pillow==10.0.0  # ImageField使用時に必要
```

インストールコマンド:
```bash
pip install django-storages Pillow
```

#### 4.2.2 settings.pyの設定

**wellbee/wellbee/settings.py**に追加:

```python
# django-storagesをINSTALLED_APPSに追加
INSTALLED_APPS = [
    # ... 既存のアプリ
    'storages',  # 追加
]

# AWS S3 設定
AWS_ACCESS_KEY_ID = env('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = env('AWS_SECRET_ACCESS_KEY')
AWS_STORAGE_BUCKET_NAME = env('AWS_STORAGE_BUCKET_NAME', default='s3-wellbee-images')
AWS_S3_REGION_NAME = env('AWS_S3_REGION_NAME', default='me-south-1')

# S3のファイルを上書きしない（ファイル名が重複した場合、ランダム文字列を付与）
AWS_S3_FILE_OVERWRITE = False

# クエリパラメータなしのクリーンなURL
AWS_QUERYSTRING_AUTH = False

# デフォルトのストレージバックエンドをS3に設定
DEFAULT_FILE_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'

# メディアファイルのURL（S3のURL）
MEDIA_URL = f'https://{AWS_STORAGE_BUCKET_NAME}.s3.{AWS_S3_REGION_NAME}.amazonaws.com/'
```

#### 4.2.3 環境変数ファイルに追加

**wellbee/.env**（開発環境）に追加:
```bash
# AWS S3
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_STORAGE_BUCKET_NAME=s3-wellbee-images
AWS_S3_REGION_NAME=me-south-1
```

**wellbee/.env.prod**（本番環境）に追加:
```bash
# AWS S3（開発環境と同じ認証情報・バケット）
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_STORAGE_BUCKET_NAME=s3-wellbee-images
AWS_S3_REGION_NAME=me-south-1
```

**重要**:
- `.env`と`.env.prod`は`.gitignore`に含めること
- 開発環境と本番環境で同じS3バケットを使用
- 開発環境でアップロードした画像が本番環境でもそのまま使用可能

---

### 4.3 モデルの変更

#### 4.3.1 マイグレーションファイルの作成

**手順**:

1. **モデルの変更**（`wellbee/attendances/models.py`）:
```python
class Course(models.Model):
    course_name = models.CharField(verbose_name="course_name", max_length=25, default='Yoga', blank=False, null=False)
    is_private = models.BooleanField(verbose_name='is_private', default=False, null=False, blank=False)
    is_open = models.BooleanField(verbose_name='is_open', default=True, null=False, blank=False)

    # 新フィールド: ImageField
    course_image = models.ImageField(
        verbose_name="course_image",
        upload_to='courses/',
        blank=True,
        null=True,
        help_text="コース画像をアップロードしてください"
    )

    # 旧フィールド: 後方互換性のため一時的に残す
    asset_image_path = models.CharField(
        verbose_name="asset_image_path (deprecated)",
        max_length=255,
        blank=True,
        null=True,
    )

    def __str__(self):
        return self.course_name

    @property
    def image_url(self):
        """画像のURLを取得"""
        if self.course_image:
            return self.course_image.url
        # フォールバック: 旧フィールドを使用
        return self.asset_image_path
```

2. **マイグレーションファイルの生成**:
```bash
cd wellbee
python manage.py makemigrations attendances
```

3. **マイグレーションの実行**:
```bash
python manage.py migrate attendances
```

#### 4.3.2 既存データの移行

**オプション1: 手動でDjango Adminからアップロード**
- 各コースのレコードを開き、画像をアップロード

**オプション2: スクリプトで一括移行**（推奨）

**移行スクリプト**（`wellbee/attendances/management/commands/migrate_images_to_s3.py`）:

```python
import os
from django.core.management.base import BaseCommand
from django.core.files import File
from attendances.models import Course

class Command(BaseCommand):
    help = 'ローカルの画像をS3に移行'

    def handle(self, *args, **options):
        # ローカル画像のマッピング（コース名 → ローカルパス）
        image_mapping = {
            'Yoga': 'lib/assets/invi_course_pic/invi_yoga.png',
            'Pilates': 'lib/assets/invi_course_pic/invi_pilates.png',
            'Music': 'lib/assets/invi_course_pic/invi_music.png',
            'Dance': 'lib/assets/invi_course_pic/invi_dance.png',
            'Karate': 'lib/assets/invi_course_pic/invi_karate.png',
            'Family Pilates': 'lib/assets/invi_course_pic/invi_family_pilates.png',
            'Male Fitness': 'lib/assets/invi_course_pic/male_fitness.png',
            'Private Yoga': 'lib/assets/invi_course_pic/private_yoga.png',
            'Private Pilates': 'lib/assets/invi_course_pic/private_pilates.png',
            'Wellbee Gold': 'lib/assets/invi_course_pic/invi_gold.png',
            'Flamenco': 'lib/assets/invi_course_pic/invi_flamenco.png',
            'Toning': 'lib/assets/invi_course_pic/invi_toning.png',
            'Zumba': 'lib/assets/invi_course_pic/invi_zumba.png',
        }

        # Flutterプロジェクトのルートパス
        flutter_root = '/Users/rui/dev/wellbee'

        for course in Course.objects.all():
            if course.course_name in image_mapping:
                local_path = image_mapping[course.course_name]
                abs_path = os.path.join(flutter_root, local_path)

                if os.path.exists(abs_path):
                    with open(abs_path, 'rb') as f:
                        # ファイル名を取得（例: invi_yoga.png）
                        filename = os.path.basename(local_path)

                        # S3にアップロード
                        course.course_image.save(
                            filename,
                            File(f),
                            save=True
                        )
                    self.stdout.write(
                        self.style.SUCCESS(f'✓ {course.course_name}: 画像をS3にアップロードしました')
                    )
                else:
                    self.stdout.write(
                        self.style.WARNING(f'✗ {course.course_name}: ファイルが見つかりません: {abs_path}')
                    )
            else:
                self.stdout.write(
                    self.style.WARNING(f'⚠ {course.course_name}: マッピングが定義されていません')
                )
```

**実行コマンド**:
```bash
python manage.py migrate_images_to_s3
```

**実行後の確認**:
1. AWS S3コンソールで`wellbee-images/courses/`に画像がアップロードされているか確認
2. Django Adminで各コースの`course_image`フィールドに画像が設定���れているか確認

---

### 4.4 Serializer・API側の対応

#### 4.4.1 CourseSerializerの更新

**wellbee/attendances/serializers.py**:

```python
from rest_framework import serializers
from .models import Course

class CourseSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = Course
        fields = ['id', 'course_name', 'is_private', 'is_open', 'image_url', 'course_image']
        # 'asset_image_path'は後方互換性のため残すか、削除してもOK

    def get_image_url(self, obj):
        """画像のURLを返す（S3のURL）"""
        if obj.course_image:
            request = self.context.get('request')
            if request:
                # 完全なURLを返す
                return request.build_absolute_uri(obj.course_image.url)
            return obj.course_image.url
        return None
```

**APIレスポンス例**:
```json
{
    "id": 1,
    "course_name": "Yoga",
    "is_private": false,
    "is_open": true,
    "image_url": "https://s3-wellbee-images.s3.me-south-1.amazonaws.com/courses/invi_yoga_abc123.png",
    "course_image": "courses/invi_yoga_abc123.png"
}
```

---

### 4.5 Flutter側の対応

#### 4.5.1 画像表示ロジックの変更

**変更前**（ローカルアセット）:
```dart
Image.asset(
  'lib/assets/invi_course_pic/invi_yoga.png',
  fit: BoxFit.cover,
)
```

**変更後**（S3からネットワーク画像）:
```dart
Image.network(
  course['image_url'],  // S3のURL
  fit: BoxFit.cover,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  },
  errorBuilder: (context, error, stackTrace) {
    // エラー時はフォールバック画像
    return Image.asset('lib/assets/invi_course_pic/female_fitness.png');
  },
)
```

#### 4.5.2 修正対象ファイル

1. **`lib/ui_parts/display.dart`** - 最優先
   - コース名による多段if文を削除
   - `Image.network(course['image_url'])`に置き換え

2. **`lib/screens/home.dart`**
   - コース画像表示を`Image.network`に変更

3. **`lib/screens/staff/course_add/edit_courses.dart`**
   - 既に`course['asset_image_path']`を使用している箇所を`course['image_url']`に変更

4. **`lib/screens/staff/qr_after/user_home.dart`**
5. **`lib/screens/staff/membership/all_course.dart`**
6. **`lib/screens/staff/course/course.dart`**
7. **`lib/ui_parts/ticket.dart`**

#### 4.5.3 キャッシング（推奨）

ネットワーク画像のキャッシングのため、`cached_network_image`パッケージの導入を推奨:

**pubspec.yaml**に追加:
```yaml
dependencies:
  cached_network_image: ^3.3.0
```

**使用例**:
```dart
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: course['image_url'],
  fit: BoxFit.cover,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Image.asset(
    'lib/assets/invi_course_pic/female_fitness.png',
    fit: BoxFit.cover,
  ),
)
```

**メリット**:
- 一度読み込んだ画像をキャッシュ
- 2回目以降は高速表示
- ネットワーク通信量の削減

---

## 5. 実装手順

### 5.1 フェーズ1: AWS S3のセットアップ（優先度: 高）✅ 完了

- [x] S3バケット作成（`s3-wellbee-images`）
- [x] バケットポリシー設定（パブリック読み取り許可）
- [x] CORS設定
- [x] バージョニング有効化
- [x] IAMユーザー作成（`wellbee-s3-uploader`）
- [x] IAMポリシーアタッチ
- [x] アクセスキー発行
- [x] `.env`ファイルにAWS認証情報追加
- [x] `.env.prod`ファイルにAWS認証情報追加（同じ内容）

### 5.2 フェーズ2: Django側の実装（優先度: 高）

- [ ] `django-storages`, `Pillow`をrequirements.txtに追加
- [ ] パッケージインストール（`pip install django-storages Pillow`）
- [ ] `settings.py`にS3設定追加
- [ ] `INSTALLED_APPS`に`storages`追加
- [ ] Courseモデルに`course_image`フィールド追加
- [ ] マイグレーションファイル生成（`makemigrations`）
- [ ] マイグレーション実行（`migrate`）
- [ ] CourseSerializer更新（`image_url`フィールド追加）

### 5.3 フェーズ3: 既存画像の移行（優先度: 高）

- [ ] `management/commands/`ディレクトリ作成
- [ ] 移行スクリプト作成（`migrate_images_to_s3.py`）
- [ ] ローカル画像のマッピング定義
- [ ] スクリプト実行（画像をS3にアップロード）
- [ ] S3バケットで画像が正しくアップロードされたか確認
- [ ] Django Adminで各コースの`course_image`フィールド確認
- [ ] API経由で`image_url`が正しく返されるか確認

### 5.4 フェーズ4: Flutter側の実装（優先度: 高）

- [ ] `cached_network_image`パッケージ追加（`pubspec.yaml`）
- [ ] パッケージインストール（`flutter pub get`）
- [ ] `lib/ui_parts/display.dart`修正
- [ ] `lib/screens/home.dart`修正
- [ ] `lib/screens/staff/course_add/edit_courses.dart`修正
- [ ] その他の画面を順次修正
- [ ] 動作確認（画像が正しく表示されるか）

### 5.5 フェーズ5: テスト・検証（優先度: 中）

- [ ] 全コースで画像が正しく表示されるか（開発環境）
- [ ] Django Adminから新しい画像をアップロードできるか
- [ ] 画像がS3に正しくアップロードされるか
- [ ] 画像のURLが正しく生成されるか
- [ ] ネットワークエラー時のフォールバック動作確認
- [ ] パフォーマンステスト（画像読み込み速度）
- [ ] 本番環境でも同じ画像が表示されるか確認

### 5.6 フェーズ6: クリーンアップ（優先度: 低）

- [ ] `asset_image_path`フィールドの削除を検討（マイグレーション）
- [ ] Flutterアプリ内のローカル画像ファイル削除を検討
- [ ] `lib/ui_parts/images.dart`の`imageOptions`の扱いを検討

---

## 6. リスクと対策

### 6.1 リスク

| リスク | 影響度 | 発生確率 | 対策 |
|--------|--------|---------|------|
| S3のアクセスキーが漏洩 | 高 | 低 | `.env`を`.gitignore`に追加、IAMポリシーを最小権限に |
| 開発環境で画像を誤削除 | 中 | 中 | S3バージョニング有効化で復元可能に |
| 画像アップロード失敗 | 中 | 中 | Django Adminでエラーメッセージ表示、ログ記録 |
| ネットワーク障害で画像表示不可 | 中 | 中 | Flutter側でerrorBuilderによるフォールバック |
| 既存画像の移行漏れ | 中 | 中 | 移行スクリプトでログ出力、手動確認 |
| AWS料金の増加 | 低 | 低 | S3のコストは非常に安い（月数ドル程度） |

### 6.2 ロールバック計画

- Git ブランチを分けて作業（`feature/s3-image-migration`）
- フェーズごとに動作確認を実施
- 問題があれば`asset_image_path`に戻せるように一時的に残す
- S3バケットのバージョニングを有効化（削除した画像を復元可能）

---

## 7. 環境間でのデータ共有

### 7.1 開発→本番の流れ

```
1. 開発環境でコースを作成
   ↓
2. Django Adminで画像をアップロード
   ↓
3. S3（s3-wellbee-images/courses/）に画像が保存
   ↓
4. DBに画像のパス（courses/yoga_abc123.jpg）が保存
   ↓
5. 本番環境も同じS3バケットを参照
   ↓
6. 本番環境でも同じ画像が表示される
```

### 7.2 メリット

- ✅ 開発環境で追加したコース画像が自動的に本番環境でも使用可能
- ✅ 画像の二重管理が不要
- ✅ シンプルな運用

### 7.3 注意点

- ⚠️ 開発環境で画像を削除すると本番環境でも表示されなくなる
- ⚠️ テスト用の画像と本番用の画像が混在する可能性

**対策**:
- 重要な画像の削除は慎重に行う
- S3のバージョニング機能で誤削除からの復元が可能

---

## 8. コスト試算

### 8.1 AWS S3のコスト

**想定**:
- 画像数: 20個
- 1画像あたりのサイズ: 500KB
- 合計: 10MB

**料金（me-south-1リージョン）**:
- ストレージ: $0.025/GB/月 → 約$0.0003/月（10MBの場合）
- リクエスト: GET: $0.0004/1000リクエスト
- データ転送: 最初の10TBは$0.11/GB

**月間コスト試算**:
- ストレージ: ほぼ無料
- 月間10,000リクエスト: $0.004
- 月間1GB転送: $0.11

**合計**: 約$0.12/月（約15円/月）

---

## 9. 将来の拡張性

### 9.1 CloudFrontの導入

画像配信を高速化するため、CloudFront（CDN）を導入:

```
Flutter App → CloudFront → S3
```

**メリット**:
- 画像読み込みの高速化
- S3へのリクエスト削減（コスト削減）
- エッジロケーションからの配信

### 9.2 画像リサイズ・最適化

Lambda@Edgeを使用して、画像を動的にリサイズ:

```
リクエスト: ?width=300
→ Lambda@Edge → リサイズされた画像を返す
```

### 9.3 画像のバージョン管理

S3のバージョニング機能を活用:
- 誤って削除した画像の復元
- 画像の履歴管理

---

## 10. 成功基準

### 10.1 必須要件

- [ ] すべてのコース画像がS3に保存されている
- [ ] Django Adminから画像アップロードが可能
- [ ] Flutter アプリで画像が正しく表示される（開発環境）
- [ ] Flutter アプリで画像が正しく表示される（本番環境）
- [ ] APIレスポンスに`image_url`が含まれる
- [ ] 画像読み込みエラー時のフォールバックが動作する

### 10.2 品質要件

- [ ] 画像読み込み速度が許容範囲内（3秒以内）
- [ ] ローカルアセットが削除され、アプリサイズが削減される（将来）
- [ ] コードの保守性が向上する
- [ ] 開発環境と本番環境で同じ画像が使用できる

---

## 11. タスクチェックリスト

### AWS側 ✅ 完了
- [x] S3バケット作成（`s3-wellbee-images`）
- [x] バケットポリシー設定
- [x] CORS設定
- [x] バージョニング有効化
- [x] IAMユーザー作成（`wellbee-s3-uploader`）
- [x] アクセスキー発行

### Django側
- [ ] パッケージインストール（django-storages, Pillow）
- [ ] settings.py設定
- [x] .env設定
- [x] .env.prod設定
- [ ] モデル変更
- [ ] マイグレーション
- [ ] Serializer更新
- [ ] 画像移行スクリプト作成・実行

### Flutter側
- [ ] `cached_network_image`導入
- [ ] 各画面の修正
- [ ] 動作確認

### テスト
- [ ] 画像表示確認（開発環境）
- [ ] 画像表示確認（本番環境）
- [ ] アップロード機能確認
- [ ] エラーハンドリング確認
- [ ] パフォーマンステスト

---

## 12. 備考

### 12.1 関連ドキュメント

- AWS S3公式ドキュメント: https://docs.aws.amazon.com/s3/
- django-storages: https://django-storages.readthedocs.io/
- Flutter Image.network: https://api.flutter.dev/flutter/widgets/Image/Image.network.html
- cached_network_image: https://pub.dev/packages/cached_network_image

### 12.2 参考情報

**S3のURL形式**:
- パス形式: `https://s3-wellbee-images.s3.me-south-1.amazonaws.com/courses/yoga.jpg`

**ImageFieldのupload_to**:
- `upload_to='courses/'` → S3上のパス: `courses/ファイル名`
- ファイル名が重複した場合、自動的にランダム文字列が付与される（例: `yoga_abc123.jpg`）

**バージョニング**:
- S3コンソール → バケット → プロパティ → バージョニング → 有効化
- 誤削除した画像を復元可能

---

**最終更新**: 2026年1月3日
