# パスワードリセット（WhatsApp OTP）実装進捗

## 作業日時
2026-02-24

## 作業概要
一般ユーザーが WhatsApp OTP を使用してパスワードをリセットできる機能と、スタッフが手動でユーザーパスワードをリセットできる機能を実装した。OTP 送信には Twilio Verify API（WhatsApp チャンネル）を使用。

---

## 完了した作業

### 1. バックエンド（Django）

#### 新規ファイル

**`wellbee/accounts/twilio_service.py`**
- `build_e164_number(phone_number, country_code)`: ローカル形式 → E.164 国際形式に変換
- `send_otp_via_whatsapp(phone_number, country_code)`: Twilio Verify API で WhatsApp OTP 送信
- `verify_otp(phone_number, country_code, otp_code)`: OTP 検証
- `TwilioRestException` をキャッチし、失敗時は `False` を返す（500 にしない）

**`wellbee/accounts/migrations/0002_passwordresettoken.py`**
- `PasswordResetToken` モデルのマイグレーション（自動生成・適用済み）

#### 変更ファイル

**`wellbee/accounts/models.py`**
- `PasswordResetToken` モデルを追加
  - フィールド: `user`（FK）, `reset_token`（UUID）, `created_at`, `expires_at`（30分）, `is_used`
  - プロパティ: `is_valid`（期限・使用済みチェック）

**`wellbee/accounts/serializers.py`**
- 旧 `secret_words` ベースのシリアライザーを削除
- 新規追加:
  - `PasswordResetRequestSerializer`: phone_number + country_code のバリデーション（ユーザー存在確認含む）
  - `PasswordResetVerifyOtpSerializer`: OTP 検証用
  - `PasswordResetConfirmSerializer`: 新パスワード設定用
  - `StaffPasswordResetSerializer`: スタッフ手動リセット用

**`wellbee/accounts/views.py`**
- 旧 `secret_words` ベースの ViewSet を削除
- 新規追加（すべて `APIView`、`AllowAny` または `IsAuthenticated`）:
  - `PasswordResetRequestView`: OTP 送信 + レートリミット（1分/電話番号、Django cache 使用）
  - `PasswordResetVerifyOtpView`: OTP 検証 → `reset_token` 返却
  - `PasswordResetConfirmView`: 新パスワード保存
  - `StaffPasswordResetView`: スタッフ手動リセット（JWT 認証必須）

**`wellbee/accounts/urls.py`**
- 新規エンドポイント追加:
  ```
  POST /accounts/password-reset/request/
  POST /accounts/password-reset/verify-otp/
  POST /accounts/password-reset/confirm/
  POST /accounts/staff/password-reset/
  ```

**`wellbee/wellbee/settings.py`**
- AWS SNS 関連の環境変数を削除
- Twilio 環境変数を追加（値は `.env` から読み込み）:
  - `TWILIO_ACCOUNT_SID`
  - `TWILIO_AUTH_TOKEN`
  - `TWILIO_VERIFY_SERVICE_SID`

**`wellbee/wellbee/authentication.py`**
- `QueryParameterJWTAuthentication.UNAUTHENTICATED_PATHS` にパスワードリセット系エンドポイントを追加
- 追加前は `AllowAny` ビューでも `AuthenticationFailed` が先に発火して 401 になっていた

**`wellbee/requirements.txt`**
- `twilio==9.4.5` を追加

**`wellbee/docker-compose.yml`**
- `app` サービスに `environment: DATABASE_HOST: db` を追加
  - `.env` の `DATABASE_HOST=localhost` は Docker コンテナ内では無効なため
- `depends_on: db` を追加

#### 削除ファイル

**`wellbee/attendances/migrations/0017_notificationdayssetting_usermessage_userfcmtoken.py`**
- DB では既にロールバック済みだったため削除（`feature/password_reset` ブランチでは不要）

**`wellbee/attendances/serializers.py` / `views.py` / `urls.py`**
- `NotificationDaysSetting`, `UserMessage`, `UserFCMToken` への参照を削除
  （別ブランチで実装予定の機能がこのブランチに混入していたため分離）

---

### 2. フロントエンド（Flutter）

#### 新規ファイル

| ファイル | 内容 |
|---|---|
| `lib/screens/pass_reset_request.dart` | Step 1: 電話番号入力（`IntlPhoneField`、デフォルト IQ +964） |
| `lib/screens/pass_reset_otp.dart` | Step 2: 6桁 OTP 入力（60秒再送クールダウン付き） |
| `lib/screens/pass_reset_confirm.dart` | Step 3: 新パスワード設定 → ログイン画面に戻る |
| `lib/screens/staff/user_password_reset.dart` | スタッフ手動パスワードリセット画面（JWT 認証使用） |

#### 変更ファイル

**`lib/main.dart`**
- `pass_reset_request.dart` の import を追加
- Sign In 画面の `_Footer` 直前に "Forgot password?" TextButton を追加

**`lib/screens/staff/staff_home_page.dart`**
- `user_password_reset.dart` の import を追加
- "Password Reset" メニューカード（`Icons.lock_reset_outlined`）を追加

#### 削除ファイル

**`lib/screens/pass_reset.dart`**
- 全コメントアウト済みの旧実装（`secret_words` ベース）を削除

---

## 現在直面している課題（ペンディング）

### Twilio Verify WhatsApp チャンネル未開通

**状況**: Twilio Verify Service の WhatsApp チャンネルを有効化しようとしているが、**Sender Pool への登録審査**が完了していない。

**エラー内容**:
```
HTTP 400 error: Delivery channel disabled: WHATSAPP
```

**原因**: Twilio の WhatsApp Business API を利用するには、Meta（Facebook）Business Manager との連携審査が必要。審査には数日〜数週間かかる場合がある。

**対応済み**: Twilio の有料アカウントにアップグレード済み。

**次のアクション**:
- Sender Pool 審査完了を待つ
- または SMS チャンネルに一時切り替えして動作確認を進める（`channel='sms'` に変更するだけ）

---

## デバッグ中に発見・修正した問題

| # | 問題 | 原因 | 修正 |
|---|---|---|---|
| 1 | Docker コンテナ起動後 502 | `twilio` パッケージ未インストール | `docker compose build app` でイメージ再ビルド |
| 2 | `ModuleNotFoundError: No module named 'twilio'` | requirements.txt 更新後にイメージ未再ビルド | 上記と同じ |
| 3 | MySQL 接続エラー（`localhost` 拒否） | Docker 内は `localhost` ではなくサービス名 `db` が必要 | `docker-compose.yml` に `DATABASE_HOST: db` を追記 |
| 4 | パスワードリセット API で 401 | `QueryParameterJWTAuthentication` が token なしリクエストで `AuthenticationFailed` を先に発火 | `UNAUTHENTICATED_PATHS` にパスワードリセット系パスを追加 |
| 5 | `Invalid parameter 'To': whatsapp:+964...` | Twilio Verify API の `to` パラメータは `whatsapp:` プレフィックス不要（E.164 形式で指定） | `build_whatsapp_number` → `build_e164_number` に変更 |
| 6 | `TwilioRestException` が 500 になる | `twilio_service.py` に例外処理がなかった | `try/except TwilioRestException` を追加し `False` を返すように修正 |
| 7 | `Delivery channel disabled: WHATSAPP` | Twilio トライアルアカウント制限 or WhatsApp Sender Pool 未登録 | 有料アカウントにアップグレード、Sender Pool 審査待ち |
