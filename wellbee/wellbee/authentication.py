from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework import exceptions
from django.utils.crypto import constant_time_compare
import logging

logger = logging.getLogger(__name__)

class QueryParameterJWTAuthentication(JWTAuthentication):
    def authenticate(self, request):
        if request.method == 'POST' and request.path == '/accounts/create/':
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