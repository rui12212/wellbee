# authentication.py
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework import exceptions
from django.utils.crypto import constant_time_compare
import logging

logger = logging.getLogger(__name__)

class QueryParameterJWTAuthentication(JWTAuthentication):
    # 認証スキップ対象パス（AllowAny ビューでも AuthenticationFailed が先に発火するため除外）
    UNAUTHENTICATED_PATHS = {
        '/accounts/create/',
        '/accounts/password-reset/request/',
        '/accounts/password-reset/verify-otp/',
        '/accounts/password-reset/confirm/',
        '/authen/jwt/create/',
        '/authen/jwt/refresh/',
    }

    def _is_unauthenticated(self, path):
        """認証スキップ対象かを末尾一致で判定する。

        完全一致にすると /api/v6/accounts/create/ のようなバージョン
        プレフィックス付きのパスが外れ、バージョンを上げるたびに
        UNAUTHENTICATED_PATHS を書き足す必要が出る。先頭を見ないことで
        プレフィックスに追従しなくて済む。
        """
        return any(path.endswith(p) for p in self.UNAUTHENTICATED_PATHS)

    def authenticate(self, request):
        if request.method == 'POST' and self._is_unauthenticated(request.path):
            return None

        # URLからtokenを取得
        url_token = request.query_params.get('token')
        if not url_token:
            logger.debug('URLにtokenが存在しません')
            raise exceptions.AuthenticationFailed('Token is missing in the URL')

        # Authorizationヘッダーからトークンを取得
        header_auth = super().authenticate(request)
        if not header_auth:
            logger.debug('ヘッダーにtokenが存在しません')
            raise exceptions.AuthenticationFailed('Token is missing in the Header')

        user, header_token = header_auth

        # AccessTokenオブジェクトを文字列に変換
        header_token_str = str(header_token)

        # デバッグ用ログ出力
        logger.debug(f'ヘッダーのtoken: {header_token_str}')
        logger.debug(f'URLのtoken: {url_token}')

        # トークンの比較
        if not constant_time_compare(header_token_str, url_token):
            logger.debug('ヘッダーとURLのtokenが一致しません')
            raise exceptions.AuthenticationFailed('Token in URL and Header does not match')

        logger.debug('ヘッダーとURLのtokenが一致しました')
        return (user, header_token)