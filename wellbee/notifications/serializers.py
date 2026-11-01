from rest_framework import serializers

from .models import FCMToken, Notification, UserNotification


class NotificationSerializer(serializers.ModelSerializer):
    """スタッフがメッセージを作成・一覧する用。"""

    course_name = serializers.CharField(
        source='target_course.course_name', read_only=True
    )
    image_url = serializers.SerializerMethodField()
    delivered_count = serializers.IntegerField(
        source='user_notifications.count', read_only=True
    )

    class Meta:
        model = Notification
        fields = (
            'id',
            'title',
            'body',
            'image',
            'image_url',
            'target_type',
            'membership_status',
            'target_course',
            'course_name',
            'staff_only',
            'delivered_count',
            'created_at',
        )
        extra_kwargs = {
            'id': {'read_only': True},
            'created_at': {'read_only': True},
            # 画像はPOST時に受け取るが、レスポンスでは image_url を使う
            'image': {'write_only': True, 'required': False},
        }

    def get_image_url(self, obj):
        """R2に保存された画像のフルURLを返す。"""
        if obj.image:
            return obj.image.url
        return None

    def validate(self, data):
        # スタッフ限定の送信は他の条件を一切見ないので、組み合わせの検証も不要
        if data.get('staff_only'):
            return data

        target_type = data.get('target_type')
        membership_status = data.get('membership_status')
        target_course = data.get('target_course')

        if target_type == 'course':
            if not target_course:
                raise serializers.ValidationError(
                    {'target_course': 'コースを指定してください。'}
                )
            if membership_status == 'none':
                raise serializers.ValidationError(
                    {
                        'membership_status':
                            'コース指定と「メンバーシップなし」は組み合わせられません。'
                    }
                )
        elif target_type == 'all' and target_course:
            # 全員宛なのにコースが入っていたら、取り違えの可能性が高いので弾く
            raise serializers.ValidationError(
                {'target_course': '全員宛ではコースを指定できません。'}
            )

        return data


class RecipientCountSerializer(serializers.Serializer):
    """送信前の人数確認用。レコードは作らないので ModelSerializer ではない。"""

    target_type = serializers.ChoiceField(choices=Notification.TARGET_TYPE)
    membership_status = serializers.ChoiceField(
        choices=Notification.MEMBERSHIP_STATUS
    )
    target_course = serializers.IntegerField(required=False, allow_null=True)
    staff_only = serializers.BooleanField(required=False, default=False)

    def validate(self, data):
        if data.get('staff_only'):
            return data

        if data.get('target_type') == 'course':
            if not data.get('target_course'):
                raise serializers.ValidationError(
                    {'target_course': 'コースを指定してください。'}
                )
            if data.get('membership_status') == 'none':
                raise serializers.ValidationError(
                    {
                        'membership_status':
                            'コース指定と「メンバーシップなし」は組み合わせられません。'
                    }
                )
        return data


class UserNotificationSerializer(serializers.ModelSerializer):
    """ユーザーが自分宛のメッセージを閲覧する用。"""

    title = serializers.CharField(source='notification.title', read_only=True)
    body = serializers.CharField(source='notification.body', read_only=True)
    image_url = serializers.SerializerMethodField()
    course_name = serializers.CharField(
        source='notification.target_course.course_name', read_only=True
    )
    notification_created_at = serializers.DateTimeField(
        source='notification.created_at', read_only=True
    )

    class Meta:
        model = UserNotification
        fields = (
            'id',
            'title',
            'body',
            'image_url',
            'course_name',
            'is_read',
            'read_at',
            'notification_created_at',
            'created_at',
        )

    def get_image_url(self, obj):
        if obj.notification.image:
            return obj.notification.image.url
        return None


class FCMTokenSerializer(serializers.ModelSerializer):
    """プッシュ通知の送信先トークン登録用。"""

    class Meta:
        model = FCMToken
        fields = ('token',)
