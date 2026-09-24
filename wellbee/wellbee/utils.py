from rest_framework.views import exception_handler
from rest_framework.response import Response
import logging

logger = logging.getLogger(__name__)

def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)

    # DRFが処理できない例外はNoneが返る
    if response is None:
        return response
    
    logger.error(f"[API error] {exc} | data: {response.data}")

    # 500番台は詳細を隠したエラー表示を行う
    if response.status_code >= 500:
        return Response({"detail": "Error occurred"}, status=response.status_code)
    

    # 400番台はエラーコードを示す。ValidationErrorの内容が表示される
    return response