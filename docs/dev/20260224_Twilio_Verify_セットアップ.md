# Twilio Verify API セットアップ手順

作成日: 2026-02-24
対象機能: WhatsApp OTP パスワードリセット
関連ドキュメント: `20260224_パスワードリセット_WhatsApp_OTP.md`

---

## 概要

Twilio Verify API を使って WhatsApp 経由で OTP（6桁ワンタイムパスワード）を送信する。
バックエンドは `wellbee/accounts/twilio_service.py` で処理している。

---

## 1. アカウント作成

1. [https://www.twilio.com](https://www.twilio.com) → **Sign up**
2. メールアドレス・電話番号で登録
3. 新規登録時に $15.00 の無料クレジットが付与される（本番移行時は課金設定が必要）

---

## 2. 認証情報の取得

Twilio Console のダッシュボード（トップページ）に表示される以下の値を取得する。

| 項目 | 環境変数名 | 値の形式 |
|---|---|---|
| Account SID | `TWILIO_ACCOUNT_SID` | `ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` |
| Auth Token | `TWILIO_AUTH_TOKEN` | 32文字の英数字 |

> **秘匿情報**: これらの値は `.env` に記載し、Git にコミットしない。

---

## 3. Verify Service の作成

1. Console 左メニュー → **Explore Products** → 検索欄に `Verify` と入力
2. **Verify** を選択 → **Services** → **Create new Service**
3. **Friendly Name** に任意の名前（例: `wellbee`）を入力 → **Create**
4. 作成された Service の **Service SID** を取得する

| 項目 | 環境変数名 | 値の形式 |
|---|---|---|
| Verify Service SID | `TWILIO_VERIFY_SERVICE_SID` | `VAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` |

> **秘匿情報**: Service SID も `.env` に記載し、Git にコミットしない。

---

## 4. WhatsApp チャンネルの有効化

Verify Service の設定画面内：

1. **Channels** タブを開く
2. **WhatsApp** をオンにする
3. 送信元の WhatsApp 番号を設定する（下記「開発時」「本番時」を参照）

### 開発時: WhatsApp Sandbox

Twilio が提供する Sandbox 番号を使う。事前に受信者（テストユーザー）が Sandbox に参加する必要がある。

**参加手順（テストユーザー側）:**

1. Console → **Messaging** → **Try it out** → **Send a WhatsApp message** を開く
2. 表示された Twilio の Sandbox 番号に WhatsApp で `join <キーワード>` と送信する
3. 「You are now connected.」と返信されれば参加完了

> テストする電話番号ごとにこの手順が必要。

### 本番時: Meta Business Account との連携

1. Meta Business Manager でビジネス認証を完了させる
2. WhatsApp Business アカウントを作成する
3. Twilio Console → **Messaging** → **Senders** → WhatsApp 番号を追加し、Meta との連携審査を行う
4. 審査通過後、Verify Service の WhatsApp チャンネルに本番番号を設定する

> 審査には数日〜数週間かかる場合がある。

---

## 5. .env への設定

`wellbee/.env` に以下を追記（値は Twilio Console から取得した実際の値に置き換える）:

```
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_VERIFY_SERVICE_SID=VAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

---

## 6. 動作確認

Django サーバーを起動した状態で curl で疎通確認する。

**OTP 送信リクエスト:**

```bash
curl -X POST http://localhost:8000/accounts/password-reset/request/ \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "07501234567", "country_code": "+964"}'
```

成功レスポンス:
```json
{"message": "OTP sent to your WhatsApp."}
```

**OTP 検証リクエスト:**

```bash
curl -X POST http://localhost:8000/accounts/password-reset/verify-otp/ \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "07501234567", "country_code": "+964", "otp_code": "123456"}'
```

成功レスポンス:
```json
{"reset_token": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"}
```

---

## 7. 料金

| イベント | 料金 |
|---|---|
| OTP 検証成功 1件 | $0.05 |
| 検証失敗・タイムアウト | 無料 |
| 無料トライアルクレジット | $15.00（約300件分） |

> 料金は変更される場合がある。最新情報は [Twilio Pricing](https://www.twilio.com/en-us/verify/pricing) を参照。

---

## 8. 注意事項

- `.env` は `.gitignore` に含まれていることを確認する
- Auth Token は定期的にローテーションすることを推奨
- 本番環境では環境変数をサーバーのシークレット管理サービス（AWS Secrets Manager 等）で管理することを検討する
- レートリミット（1分に1リクエスト/電話番号）はバックエンドで実装済み（`PasswordResetRequestView` 内の Django cache 使用）
