# Membership編集機能 仕様書

## 概要

スタッフが既存のMembershipの情報を後から変更できる機能を`screens/staff/staff_home_page.dart`に追加する。

**作成日:** 2026-01-16

---

## 1. 対象モデル

**Membershipモデル** (`wellbee/attendances/models.py`)

### 1.1 編集可能フィールド一覧

| フィールド名 | 型 | 説明 | 入力タイプ |
|------------|---|------|----------|
| `course` | ForeignKey(Course) | コース | ドロップダウン選択 |
| `duration` | IntegerField | 期間（月） | ドロップダウン (1,2,3,6,12) |
| `max_join_times` | IntegerField | 最大参加回数 | 数値入力 |
| `requested_join_times` | IntegerField | リクエスト済み回数 | 数値入力 |
| `already_join_times` | IntegerField | 参加済み回数 | 数値入力 |
| `start_day` | DateField | 開始日 | 日付ピッカー |
| `expire_day` | DateField | 有効期限 | 日付ピッカー |
| `is_expired` | BooleanField | 期限切れフラグ | スイッチ |
| `last_check_in` | DateField | 最終チェックイン日 | 日付ピッカー |

### 1.2 読み取り専用（編集不可）フィールド

| フィールド名 | 理由 |
|------------|------|
| `id` | 自動生成 |
| `user` | 購入者（変更不可） |
| `attendee` | 利用者（変更不可） |
| `request_time` | 購入日時（自動設定） |
| `times` | 週あたりの回数（作成時に設定） |
| `num_person` | 人数（作成時に設定） |
| `is_approved` | 承認状態（作成時に設定） |
| `total_price` | 合計金額（作成時に設定） |
| `discount_rate` | 割引率（作成時に設定） |
| `offer` | 特典割引額（作成時に設定） |
| `minus` | ポイント使用額（作成時に設定） |
| `discounted_total_price` | 自動計算（作成時のみ計算） |

---

## 2. 画面構成

### 2.1 Staff Home Pageへのメニュー追加

`lib/screens/staff/staff_home_page.dart` に新しいメニューカードを追加:

```
アイコン: Icons.edit_note_outlined
タイトル: 'Edit Membership'
遷移先: MembershipEditListPage
```

### 2.2 新規作成ファイル

```
lib/screens/staff/membership/
├── membership_edit_list.dart    # Membership一覧（検索・選択画面）
└── membership_edit.dart         # Membership編集フォーム画面
```

### 2.3 画面フロー

```
Staff Home Page
    ↓ (Edit Membershipタップ)
MembershipEditListPage (Membership一覧)
    ↓ (編集したいMembershipを選択)
MembershipEditPage (編集フォーム)
    ↓ (保存ボタンタップ)
API PATCH リクエスト
    ↓ (成功)
一覧画面に戻る
```

---

## 3. 画面詳細設計

### 3.1 MembershipEditListPage（一覧画面）

**ヘッダー:**
- タイトル: "Edit Membership"
- サブタイトル: "Select membership to edit"
- 戻るボタン

**検索/フィルター機能:**
- コース名フィルター（ドロップダウン）
- Attendee名検索（テキスト入力）
- 電話番号検索（テキスト入力） - AttendeeのUserモデルのphone_numberで検索
- 有効期限フィルター（有効/期限切れ）

**一覧表示:**
- 既存の`TicketList`または`MembershipTicketList`ウィジェットを活用
- 各アイテムタップで編集画面へ遷移
- 表示情報: Attendee名、コース名、有効期限、参加回数、電話番号

**APIエンドポイント:**
```
GET /attendances/membership/all_available_membership/
```

### 3.2 MembershipEditPage（編集画面）

**ヘッダー:**
- タイトル: "{Attendee名} - {コース名}"
- 戻るボタン

**読み取り専用セクション:**
- Membership ID
- User情報（電話番号含む）
- Attendee情報
- 購入日時
- 基本情報（times, num_person, is_approved）
- 料金情報（total_price, discount_rate, offer, minus, discounted_total_price）

**編集可能セクション（フォーム）:**

| セクション | フィールド |
|----------|----------|
| 基本情報 | course, duration |
| 参加状況 | max_join_times, requested_join_times, already_join_times |
| 期間設定 | start_day, expire_day |
| ステータス | is_expired |
| その他 | last_check_in |

**保存ボタン:**
- "Save Changes" ボタン
- 確認ダイアログ表示後にPATCHリクエスト送信

---

## 4. API設計

### 4.1 編集用API

**エンドポイント:**
```
PATCH /attendances/membership/{id}/edit/
```

