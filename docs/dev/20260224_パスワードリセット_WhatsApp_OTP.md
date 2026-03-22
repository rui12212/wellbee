# パスワードリセット機能（WhatsApp OTP） 仕様書

## 概要

ログイン画面から「Forgot password?」リンクをタップしたユーザーが、WhatsApp経由でOTPを受け取り、パスワードをリセットできる機能を実装する。また、スタッフが管理画面から手動でユーザーのパスワードをリセットできる機能も追加する。

**対象ユーザー**: 一般ユーザーのみ（スタッフはスタッフ側でリセット機能を持つ）

**WhatsApp API**: Twilio Verify API（WhatsApp channel）

**主要使用地域**: イラク（デフォルト国番号: +964）

---

## 現状と変更方針

### 削除する既存実装

`accounts/serializers.py` および `accounts/views.py` に `secret_words` フィールドを参照するパスワードリセット実装が存在するが、以下の問題があるため**完全に削除して作り直す**。

- `secret_words` フィールドがUserモデルにもDBマイグレーションにも存在しない（動作不可）
- `lib/screens/pass_reset.dart` のFlutter実装が全コメントアウト

---

## フロー設計

```
[ログイン画面（main.dart）]
    ↓ "Forgot password?" タップ
[Step 1: 電話番号入力画面]
    ↓ 国番号選択（デフォルト: イラク +964） + 電話番号入力
    ↓ POST /accounts/password-reset/request/
[Django] → Twilio Verify API → WhatsApp OTPメッセージ送信（6桁・10分有効）
    ↓
[Step 2: OTP入力画面]
    ↓ POST /accounts/password-reset/verify-otp/
[Django] → OTP検証（Twilio側） → reset_token（UUID）を返却
    ↓
[Step 3: 新パスワード設定画面]
    ↓ POST /accounts/password-reset/confirm/
[Django] → reset_token検証 → パスワード更新 → 完了
    ↓
[ログイン画面へ戻る]
```

---

## 外部サービス

### Twilio Verify API

OTPの生成・送信・検証を担う。自前でOTPを生成・管理する必要はなく、Twilioに委譲する。

**料金**: $0.05 / 成功した認証1件（+ WhatsAppテンプレート料金 ~$0.003）

**設定（環境変数）**:

```
TWILIO_ACCOUNT_SID=<Twilioダッシュボードから取得>
TWILIO_AUTH_TOKEN=<Twilioダッシュボードから取得>
TWILIO_VERIFY_SERVICE_SID=<Verify Service作成後に取得>
```

**Verifyサービス初期設定**:
1. Twilioコンソール → Verify → Services → 新規作成
2. Channel: WhatsApp を有効化
3. Code length: 6桁
4. Code expiry: 10分

---

## 電話番号フォーマット設計

### アプリ内の電話番号の扱い

| 場面 | フォーマット例 | 説明 |
|------|---------------|------|
| DBに保存（User.phone_number） | `07501234567` | 11桁ローカル形式（既存のまま変更なし） |
| WhatsApp OTP送信時 | `+9647501234567` | 国際形式（Twilio要件） |

OTPリクエスト時にフロントエンドから `phone_number`（DB保存形式）と `country_code`（例: `+964`）を送信し、バックエンドで国際形式に変換して Twilio に渡す。

### フロントエンドの国番号選択UI

- `intl_phone_field` パッケージを使用（既存のサインアップ画面で採用済み）
- **デフォルト国**: イラク（`IQ`）、国番号 `+964`
- ユーザーは国番号を変更可能
- 選択した国番号と電話番号をバックエンドに送信

---

## データモデル

### 新規モデル: PasswordResetToken

OTP検証後に発行する一時トークンを管理する。OTPの管理はTwilio側が行うため、このモデルはOTP検証後のパスワード更新フェーズでのみ使用する。

| フィールド名 | 型 | 説明 |
|-------------|-----|------|
| id | AutoField | 主キー |
| user | ForeignKey(User) | 対象ユーザー |
| reset_token | UUIDField | OTP検証後に発行するトークン（default=uuid4） |
| created_at | DateTimeField | 作成日時（auto_now_add） |
| expires_at | DateTimeField | 有効期限（作成から30分） |
| is_used | BooleanField | 使用済みフラグ（default=False） |

**インデックス**: `reset_token`, `user`

---

## API設計

### 一般ユーザー向け（認証不要）

| メソッド | エンドポイント | 処理 |
|---------|--------------|------|
| POST | `/accounts/password-reset/request/` | 電話番号 + 国番号受信 → OTP発行・WhatsApp送信 |
| POST | `/accounts/password-reset/verify-otp/` | OTP検証 → `reset_token` 返却 |
| POST | `/accounts/password-reset/confirm/` | `reset_token` + 新パスワードでリセット |

