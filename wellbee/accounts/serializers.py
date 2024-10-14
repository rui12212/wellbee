from django.contrib.auth import get_user_model
from .models import User, Profile
# env_wellbee/lib/python3.9/site-packages/rest_framework
# /Users/rui/dev/wellbee/env_wellbee/lib/python3.9/site-packages/rest_framework/__init__.py
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields=('id', 'phone_number','password','points')
        extra_kwargs= {'password': {'write_only': True}}
    
    def create(self,validated_data):
        user = get_user_model().objects.create_user(**validated_data)
        return user


class ProfileSerializer(serializers.ModelSerializer):
    created_on = serializers.DateTimeField(format="%Y-%m-%d", read_only=True)
    # updated_at = serializers.DateTimeField(format="%Y-%m-%d", read_only=True)
    class Meta:
        model=Profile
        fields = ('id', 'userProfile','user_name','gender','created_on','date_of_birth')
        extra_kwargs = {'userProfile': {'read_only': True}}

class StaffTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        data = super().validate(attrs)
        if not self.user.is_staff:
            raise serializers.ValidationError('User is not a staff')
        return  data
