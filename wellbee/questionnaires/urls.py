from django.urls import path
from django.conf.urls import include
from rest_framework.routers import DefaultRouter
from . views import BaseBodySurveyViewSet, SurveyResponseViewSet

app_name='questionnaires'

router = DefaultRouter()
router.register(r'base_body_survey',BaseBodySurveyViewSet,basename='base_body_survey')
router.register(r'survey_response', SurveyResponseViewSet, basename='survey')

urlpatterns=[
    # path('user/membership/', MyMembershipViewSet.as_view(), name='user-membership'),
    path('', include(router.urls))
]