### スタッフ向け（JWT認証 + is_staff 必須）

| メソッド | エンドポイント | 処理 |
|---------|--------------|------|
| POST | `/accounts/staff/password-reset/` | 電話番号 + 新パスワード直接設定 |

---

### リクエスト・レスポンス例

#### POST /accounts/password-reset/request/

```json
// Request
{
  "phone_number": "07501234567",
  "country_code": "+964"
}

// Response 200 OK
{
  "message": "OTP sent to your WhatsApp."
}

// Response 404 Not Found（ユーザーが存在しない）
{
  "error": "User with this phone number does not exist."
}

// Response 429 Too Many Requests（レートリミット）
{
  "error": "Please wait before requesting another OTP."
}
```

#### POST /accounts/password-reset/verify-otp/

```json
// Request
{
  "phone_number": "07501234567",
  "country_code": "+964",
  "otp_code": "123456"
}

// Response 200 OK
{
  "reset_token": "550e8400-e29b-41d4-a716-446655440000"
}

// Response 400 Bad Request（OTP不正 or 期限切れ）
{
  "error": "Invalid or expired OTP."
}
```

#### POST /accounts/password-reset/confirm/

```json
// Request
{
  "reset_token": "550e8400-e29b-41d4-a716-446655440000",
  "new_password": "NewPassword123",
  "confirm_password": "NewPassword123"
}

// Response 200 OK
{
  "message": "Password reset successfully."
}

// Response 400 Bad Request
{
  "error": "Invalid or expired reset token."
}
```

#### POST /accounts/staff/password-reset/

```json
// Request（Authorization: JWT <staff_token> ヘッダー必須）
{
  "phone_number": "07501234567",
  "new_password": "TempPassword123"
}

// Response 200 OK
{
  "message": "Password reset successfully.",
  "phone_number": "07501234567"
}

// Response 403 Forbidden（is_staff=False）
{
  "error": "Staff permission required."
}
```

---

## セキュリティ設計

| 項目 | 仕様 |
|------|------|
| OTP有効期限 | 10分（Twilio側で管理） |
| reset_token有効期限 | 30分（`PasswordResetToken.expires_at`） |
| reset_tokenの再利用防止 | `is_used=True` に更新後は無効 |
| レートリミット | 同一電話番号：1分間に1リクエストまで |
| パスワードバリデーション | Djangoデフォルト（`AUTH_PASSWORD_VALIDATORS`） |
| スタッフAPI認証 | JWT認証 + `is_staff=True` チェック |

---

## バックエンド実装詳細

### 依存パッケージ追加（requirements.txt）

```
twilio==9.x.x
```

### 環境変数（settings.py）

```python
import os

TWILIO_ACCOUNT_SID = os.environ.get('TWILIO_ACCOUNT_SID')
TWILIO_AUTH_TOKEN = os.environ.get('TWILIO_AUTH_TOKEN')
TWILIO_VERIFY_SERVICE_SID = os.environ.get('TWILIO_VERIFY_SERVICE_SID')
```

### Twilioユーティリティ（accounts/twilio_service.py）

```python
from twilio.rest import Client
from django.conf import settings


def build_whatsapp_number(phone_number: str, country_code: str) -> str:
    """
    ローカル形式の電話番号を WhatsApp 用国際形式に変換する
    例: phone_number='07501234567', country_code='+964' → 'whatsapp:+9647501234567'
    先頭の0を除去して国番号を付与する
    """
    local_number = phone_number.lstrip('0')
    return f'whatsapp:{country_code}{local_number}'


def send_otp_via_whatsapp(phone_number: str, country_code: str) -> bool:
    """WhatsApp経由でOTPを送信する"""
    client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
    whatsapp_number = build_whatsapp_number(phone_number, country_code)
    verification = client.verify.v2.services(
        settings.TWILIO_VERIFY_SERVICE_SID
    ).verifications.create(
        to=whatsapp_number,
        channel='whatsapp'
    )
    return verification.status == 'pending'


def verify_otp(phone_number: str, country_code: str, otp_code: str) -> bool:
    """OTPを検証する"""
    client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
    whatsapp_number = build_whatsapp_number(phone_number, country_code)
    verification_check = client.verify.v2.services(
        settings.TWILIO_VERIFY_SERVICE_SID
    ).verification_checks.create(
        to=whatsapp_number,
        code=otp_code
    )
    return verification_check.status == 'approved'
```

### models.py への追加（accounts/models.py）

