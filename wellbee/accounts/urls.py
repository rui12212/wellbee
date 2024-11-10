# from rest_framework.routers import DefaultRouter
from django.urls import path
from django.conf.urls import include
from . import views
from .views import CreateUserView, ProfileViewSet, StaffTokenObtainPairView, UserViewSet,PasswordResetRequestViewSet,PasswordResetConfirmViewSet
from rest_framework import routers
# MyUserView,CreateStaffView,StaffViewSet
# from .views import ProfileViewSet
# from .views import MyProfileListView

app_name='accounts'

router=routers.DefaultRouter()
# profileというパスに対して、ProfileViewSetのViewを紐づけてあげる
router.register('profile', views.ProfileViewSet)
# router.register('users',views.UserViewSet)
router.register(r'users',UserViewSet,basename='users')
router.register(r'password-reset/request', PasswordResetRequestViewSet,basename='password_reset_request')
router.register(r'password-reset/confirm', PasswordResetConfirmViewSet,basename='password_reset_confirm')
# models.pyを参考にして、下記のurlpatternsを適切に書き換えてください



urlpatterns = [
    path('create/', CreateUserView.as_view(), name='users-create'),
    # path('update-points/<uuid:user_id>', views.update_points, name='update_points'),
    # path('user/all/',UserViewSet.as_view(), name='users-all'),
    # path('users/<pk>/retrieve/',MyUserView.as_view(), name='my-user'),
    # path('profile/<uuid:id>/',MyProfileListView.as_view(), name='users-profile'),
    path('staff_login/', views.staff_login, name='staff_login'),
    path('api/staff/token/', StaffTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('', include(router.urls)),
]