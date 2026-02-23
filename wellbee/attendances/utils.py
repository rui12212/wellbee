from attendances.models import UserFCMToken


def send_push_notification(user_ids, title, body):
    """
    指定されたUserにFCMプッシュ通知を送信
    """
    try:
        from firebase_admin import messaging
    except ImportError:
        print('firebase-admin is not installed. Skipping push notification.')
        return 0

    tokens = list(
        UserFCMToken.objects.filter(
            user_id__in=user_ids,
            is_active=True
        ).values_list('token', flat=True)
    )

    if not tokens:
        return 0

    # FCMは1回のマルチキャストで最大500トークンまで
    batch_size = 500
    total_success = 0

    for i in range(0, len(tokens), batch_size):
        batch_tokens = tokens[i:i + batch_size]
        message = messaging.MulticastMessage(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            tokens=batch_tokens,
        )
        try:
            response = messaging.send_each_for_multicast(message)
            total_success += response.success_count

            # 無効なトークンを無効化
            for idx, send_response in enumerate(response.responses):
                if send_response.exception is not None:
                    failed_token = batch_tokens[idx]
                    UserFCMToken.objects.filter(token=failed_token).update(is_active=False)
        except Exception as e:
            print(f'FCM batch send error: {e}')

    return total_success
