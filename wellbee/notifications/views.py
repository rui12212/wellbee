from django.utils import timezone
from rest_framework import mixins, status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .delivery import count_recipients, deliver
from .models import FCMToken, Notification, UserNotification
from .permissions import IsStaffMember
from .push import send_push
from .serializers import (
    FCMTokenSerializer,
    NotificationSerializer,
    RecipientCountSerializer,
    UserNotificationSerializer,
)

# ユーザーの受信箱に一度に返す件数
MY_NOTIFICATION_LIMIT = 50


class NotificationViewSet(
    mixins.CreateModelMixin,
    mixins.ListModelMixin,
    viewsets.GenericViewSet,
):
    """スタッフ用：メッセージの作成と送信済み一覧。

    ModelViewSet を使わないのは、更新・削除の口を開けないため。送信済みの
    メッセージを後から書き換えられると、ユーザーが読んだ内容と記録が
    食い違ってしまう。
    """

    serializer_class = NotificationSerializer
    permission_classes = [IsStaffMember]

    def get_queryset(self):
        return Notification.objects.select_related(
            'target_course', 'created_by'
        ).prefetch_related('user_notifications')

    def perform_create(self, serializer):
        """保存と同時に配信する。

        post_save シグナルにしないのは、管理画面やシェルからの保存でも
        発火してしまうため。配信は意図した操作のときだけ走らせる。
        """
        notification = serializer.save(created_by=self.request.user)
        users = deliver(notification)
        # プッシュは補助。失敗しても send_push が例外を吸収するので、
        # 受信箱への配信が巻き戻ることはない。
        send_push(notification, users)

    @action(
        detail=False,
        methods=['post'],
        permission_classes=[IsStaffMember],
        url_path='recipient_count',
    )
    def recipient_count(self, request):
        """送信前に「何人に届くか」を返す。レコードは作らない。

        宛先が all / course しかなく、送信を取り消せないため、スタッフが
        送信ボタンを押す前に必ず人数を確認できるようにしている。
        """
        serializer = RecipientCountSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        count = count_recipients(
            data['target_type'],
            data['membership_status'],
            data.get('target_course'),
            data.get('staff_only', False),
        )
        return Response({'recipient_count': count})


class UserNotificationViewSet(viewsets.GenericViewSet):
    """ユーザー用：自分宛のメッセージの閲覧と既読管理。

    GenericViewSet のみを継承し、必要なアクションだけを自分で定義する。
    ModelViewSet だと他人のレコードまで更新・削除できる口が開いてしまう。
    """

    serializer_class = UserNotificationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """常にログインユーザー自身のレコードだけに絞る。

        ここで絞っておけば、get_object() も自分のものしか引けなくなるため、
        他人のメッセージを既読にするような操作は 404 になる。
        """
        return UserNotification.objects.filter(
            user=self.request.user
        ).select_related('notification', 'notification__target_course')

    @action(detail=False, methods=['get'], url_path='my_notifications')
    def my_notifications(self, request):
        notifications = self.get_queryset().order_by('-created_at')[
            :MY_NOTIFICATION_LIMIT
        ]
        serializer = self.get_serializer(notifications, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'], url_path='unread_count')
    def unread_count(self, request):
        count = self.get_queryset().filter(is_read=False).count()
        return Response({'unread_count': count})

    @action(detail=True, methods=['patch'], url_path='mark_read')
    def mark_read(self, request, pk=None):
        # get_object() は get_queryset() を通るので、他人のレコードは引けない
        user_notification = self.get_object()
        if not user_notification.is_read:
            user_notification.is_read = True
            user_notification.read_at = timezone.now()
            user_notification.save(update_fields=['is_read', 'read_at'])
        serializer = self.get_serializer(user_notification)
        return Response(serializer.data)


class FCMTokenViewSet(viewsets.GenericViewSet):
    """プッシュ通知の送信先トークンの登録・解除。"""

    serializer_class = FCMTokenSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return FCMToken.objects.filter(user=self.request.user)

    @action(detail=False, methods=['post'], url_path='register')
    def register(self, request):
        """トークンを登録する。

        token は unique なので、同じ端末を別アカウントで使った場合は
        所有者を付け替える必要がある。update_or_create で user を上書きし、
        前の所有者に誤配信しないようにしている。
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        token = serializer.validated_data['token']
        FCMToken.objects.update_or_create(
            token=token, defaults={'user': request.user}
        )
        return Response({'registered': True}, status=status.HTTP_200_OK)

    @action(detail=False, methods=['post'], url_path='unregister')
    def unregister(self, request):
        """ログアウト時にトークンを削除する。"""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        token = serializer.validated_data['token']
        # 自分のトークンだけを削除対象にする
        self.get_queryset().filter(token=token).delete()
        return Response({'unregistered': True}, status=status.HTTP_200_OK)
