from django.contrib.auth import get_user_model
from .models import User, Profile
# env_wellbee/lib/python3.9/site-packages/rest_framework
# /Users/rui/dev/wellbee/env_wellbee/lib/python3.9/site-packages/rest_framework/__init__.py
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.contrib.auth.password_validation import validate_password

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields=('id', 'phone_number','password','points','is_active')
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
    
class PasswordResetRequestSerializer(serializers.ModelSerializer):
    phone_number = serializers.CharField(max_length=11)
    secret_words = serializers.CharField()

    def validate(self,attrs):
        phone_number = attrs.get('phone_number')
        secret_words = attrs.get('secret_words')
        try:
            user = User.objects.get(phone_number=phone_number, secret_words=secret_words)
        except User.DoesNotExist:
            raise serializers.ValidationError('phone number or secret words is not correct')
        attrs['user'] = user
        return attrs
    
class PasswordResetSerializer(serializers.ModelSerializer):
    new_password = serializers.CharField(write_only=True,required=True, validators=[validate_password])
    confirm_password = serializers.CharField(write_only=True,required=True)

    def validate(self,attrs):
        if attrs['new_password'] !=attrs['confirm_password']:
            raise serializers.ValidationError({'password':'password does not match'})
        return attrs
