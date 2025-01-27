from django.urls import path
from django.conf.urls import include
from rest_framework.routers import DefaultRouter

from versions.views import VersionViewSet

app_name = 'versions'

router = DefaultRouter()

router.register(r'version', VersionViewSet,basename='version')

urlpatterns = [
    path('', include(router.urls))
]