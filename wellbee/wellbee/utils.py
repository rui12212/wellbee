from rest_framework.views import exception_handler
from rest_framework.response import Response

def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)

    if response is not None and response.status_code >= 400:
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f"[DEBUG] Original error: {exc} | response data: {response.data}")
        return Response({"detail":"Error Occurred"}, status=response.status_code)
    return response