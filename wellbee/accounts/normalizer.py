"""電話番号のE.164正規化ユーティリティ。

`phonenumbers` ライブラリで以下を行う:
- 国際プレフィックス (`+` または `00`) と trunk 0 の正規化
- 国番号付き（例: +9640111111111）から trunk 0 を除去 → +964111111111
- 入力がパース不能の場合は元の値をそのまま返す（保存時バリデーションは
  field の RegexValidator に任せる）
"""

import phonenumbers


_DEFAULT_REGION = 'IQ'


def normalize_phone(raw):
    """任意の電話番号文字列を E.164 形式 (例 +964111111111) に正規化して返す。"""
    if not raw:
        return raw
    cleaned = str(raw).strip()
    if not cleaned:
        return cleaned
    try:
        # `+` 始まりは国番号込みでパース、それ以外はデフォルト国 (IQ) でパース
        if cleaned.startswith('+'):
            parsed = phonenumbers.parse(cleaned, None)
        else:
            parsed = phonenumbers.parse(cleaned, _DEFAULT_REGION)
    except phonenumbers.NumberParseException:
        return cleaned
    return phonenumbers.format_number(
        parsed, phonenumbers.PhoneNumberFormat.E164
    )
