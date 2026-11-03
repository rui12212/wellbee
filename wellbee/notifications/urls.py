from django.conf.urls import include
from django.urls import path
from rest_framework.routers import DefaultRouter

from .views import FCMTokenViewSet, NotificationViewSet, UserNotificationViewSet

app_name = 'notifications'

router = DefaultRouter()
# 末尾に / を付けないこと（既存アプリと同じ。付けるとルーティングが壊れる）
router.register(r'notification', NotificationViewSet, basename='notification')
router.register(
    r'user_notification', UserNotificationViewSet, basename='user-notification'
)
router.register(r'fcm_token', FCMTokenViewSet, basename='fcm-token')

urlpatterns = [
    path('', include(router.urls)),
]
