from django.shortcuts import render
from rest_framework import generics, viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action
from . import serializers
from versions.models import Version
from wellbee.permissions import VersionPermission

class VersionViewSet(viewsets.ModelViewSet):
    serializer_class = serializers.VersionSerializer
    def get_queryset(self):
        if self.action == 'fetch_latest_version':
            versions = Version.objects.all()
            return versions
        else:
            return super().get_queryset()
        
    @action(detail=False, methods=['get'],permission_classes=[VersionPermission], url_path='latest_version')
    def fetch_latest_version(self,request):
        version = Version.objects.order_by('created_date').reverse().first()
        serializer = self.get_serializer(version)
        return Response(serializer.data)