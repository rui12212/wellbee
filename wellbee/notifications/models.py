from django.conf import settings
from django.db import models


class Notification(models.Model):
    """スタッフが作成するメッセージ本体。本文はここに1行だけ保存する。"""

    TARGET_TYPE = (
        ('all', 'All Users'),
        ('course', 'Course Members'),
    )
    MEMBERSHIP_STATUS = (
        ('all', 'All'),
        ('active', 'Active'),
        ('expired', 'Expired'),
        ('none', 'No Membership'),
    )

    title = models.CharField(verbose_name='title', max_length=100)
    body = models.TextField(verbose_name='body')
    image = models.ImageField(
        verbose_name='image',
        upload_to='notifications/images/',
        blank=True,
        null=True,
    )
    # 動画は今回のスコープ外。フィールドだけ用意しておき、後から有効化しても
    # マイグレーションが不要になるようにしている。
    video = models.FileField(
        verbose_name='video',
        upload_to='notifications/videos/',
        blank=True,
        null=True,
    )
    target_type = models.CharField(
        verbose_name='target_type', max_length=10, choices=TARGET_TYPE
    )
    membership_status = models.CharField(
        verbose_name='membership_status', max_length=10, choices=MEMBERSHIP_STATUS
    )
    target_course = models.ForeignKey(
        'attendances.Course',
        verbose_name='target_course',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
    )
    # True のときはスタッフ全員にだけ配信し、target_type / membership_status /
    # target_course を一切見ない。実在の会員に影響を出さずに動作確認するための
    # 逃げ道として用意している。
    staff_only = models.BooleanField(verbose_name='staff_only', default=False)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        verbose_name='created_by',
        on_delete=models.PROTECT,
    )
    created_at = models.DateTimeField(verbose_name='created_at', auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.title} ({self.target_type}/{self.membership_status})"


class UserNotification(models.Model):
    """ユーザーごとの配信レコード。既読管理はこのテーブルが担う。"""

    notification = models.ForeignKey(
        Notification,
        verbose_name='notification',
        on_delete=models.CASCADE,
        related_name='user_notifications',
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        verbose_name='user',
        on_delete=models.CASCADE,
        related_name='notifications',
    )
    is_read = models.BooleanField(verbose_name='is_read', default=False)
    read_at = models.DateTimeField(verbose_name='read_at', null=True, blank=True)
    created_at = models.DateTimeField(verbose_name='created_at', auto_now_add=True)

    class Meta:
        # 同じメッセージが同じユーザーに二重配信されるのを DB レベルで防ぐ
        unique_together = ('notification', 'user')
        ordering = ['-created_at']
        indexes = [
            # 未読件数の取得（user と is_read での絞り込み）に効く
            models.Index(fields=['user', 'is_read']),
        ]

    def __str__(self):
        return f"{self.user} - {self.notification.title}"


class FCMToken(models.Model):
    """プッシュ通知の送信先。1ユーザーが複数端末を持つ場合があるので1対多。"""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        verbose_name='user',
        on_delete=models.CASCADE,
        related_name='fcm_tokens',
    )
    # 端末ごとに一意なトークン。機種変更や再インストールで値が変わる。
    token = models.CharField(verbose_name='token', max_length=255, unique=True)
    created_at = models.DateTimeField(verbose_name='created_at', auto_now_add=True)
    updated_at = models.DateTimeField(verbose_name='updated_at', auto_now=True)

    class Meta:
        ordering = ['-updated_at']
        indexes = [
            models.Index(fields=['user']),
        ]

    def __str__(self):
        return f"{self.user} - {self.token[:16]}..."
