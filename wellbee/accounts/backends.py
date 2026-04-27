from django.contrib.auth.backends import ModelBackend
from .normalizer import normalize_phone


class PhoneNormalizingBackend(ModelBackend):
    def authenticate(self, request, username=None, password=None, **kwargs):
        if username:
            username = normalize_phone(username)
        return super().authenticate(request, username=username, password=password, **kwargs)
