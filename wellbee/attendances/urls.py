from django.urls import path
from django.conf.urls import include
from rest_framework.routers import DefaultRouter
from . views import InterviewViewSet, MembershipViewSet,AttendeeViewSet
from . views import CheckInViewSet, CourseViewSet

app_name='attendances'

router = DefaultRouter()
# ここの最後の / はいらない！エラーの元
router.register(r'membership',MembershipViewSet,basename='membership')
router.register(r'attendee',AttendeeViewSet,basename='staff-attendee')
router.register(r'interview',InterviewViewSet, basename='interview')
# router.register(r'user/attendee',MyAttendeeViewSet,basename='user-attendee')
router.register(r'checkin',CheckInViewSet,basename='staff-checkin')
# router.register(r'user/checkin',MyCheckInViewSet,basename='user-checkin')
router.register(r'course',CourseViewSet,basename='course')
# router.register(r'payment', PaymentViewSet, basename='payment')

urlpatterns=[
    # path('user/membership/', MyMembershipViewSet.as_view(), name='user-membership'),
    path('', include(router.urls))
]