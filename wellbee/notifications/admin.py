from django.contrib import admin

from .models import FCMToken, Notification, UserNotification


class NotificationAdmin(admin.ModelAdmin):
    list_display = [
        'title',
        'target_type',
        'membership_status',
        'target_course',
        'delivered_count',
        'created_by',
        'created_at',
    ]
    list_filter = ['target_type', 'membership_status', 'created_at']
    search_fields = ['title', 'body']
    readonly_fields = ['created_by', 'created_at']

    @admin.display(description='delivered')
    def delivered_count(self, obj):
        return obj.user_notifications.count()

    def has_add_permission(self, request):
        # 配信は perform_create を通して行う。管理画面から作ると配信処理が
        # 走らず、宛先ゼロのメッセージが残るだけになるため作成を禁止する。
        return False


class UserNotificationAdmin(admin.ModelAdmin):
    list_display = ['user', 'notification', 'is_read', 'read_at', 'created_at']
    list_filter = ['is_read', 'created_at']
    search_fields = ['user__phone_number', 'notification__title']
    readonly_fields = ['notification', 'user', 'created_at']

    def has_add_permission(self, request):
        return False


class FCMTokenAdmin(admin.ModelAdmin):
    list_display = ['user', 'token', 'updated_at']
    search_fields = ['user__phone_number', 'token']
    readonly_fields = ['created_at', 'updated_at']


admin.site.register(Notification, NotificationAdmin)
admin.site.register(UserNotification, UserNotificationAdmin)
admin.site.register(FCMToken, FCMTokenAdmin)
