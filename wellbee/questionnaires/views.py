from django.forms import ValidationError
from django.utils import timezone
from django.shortcuts import get_object_or_404
from rest_framework import generics, viewsets, status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from attendances.models import Attendee
from wellbee.permissions import BaseBodySurveyPermission, SurveyResponsePermission
from . import serializers
from .models import BaseBodySurvey, SurveyResponse
from rest_framework.decorators import action


# ModelViewSetlに関しては、これだけで、GET,POST,PUT,PATCH,DELETEが使えるようになる
class BaseBodySurveyViewSet(viewsets.ModelViewSet):
    queryset = BaseBodySurvey.objects.all()
    serializer_class=serializers.BaseBodySurveySerializer
    permission_classes = [BaseBodySurveyPermission]

    def get_queryset(self):
        if self.action == 'fetch_my_bmi':
            # my_survey = BaseBodySurvey.objects.all()
            my_survey = SurveyResponse.objects.filter(
                attendee__user = self.request.user,
            ).order_by('created_at')
            return my_survey
        if self.action == 'fetch_staff_bmi':
            user_id = self.request.query_params.get('id')
            staff_bmi = BaseBodySurvey.objects.filter(
                attendee_id = user_id
            )
            return staff_bmi
        return super().get_queryset()
    
    def perform_create(self, serializer):
        # リクエストデータから 'attendee_id' を取得
        attendee_id = self.request.data.get('attendee_id')
        if not attendee_id:
            raise ValidationError({"attendee_id": "This field is required."})
        # 'attendee_id' に対応する Attendee オブジェクトを取得
        try:
            attendee = Attendee.objects.get(id=attendee_id)
        except Attendee.DoesNotExist:
            raise ValidationError({"attendee_id": "Invalid attendee_id."})
        # シリアライザーに 'attendee' を設定して保存
        serializer.save(attendee=attendee)

    
    @action(detail=False, methods=['get'], permission_classes=[BaseBodySurveyPermission], url_path='my_bmi')
    def fetch_my_bmi(self,request):
       user = request.user
       attendee_name = self.request.query_params.get('attendee_name')
       if user.is_authenticated:
           my_survey = BaseBodySurvey.objects.filter(
               attendee__user = request.user,
               attendee__name = attendee_name
           ).order_by('created_at')
           serializer = self.get_serializer(my_survey, many=True)
           return Response(serializer.data)
       return super().get_queryset()
    
    @action(detail=False, methods=['get'], permission_classes=[BaseBodySurveyPermission], url_path='staff_bmi')
    def fetch_staff_bmi(self,request):
      staff_bmi = self.get_queryset()
      staff_bmi_serializer = serializers.BaseBodySurveySerializer(staff_bmi,many=True)
      return Response(staff_bmi_serializer.data)
       

class SurveyResponseViewSet(viewsets.ModelViewSet):
    queryset = SurveyResponse.objects.all()
    serializer_class=serializers.SurveyResponseSerializer
    permission_classes = [SurveyResponsePermission]

    def get_queryset(self):
        if self.action == 'fetch_my_survey':
            my_survey = SurveyResponse.objects.all()
            my_survey = SurveyResponse.objects.filter(
                attendee__user = self.request.user,
            ).order_by('created_at')
            return my_survey
        if self.action == 'fetch_last_survey':
            attendee_last_survey = SurveyResponse.objects.all()
            return attendee_last_survey
        if self.action == 'fetch_staff_survey':
            staff_survey = SurveyResponse.objects.all()
            return staff_survey
        return super().get_queryset()
    
    def perform_create(self, serializer):
        # リクエストデータから 'attendee_id' を取得
        attendee_id = self.request.data.get('attendee_id')
        if not attendee_id:
            raise ValidationError({"attendee_id": "This field is required."})
        # 'attendee_id' に対応する Attendee オブジェクトを取得
        try:
            attendee = Attendee.objects.get(id=attendee_id)
        except Attendee.DoesNotExist:
            raise ValidationError({"attendee_id": "Invalid attendee_id."})
        # シリアライザーに 'attendee' を設定して保存
        serializer.save(attendee=attendee)

    
    @action(detail=False, methods=['get'], permission_classes=[SurveyResponsePermission], url_path='my_survey')
    def fetch_my_survey(self,request):
       user = request.user
       attendee_name = self.request.query_params.get('attendee_name')
       if user.is_authenticated:
           my_survey = SurveyResponse.objects.filter(
               attendee__user = request.user,
               attendee__name = attendee_name
           ).order_by('created_at')
           serializer = self.get_serializer(my_survey, many=True)
           return Response(serializer.data)
       return super().get_queryset()
    
    @action(detail=False, methods=['get'], permission_classes=[SurveyResponsePermission], url_path='staff_survey')
    def fetch_staff_survey(self,request):
        user_id = self.request.query_params.get('id')
        staff_survey = SurveyResponse.objects.filter(attendee_id=user_id).order_by('created_at')
        serializer = self.get_serializer(staff_survey, many=True)
        return Response(serializer.data)

    
    # @action(detail=False, methods=['get'], permission_classes=[SurveyResponsePermission], url_path='attendee_last_survey')
    # def fetch_my_survey(self,request):
    #    user = request.user
    #    attendee_name = self.request.query_params.get('attendee_name')
    #    if user.is_authenticated:
    #        my_survey = SurveyResponse.objects.filter(
    #            attendee__user = request.user,
    #            attendee__name = attendee_name
    #        ).order_by('created_at')
    #        serializer = self.get_serializer(my_survey, many=True)
    #        return Response(serializer.data)
    #    return super().get_queryset()
       