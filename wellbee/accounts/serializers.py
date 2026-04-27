import logging
from django.contrib.auth import get_user_model
from .models import User, Profile
from .normalizer import normalize_phone
from rest_framework import serializers
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth.password_validation import validate_password

logger = logging.getLogger(__name__)

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

class StaffLoginSerializer(serializers.Serializer):
    """Staffログイン専用。phone_number + password を検証し、is_staffユーザー
    のみ JWT (access/refresh) を発行する。simplejwtのTokenObtainPairSerializer
    を継承せず、独自にユーザー検索→パスワード照合→ステータス確認→トークン発行を行う。
    """

    phone_number = serializers.CharField(max_length=16)
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        phone_number = normalize_phone(attrs.get('phone_number'))
        password = attrs.get('password')

        try:
            user = User.objects.get(phone_number=phone_number)
        except User.DoesNotExist:
            logger.warning(
                'Staff login failed: user not found phone=%s', phone_number,
            )
            raise serializers.ValidationError(
                {'detail': 'User with this phone number does not exist.'}
            )

        if not user.check_password(password):
            logger.warning(
                'Staff login failed: invalid password phone=%s', phone_number,
            )
            raise serializers.ValidationError(
                {'detail': 'Invalid password.'}
            )

        if not user.is_active:
            logger.warning(
                'Staff login failed: inactive account phone=%s', phone_number,
            )
            raise serializers.ValidationError(
                {'detail': 'Account is not active.'}
            )

        if not user.is_staff:
            logger.warning(
                'Staff login failed: not staff phone=%s', phone_number,
            )
            raise serializers.ValidationError(
                {'detail': 'User is not a staff member.'}
            )

        refresh = RefreshToken.for_user(user)
        return {
            'access': str(refresh.access_token),
            'refresh': str(refresh),
        }
    
class PasswordResetRequestSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=16)
    country_code = serializers.CharField(max_length=8)

    def validate_phone_number(self, value):
        normalized = normalize_phone(value)
        if not User.objects.filter(phone_number=normalized).exists():
            raise serializers.ValidationError('User with this phone number does not exist.')
        return normalized


class PasswordResetVerifyOtpSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=16)
    country_code = serializers.CharField(max_length=8)
    otp_code = serializers.CharField(max_length=6)

    def validate_phone_number(self, value):
        normalized = normalize_phone(value)
        if not User.objects.filter(phone_number=normalized).exists():
            raise serializers.ValidationError('User with this phone number does not exist.')
        return normalized


class PasswordResetConfirmSerializer(serializers.Serializer):
    reset_token = serializers.UUIDField()
    new_password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    confirm_password = serializers.CharField(write_only=True, required=True)

    def validate(self, attrs):
        if attrs['new_password'] != attrs['confirm_password']:
            raise serializers.ValidationError({'confirm_password': 'Passwords do not match.'})
        return attrs


class StaffPasswordResetSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=16)
    new_password = serializers.CharField(write_only=True, required=True, validators=[validate_password])

    def validate_phone_number(self, value):
        normalized = normalize_phone(value)
        if not User.objects.filter(phone_number=normalized).exists():
            raise serializers.ValidationError('User with this phone number does not exist.')
        return normalized


class StaffCreateUserSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=16)
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])

    def validate_phone_number(self, value):
        normalized = normalize_phone(value)
        if User.objects.filter(phone_number=normalized).exists():
            raise serializers.ValidationError('User with this phone number already exists.')
        return normalized

    def create(self, validated_data):
        user = get_user_model().objects.create_user(
            phone_number=validated_data['phone_number'],
            password=validated_data['password'],
        )
        user.is_staff = True
        user.is_active = True
        user.save()
        return user
