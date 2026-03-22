from django.urls import path
from django.conf.urls import include
from . import views
from .views import (
    CreateUserView,
    ProfileViewSet,
    StaffTokenObtainPairView,
    UserViewSet,
    PasswordResetRequestView,
    PasswordResetVerifyOtpView,
    PasswordResetConfirmView,
    StaffPasswordResetView,
)
from rest_framework import routers

app_name = 'accounts'

router = routers.DefaultRouter()
router.register('profile', views.ProfileViewSet)
router.register(r'users', UserViewSet, basename='users')

urlpatterns = [
    path('create/', CreateUserView.as_view(), name='users-create'),
    path('staff_login/', views.staff_login, name='staff_login'),
    path('api/staff/token/', StaffTokenObtainPairView.as_view(), name='token_obtain_pair'),

    # パスワードリセット（一般ユーザー・認証不要）
    path('password-reset/request/', PasswordResetRequestView.as_view(), name='password_reset_request'),
    path('password-reset/verify-otp/', PasswordResetVerifyOtpView.as_view(), name='password_reset_verify_otp'),
    path('password-reset/confirm/', PasswordResetConfirmView.as_view(), name='password_reset_confirm'),

    # パスワードリセット（スタッフ手動・JWT認証必須）
    path('staff/password-reset/', StaffPasswordResetView.as_view(), name='staff_password_reset'),

    path('', include(router.urls)),
]