**リクエストボディ例:**
```json
{
  "course": 2,
  "duration": 3,
  "start_day": "2025-02-01",
  "expire_day": "2025-05-01",
  "max_join_times": 48,
  "already_join_times": 10,
  "is_expired": false
}
```

**レスポンス:**
- 200 OK: 更新成功
- 400 Bad Request: バリデーションエラー
- 403 Forbidden: 権限エラー

---

## 5. バックエンド修正

### 5.1 モデルシグナル修正（重要）

`wellbee/attendances/models.py` の以下のシグナルを**作成時のみ実行**されるよう修正:

#### 5.1.1 set_discounted_total_price

**変更前:**
```python
@receiver(pre_save, sender=Membership)
def set_discounted_total_price(sender, instance, **kwargs):
    instance.discounted_total_price = ((instance.total_price - (instance.minus + instance.offer))) * instance.discount_rate
```

**変更後:**
```python
@receiver(pre_save, sender=Membership)
def set_discounted_total_price(sender, instance, **kwargs):
    # 新規作成時のみ計算（pkがない = 新規作成）
    if instance.pk is None:
        instance.discounted_total_price = ((instance.total_price - (instance.minus + instance.offer))) * instance.discount_rate
```

#### 5.1.2 set_max_join_times

**変更前:**
```python
@receiver(pre_save, sender=Membership)
def set_max_join_times(sender, instance, **kwargs):
    if instance.course and not instance.course.is_private:
        instance.max_join_times = int(instance.times * instance.duration * 4)
    else:
        instance.max_join_times = int(instance.times)
```

**変更後:**
```python
@receiver(pre_save, sender=Membership)
def set_max_join_times(sender, instance, **kwargs):
    # 新規作成時のみ計算（pkがない = 新規作成）
    if instance.pk is None:
        if instance.course and not instance.course.is_private:
            instance.max_join_times = int(instance.times * instance.duration * 4)
        else:
            instance.max_join_times = int(instance.times)
```

#### 5.1.3 set_expire_day

**変更前:**
```python
@receiver(pre_save, sender=Membership)
def set_expire_day(sender, instance, created ,**kwargs):
    if instance.start_day:
        instance.expire_day = (instance.start_day + relativedelta(months=instance.duration))
    else:
        instance.expire_day = (timezone.localdate() + relativedelta(months=instance.duration))
```

**変更後:**
```python
@receiver(pre_save, sender=Membership)
def set_expire_day(sender, instance, **kwargs):
    # 新規作成時のみ計算（pkがない = 新規作成）
    # ※ pre_saveにはcreated引数は存在しないため削除
    if instance.pk is None:
        if instance.start_day:
            instance.expire_day = (instance.start_day + relativedelta(months=instance.duration))
        else:
            instance.expire_day = (timezone.localdate() + relativedelta(months=instance.duration))
```

> **注意:** 現在の`set_expire_day`関数はpre_saveシグナルなのに`created`引数を受け取っています。pre_saveには`created`引数は存在しないため、この修正でバグも同時に修正されます。

### 5.2 Serializer追加

`wellbee/attendances/serializers.py` に追加:

```python
class MembershipEditSerializer(serializers.ModelSerializer):
    """スタッフ用Membership編集Serializer"""
    attendee_name = serializers.CharField(source='attendee.name', read_only=True)
    course_name = serializers.CharField(source='course.course_name', read_only=True)
    user_phone = serializers.CharField(source='user.phone_number', read_only=True)

    class Meta:
        model = Membership
        fields = (
            'id', 'user', 'attendee', 'course', 'times', 'num_person',
            'duration', 'offer', 'minus', 'is_approved', 'total_price',
            'discount_rate', 'discounted_total_price', 'max_join_times',
            'requested_join_times', 'already_join_times', 'request_time',
            'start_day', 'expire_day', 'is_expired', 'last_check_in',
            'attendee_name', 'course_name', 'user_phone'
        )
        extra_kwargs = {
            # 読み取り専用フィールド
            'id': {'read_only': True},
            'user': {'read_only': True},
            'attendee': {'read_only': True},
            'request_time': {'read_only': True},
            # 基本情報（読み取り専用）
            'times': {'read_only': True},
            'num_person': {'read_only': True},
            'is_approved': {'read_only': True},
            # 料金関連（読み取り専用）
            'total_price': {'read_only': True},
            'discount_rate': {'read_only': True},
            'offer': {'read_only': True},
            'minus': {'read_only': True},
            'discounted_total_price': {'read_only': True},
        }
```