```python
import uuid
from datetime import timedelta
from django.utils import timezone

class PasswordResetToken(models.Model):
    user = models.ForeignKey(
        'User',
        on_delete=models.CASCADE,
        related_name='password_reset_tokens'
    )
    reset_token = models.UUIDField(default=uuid.uuid4, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)

    def save(self, *args, **kwargs):
        if not self.pk:
            self.expires_at = timezone.now() + timedelta(minutes=30)
        super().save(*args, **kwargs)

    @property
    def is_valid(self):
        return not self.is_used and timezone.now() < self.expires_at

    class Meta:
        indexes = [
            models.Index(fields=['reset_token']),
            models.Index(fields=['user']),
        ]
```

---

## フロントエンド設計

### ディレクトリ構造

```
lib/screens/
├── pass_reset.dart                          # 既存（コメントアウト状態） → 削除
├── pass_reset_request.dart                  # 新規: Step1 電話番号入力
├── pass_reset_otp.dart                      # 新規: Step2 OTP入力
├── pass_reset_confirm.dart                  # 新規: Step3 新パスワード設定
│
└── staff/
    └── user_password_reset.dart             # 新規: スタッフ手動リセット
```

### 画面仕様

#### 1. pass_reset_request.dart（電話番号入力）

- `intl_phone_field` で国番号セレクター + 電話番号入力（**デフォルト: イラク `IQ` / `+964`**）
- 「Send OTP」ボタン
- ローディング中はボタンを無効化
- 成功後: `pass_reset_otp.dart` へ遷移（`phone_number` と `country_code` を引数として渡す）
- エラー時: snackbarでメッセージ表示

#### 2. pass_reset_otp.dart（OTP入力）

- 6桁コード入力フィールド
- 「Verify」ボタン
- 「Resend OTP」ボタン（60秒クールダウンタイマー付き）
- 成功後: `pass_reset_confirm.dart` へ遷移（`reset_token` を引数として渡す）

#### 3. pass_reset_confirm.dart（新パスワード設定）

- 新パスワード入力（表示/非表示トグル付き）
- パスワード確認入力
- 「Reset Password」ボタン
- 成功後: ログイン画面へ遷移 + snackbar「Password reset successfully.」

#### 4. staff/user_password_reset.dart（スタッフ手動リセット）

- ユーザー電話番号入力フィールド
- 新パスワード入力（確認入力あり）
- 「Reset Password」ボタン
- 成功後: snackbar「Password reset successfully.」
- Staff Home Pageのメニューに「Password Reset」項目を追加

### ログイン画面への変更（main.dart）

```dart
// 既存のログインフォームの下に追加
TextButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => PassResetRequestPage()),
  ),
  child: Text('Forgot password?'),
)
```

---

## 画面フロー

### ユーザー側

```
SignInPage（main.dart）
    │
    └─→ "Forgot password?" タップ
            │
            └─→ PassResetRequestPage（国番号選択 + 電話番号入力）
                    │
                    └─→ PassResetOtpPage（OTP入力）
                            │
                            └─→ PassResetConfirmPage（新パスワード設定）
                                    │
                                    └─→ SignInPage（ログイン画面へ戻る）
```

### スタッフ側

```
StaffHomePage
    │
    └─→ "Password Reset" メニュー
            │
            └─→ UserPasswordResetPage（電話番号 + 新パスワード入力）
```

---

## UIモックアップ

### Step1: 電話番号入力

```
┌─────────────────────────────────────────────┐
│  ←  Forgot Password                         │
├─────────────────────────────────────────────┤
│                                             │
│  Enter your phone number to receive         │
│  a verification code via WhatsApp.          │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │  🇮🇶 +964  │  750-123-4567         │    │  ← デフォルトはイラク
│  └─────────────────────────────────────┘    │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │            Send OTP                 │    │
│  └─────────────────────────────────────┘    │
│                                             │
│  If you don't use WhatsApp,                 │
│  please contact staff.                      │
│                                             │
└─────────────────────────────────────────────┘
```

### Step2: OTP入力

```
┌─────────────────────────────────────────────┐
│  ←  Enter Verification Code                 │
├─────────────────────────────────────────────┤
│                                             │
│  A 6-digit code was sent to your WhatsApp.  │
│                                             │
│  ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐       │
│  │ 1 │ │ 2 │ │ 3 │ │ _ │ │ _ │ │ _ │       │
│  └───┘ └───┘ └───┘ └───┘ └───┘ └───┘       │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │              Verify                 │    │
│  └─────────────────────────────────────┘    │
│                                             │
│  Didn't receive it? Resend OTP (45s)        │
│                                             │
└─────────────────────────────────────────────┘
```

