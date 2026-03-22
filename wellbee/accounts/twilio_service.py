import logging
from twilio.rest import Client
from twilio.base.exceptions import TwilioRestException
from django.conf import settings

logger = logging.getLogger(__name__)

def build_e164_number(phone_number: str, country_code:str) -> str:
    # 先頭の0を削除して、電話番号に国番号を付与する
    local_number = phone_number.lstrip('0')
    return f"{country_code}{local_number}"

def send_otp_via_whatsapp(phone_number:str, country_code: str) -> bool:
    # OTP送信viaワッツアップ。成功か失敗かをbooleanで返す
    try:
        client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
        e164_number = build_e164_number(phone_number, country_code)
        verification = client.verify.v2.services(
            settings.TWILIO_VERIFY_SERVICE_SID
        ).verifications.create(
            to=e164_number,
            channel='whatsapp'
        )
        return verification.status== "pending"
    except TwilioRestException as e:
        logger.error(f"Twilio OTP send failed:{e}")
        return False

def verify_otp(phone_number: str,country_code: str, otp_code: str ) -> bool:
    try:
        client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
        e164_number = build_e164_number(phone_number, country_code)
        verification_check = client.verify.v2.services(
          settings.TWILIO_VERIFY_SERVICE_SID
        ).verification_checks.create(
        to= e164_number,
        code=otp_code,
        )
        return verification_check.status == "approved"
    except TwilioRestException as e :
        logger.error(f"Twilio OTP verify failed: {e}")
        return False

