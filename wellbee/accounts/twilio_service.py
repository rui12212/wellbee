import logging
from twilio.rest import Client
from twilio.base.exceptions import TwilioRestException
from django.conf import settings

logger = logging.getLogger(__name__)

def send_otp_via_whatsapp(phone_number:str, country_code: str) -> bool:
    # OTP送信viaワッツアップ。phone_numberはE.164形式(例: +9647501234567)
    try:
        client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
        verification = client.verify.v2.services(
            settings.TWILIO_VERIFY_SERVICE_SID
        ).verifications.create(
            to=phone_number,
            channel='whatsapp'
        )
        return verification.status== "pending"
    except TwilioRestException as e:
        logger.error(f"Twilio OTP send failed:{e}")
        return False

def verify_otp(phone_number: str,country_code: str, otp_code: str ) -> bool:
    # phone_numberはE.164形式(例: +9647501234567)
    try:
        client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
        verification_check = client.verify.v2.services(
          settings.TWILIO_VERIFY_SERVICE_SID
        ).verification_checks.create(
        to= phone_number,
        code=otp_code,
        )
        return verification_check.status == "approved"
    except TwilioRestException as e :
        logger.error(f"Twilio OTP verify failed: {e}")
        return False

