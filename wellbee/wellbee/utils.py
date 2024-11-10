from rest_framework.views import exception_handler
from rest_framework.response import Response

def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)

    if response is not None and response.status_code >= 400:
        return Response({"detail":"Error Occurred"}, status=response.status_code)
    return response