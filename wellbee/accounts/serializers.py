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
        fields=('id', 'phone_number','password','points',)
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
    
class PasswordResetRequestSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=11)
    country_code = serializers.CharField(max_length=8)

    def validate_phone_number(self, value):
        if not User.objects.filter(phone_number=value).exists():
            raise serializers.ValidationError('User with this phone number does not exist.')
        return value


class PasswordResetVerifyOtpSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=11)
    country_code = serializers.CharField(max_length=8)
    otp_code = serializers.CharField(max_length=6)

    def validate_phone_number(self, value):
        if not User.objects.filter(phone_number=value).exists():
            raise serializers.ValidationError('User with this phone number does not exist.')
        return value


class PasswordResetConfirmSerializer(serializers.Serializer):
    reset_token = serializers.UUIDField()
    new_password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    confirm_password = serializers.CharField(write_only=True, required=True)

    def validate(self, attrs):
        if attrs['new_password'] != attrs['confirm_password']:
            raise serializers.ValidationError({'confirm_password': 'Passwords do not match.'})
        return attrs


class StaffPasswordResetSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=11)
    new_password = serializers.CharField(write_only=True, required=True, validators=[validate_password])

    def validate_phone_number(self, value):
        if not User.objects.filter(phone_number=value).exists():
            raise serializers.ValidationError('User with this phone number does not exist.')
        return value
