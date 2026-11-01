import logging

from firebase_admin import messaging

from accounts.firebase_service import get_app

from .models import FCMToken

logger = logging.getLogger(__name__)

# FCM のマルチキャストは1回あたり500トークンまで
_CHUNK_SIZE = 500
# プッシュの本文は長文を載せられないので先頭だけ出し、続きはアプリで読ませる
_BODY_LIMIT = 120


def send_push(notification, users):
    """対象ユーザーの端末にプッシュ通知を送る。

    **この関数は例外を投げない。** プッシュはあくまで「気づかせる」ための
    補助であり、FCMが落ちていてもメッセージ自体は受信箱に届いている。
    送信失敗で配信APIが500を返してしまうと、スタッフには送信できたのか
    分からなくなるため、ここで吸収してログだけ残す。

    返り値は送信に成功した端末数。
    """
    try:
        tokens = list(
            FCMToken.objects.filter(user__in=users).values_list('token', flat=True)
        )
        if not tokens:
            return 0

        app = get_app()
        body = notification.body[:_BODY_LIMIT]
        success = 0

        for start in range(0, len(tokens), _CHUNK_SIZE):
            chunk = tokens[start:start + _CHUNK_SIZE]
            message = messaging.MulticastMessage(
                notification=messaging.Notification(
                    title=notification.title,
                    body=body,
                ),
                # アプリ側でタップ時に該当メッセージを開けるようにIDを載せる
                data={'notification_id': str(notification.id)},
                tokens=chunk,
            )
            response = messaging.send_each_for_multicast(message, app=app)
            success += response.success_count
            _remove_stale_tokens(chunk, response)

        return success
    except Exception:
        logger.exception(
            'FCM送信に失敗しました notification_id=%s', notification.pk
        )
        return 0


def _remove_stale_tokens(tokens, response):
    """失効したトークンを削除する。

    アプリを削除した端末や機種変更後の端末のトークンは UnregisteredError を
    返す。放置すると送信のたびに無駄な失敗が積み上がるので消しておく。
    ネットワークエラーなど一時的な失敗は消さない。
    """
    stale = [
        token
        for token, result in zip(tokens, response.responses)
        if not result.success
        and isinstance(result.exception, messaging.UnregisteredError)
    ]
    if stale:
        FCMToken.objects.filter(token__in=stale).delete()
        logger.info('失効したFCMトークンを%d件削除しました', len(stale))
