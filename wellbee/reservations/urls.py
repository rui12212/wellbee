from django.urls import path
from django.conf.urls import include
from rest_framework.routers import DefaultRouter
from . views import ReservationViewSet,SlotViewSet

app_name='reservations'

router = DefaultRouter()
# ここの最後の / はいらない！エラーの元
router.register(r'slot',SlotViewSet,basename='slot')
router.register(r'reservation',ReservationViewSet,basename='reservation')

urlpatterns=[
    # path('user/membership/', MyMembershipViewSet.as_view(), name='user-membership'),
    path('', include(router.urls))
]