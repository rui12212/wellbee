import os
from typing import Optional
import firebase_admin
from firebase_admin import credentials, auth

_app = None


def _get_app():
    global _app
    if _app is None:
        cred_path = os.path.join(
            os.path.dirname(os.path.dirname(__file__)),
            'firebase_service_account.json',
        )
        cred = credentials.Certificate(cred_path)
        _app = firebase_admin.initialize_app(cred)
    return _app


def verify_id_token(id_token: str) -> Optional[dict]:
    """Firebase IDトークンを検証し、デコード済みトークンを返す。失敗時はNone。"""
    try:
        _get_app()
        return auth.verify_id_token(id_token)
    except Exception:
        return None