### Step3: 新パスワード設定

```
┌─────────────────────────────────────────────┐
│  ←  Set New Password                        │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │  New Password               👁       │    │
│  └─────────────────────────────────────┘    │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │  Confirm Password           👁       │    │
│  └─────────────────────────────────────┘    │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │           Reset Password            │    │
│  └─────────────────────────────────────┘    │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 実装順序

### Phase 1: バックエンド（Django）

1. `accounts/models.py` - `PasswordResetToken` モデル追加、壊れた既存実装を削除
2. マイグレーション作成・実行
3. `requirements.txt` - `twilio` 追加
4. `accounts/twilio_service.py` - Twilioユーティリティ作成（新規）
5. `accounts/serializers.py` - 新規シリアライザー追加、旧実装削除
6. `accounts/views.py` - 新規View追加（OTPリクエスト・検証・確認・スタッフリセット）、旧実装削除
7. `accounts/urls.py` - ルーティング更新
8. `wellbee/settings.py` - Twilio環境変数設定追加

### Phase 2: フロントエンド（Flutter）

1. `lib/screens/pass_reset.dart` - ファイル削除（コメントアウト状態）
2. `lib/screens/pass_reset_request.dart` - Step1画面（新規作成）
3. `lib/screens/pass_reset_otp.dart` - Step2画面（新規作成）
4. `lib/screens/pass_reset_confirm.dart` - Step3画面（新規作成）
5. `lib/screens/staff/user_password_reset.dart` - スタッフ手動リセット（新規作成）
6. `lib/main.dart` - 「Forgot password?」リンク追加
7. `lib/screens/staff/staff_home_page.dart` - 「Password Reset」メニュー追加

---

## 注意事項・考慮事項

### 1. WhatsApp普及率（イラク）

イラクではWhatsAppの普及率は高く（推定70〜80%）、本機能の有効性は高い。ただし一部ユーザーがWhatsAppを使用していない場合に備え、ログイン画面に「If you don't use WhatsApp, please contact staff.」の案内を添える。

### 2. 電話番号フォーマット変換（イラクの例）

| フォーマット | 例 |
|-------------|-----|
| DBに保存 | `07501234567` |
| Twilio送信 | `whatsapp:+9647501234567` |

変換ロジック: 先頭の `0` を除去 → 国番号を付与

### 3. Twilio Sandboxから本番への移行

- 開発時は Twilio WhatsApp Sandbox を使用（事前登録した番号のみ受信可能）
- 本番環境では Meta Business Account の審査が必要（24〜48時間）

### 4. レートリミット実装

Djangoのキャッシュ（MemcacheまたはRedis）を使ってシンプルに実装。外部ライブラリ（django-ratelimit等）は不要。

### 5. パスワードリセット完了後のトークン処理

パスワード変更後、既存のJWTアクセストークンは引き続き有効なままとなる（SimpleJWTはデフォルトでブラックリスト機能が無効）。現時点では許容範囲とするが、将来的にはJWT Blacklistの導入を検討。

---

## ファイル一覧（作成/変更/削除）

### 新規作成

| ファイル | 説明 |
|---------|------|
| `wellbee/accounts/twilio_service.py` | Twilioユーティリティ（OTP送信・検証） |
| `wellbee/accounts/migrations/0002_passwordresettoken.py` | マイグレーション（自動生成） |
| `lib/screens/pass_reset_request.dart` | Step1: 電話番号入力画面 |
| `lib/screens/pass_reset_otp.dart` | Step2: OTP入力画面 |
| `lib/screens/pass_reset_confirm.dart` | Step3: 新パスワード設定画面 |
| `lib/screens/staff/user_password_reset.dart` | スタッフ手動リセット画面 |

### 変更

| ファイル | 変更内容 |
|---------|---------|
| `wellbee/accounts/models.py` | `PasswordResetToken` モデル追加 |
| `wellbee/accounts/serializers.py` | 旧パスワードリセット実装を削除し、新規シリアライザーに置き換え |
| `wellbee/accounts/views.py` | 旧パスワードリセット実装を削除し、新規Viewに置き換え |
| `wellbee/accounts/urls.py` | ルーティング更新 |
| `wellbee/wellbee/settings.py` | Twilio環境変数設定追加 |
| `wellbee/requirements.txt` | `twilio` 追加 |
| `lib/main.dart` | 「Forgot password?」リンク追加 |
| `lib/screens/staff/staff_home_page.dart` | 「Password Reset」メニュー追加 |

### 削除

| ファイル | 理由 |
|---------|------|
| `lib/screens/pass_reset.dart` | 旧実装（全コメントアウト）、新規ファイルに置き換え |