### 5.3 ViewSetに編集アクション追加

`wellbee/attendances/views.py` の `MembershipViewSet` に追加:

```python
@action(detail=True, methods=['patch'], permission_classes=[IsStaffUser], url_path='edit')
def edit_membership(self, request, pk=None):
    """スタッフによるMembership編集"""
    membership = self.get_object()
    serializer = MembershipEditSerializer(membership, data=request.data, partial=True)
    serializer.is_valid(raise_exception=True)
    serializer.save()
    return Response(serializer.data, status=status.HTTP_200_OK)
```

### 5.4 一覧取得APIに電話番号追加

`fetch_all_available_membership`アクションを修正:

```python
@action(detail=False, methods=['get'], permission_classes=[MembershipPermission], url_path='all_available_membership')
def fetch_all_available_membership(self, request):
    now_utc = timezone.now()
    local_timezone = pytz.timezone('Africa/Nairobi')
    now_local = now_utc.astimezone(local_timezone)
    today_date = now_local.date()
    memberships = Membership.objects.filter(
        expire_day__gte = today_date
    ).order_by('expire_day').annotate(
        attendee_name = F('attendee__name'),
        course_name = F('course__course_name'),
        user_phone = F('user__phone_number')  # 追加
    )
    serializer = self.get_serializer(memberships, many=True)
    return Response(serializer.data)
```

---

## 6. Flutter実装詳細

### 6.1 MembershipEditListPage

```dart
class MembershipEditListPage extends StatefulWidget {
  // 全Membership一覧を取得・表示
  // フィルター機能（コース名、Attendee名、電話番号、有効期限）
  // 選択時にMembershipEditPageへ遷移
}
```

**検索機能実装:**
```dart
// 検索条件
String? selectedCourse;
String attendeeNameQuery = '';
String phoneNumberQuery = '';  // 電話番号検索
bool showExpiredOnly = false;

// フィルタリング処理
List<dynamic> filteredList = membershipList.where((m) {
  bool matchCourse = selectedCourse == null || m['course_name'] == selectedCourse;
  bool matchName = attendeeNameQuery.isEmpty ||
      m['attendee_name'].toLowerCase().contains(attendeeNameQuery.toLowerCase());
  bool matchPhone = phoneNumberQuery.isEmpty ||
      (m['user_phone'] ?? '').contains(phoneNumberQuery);
  return matchCourse && matchName && matchPhone;
}).toList();
```

### 6.2 MembershipEditPage

```dart
class MembershipEditPage extends StatefulWidget {
  final Map<String, dynamic> membership;

  // 読み取り専用表示（times, num_person, is_approved, 料金情報）
  // フォームウィジェット
  // 日付ピッカー（start_day, expire_day, last_check_in）
  // ドロップダウン（course, duration）
  // 数値入力フィールド（max_join_times, requested_join_times, already_join_times）
  // スイッチ（is_expired）
  // 保存ボタン
}
```

### 6.3 APIリクエスト

```dart
Future<bool> _updateMembership(int membershipId, Map<String, dynamic> data) async {
  token = await SharedPrefs.fetchStaffAccessToken();
  var url = Uri.parse('${baseUri}attendances/membership/$membershipId/edit/');
  var response = await http.patch(
    url,
    headers: {
      "Authorization": 'JWT $token',
      "Content-Type": "application/json"
    },
    body: jsonEncode(data),
  );
  return response.statusCode == 200;
}
```

---

## 7. UI/UXガイドライン

- 既存のスタッフ画面のデザインパターンを踏襲
- `flutter_screenutil`を使用したレスポンシブデザイン
- 読み取り専用フィールドはグレーアウトして編集不可であることを明示
- 保存前に確認ダイアログを表示
- エラー時はSnackBarで通知

---

## 8. データ整合性バリデーション

- `already_join_times` > `max_join_times`とならないようバリデーション追加
- `expire_day` < `start_day`とならないようバリデーション追加

---

## 9. 変更サマリー

| 項目 | 内容 |
|-----|------|
| 編集可能フィールド | 9項目（course, duration, max_join_times, requested_join_times, already_join_times, start_day, expire_day, is_expired, last_check_in） |
| 読み取り専用フィールド | 12項目（id, user, attendee, request_time, times, num_person, is_approved, total_price, discount_rate, offer, minus, discounted_total_price） |
| 検索機能 | コース名、Attendee名、電話番号、有効期限 |
| models.py修正 | 3つのシグナル（set_discounted_total_price, set_max_join_times, set_expire_day）を作成時のみ実行に変更 |