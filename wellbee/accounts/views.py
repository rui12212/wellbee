# import sys
# sys.path.append('/Users/rui/dev/wellbee/env_wellbee/lib/python3.9/site-packages/rest_framework')
from django.http import JsonResponse
from django.shortcuts import get_object_or_404
# from requests import Response
from rest_framework.response import Response
from rest_framework import generics, viewsets, status
from rest_framework.permissions import AllowAny

from wellbee.permissions import UserPermission
from . import serializers
from .models import User, Profile, PasswordResetToken
from . import twilio_service
from . import firebase_service
from .normalizer import normalize_phone
from rest_framework.decorators import action
from django.db.models import F
from rest_framework_simplejwt.views import TokenObtainPairView
import json
from django.contrib.auth import get_user_model
from django.core.cache import cache


# viewsでは、このクラスでデータをどのように扱うかを設定している。更新する？登録する？とかを
# serializerが入ると、そのデータのやり取りが楽になるから、噛ませている

# Userの登録をするためのView
class CreateUserView(generics.CreateAPIView):
    serializer_class = serializers.UserSerializer
    permission_classes = (AllowAny,)

# ModelViewSetlに関しては、これだけで、GET,POST,PUT,PATCH,DELETEが使えるようになる
class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class=serializers.UserSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        # if self.action == 'fetch_my_point':
        #     my_points = User.objects.all()
        #     return my_points
        if self.action == 'fetch_my_id':   
            return User.objects.get(phone_number=self.request.user.phone_number)
            # my_id = User.objects.all()
            # return my_id
        else:
            return super().get_queryset()

    @action(detail=False, methods=['get'], permission_classes=[UserPermission],url_path='my_id') 
    def fetch_my_id(self,request):
        my_data = self.get_queryset()
        my_data_serializer = serializers.UserSerializer(my_data, many=False)
        return Response(my_data_serializer.data)

        # my_data = User.objects.filter(phone_number = self.request.user.phone_number)
        # my_data_serializer = serializers.UserSerializer(my_data,many=True)
        # return Response(my_data_serializer.data)

    @action(detail=True, methods=['patch'], permission_classes=[UserPermission])
    def increase_points(self,request):
        data = self.request.data
        user_id = data.get('user_id')
        # user = self.get_object()
        user = get_object_or_404(User, id = user_id)
        serializer = self.get_serializer(user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    @action(detail=True, methods=['post'], permission_classes=[UserPermission], url_path='delete_user')
    def delete_user(self, request, pk=None):
        token = request.query_params.get('token')
        if not token:
            return Response({'error': 'Token is required'}, status=status.HTTP_400_BAD_REQUEST)
        
        user = get_object_or_404(User, pk=pk)
        #if not user.is_active:
        #    return Response({'message': 'User is already deactivated.'}, status=status.HTTP_400_BAD_REQUEST)
        
        user.delete()
        return Response({'status': 'User has been deleted.'}, status=status.HTTP_200_OK)


    
    # @csrf_exempt
    # def update_points(request, user_id):
    #     try:
    #         user =User.objects.get(id=user_id)
    #         if request.method == 'POST':
    #             data =json.loads(request.body)
    #             points_change = data.get('points_change', 0)
    #             user.points += points_change
    #             user.save()
    #             return JsonResponse({'status': 'success', 'new_points':user.points})
    #         else:
    #             return JsonResponse({'status': 'fail', 'message':'invalid request method'}, status=400)
    #     except User.DoesNotExist:
    #         return JsonResponse({'status':'fail','message':'User Does not exist'}, status =404)

        


# # Admin用。Profileの全件取得。他人を含む。登録更新削除、CRUDなんでもござれ
class ProfileViewSet(viewsets.ModelViewSet):
    queryset = Profile.objects.all()
    serializer_class = serializers.ProfileSerializer
    # permission_classes = (AllowAny,)

class StaffTokenObtainPairView(TokenObtainPairView):
    serializer_class = serializers.StaffLoginSerializer


class PasswordResetRequestView(generics.GenericAPIView):
    serializer_class = serializers.PasswordResetRequestSerializer
    permission_classes = (AllowAny,)

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        phone_number = serializer.validated_data['phone_number']
        country_code = serializer.validated_data['country_code']

        # レートリミット: 同一電話番号は1分間に1リクエストまで
        cache_key = f'pwd_reset_request_{phone_number}'
        if cache.get(cache_key):
            return Response(
                {'error': 'Please wait before requesting another OTP.'},
                status=status.HTTP_429_TOO_MANY_REQUESTS
            )

        success = twilio_service.send_otp_via_whatsapp(phone_number, country_code)
        if not success:
            return Response(
                {'error': 'Failed to send OTP. Please try again.'},
                status=status.HTTP_503_SERVICE_UNAVAILABLE
            )

        cache.set(cache_key, True, timeout=60)
        return Response({'message': 'OTP sent to your WhatsApp.'}, status=status.HTTP_200_OK)


class PasswordResetVerifyOtpView(generics.GenericAPIView):
    serializer_class = serializers.PasswordResetVerifyOtpSerializer
    permission_classes = (AllowAny,)

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        phone_number = serializer.validated_data['phone_number']
        country_code = serializer.validated_data['country_code']
        otp_code = serializer.validated_data['otp_code']

        is_valid = twilio_service.verify_otp(phone_number, country_code, otp_code)
        if not is_valid:
            return Response(
                {'error': 'Invalid or expired OTP.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        user = User.objects.get(phone_number=phone_number)
        token = PasswordResetToken.objects.create(user=user)
        return Response({'reset_token': str(token.reset_token)}, status=status.HTTP_200_OK)


class PasswordResetConfirmView(generics.GenericAPIView):
    serializer_class = serializers.PasswordResetConfirmSerializer
    permission_classes = (AllowAny,)

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        reset_token = serializer.validated_data['reset_token']
        new_password = serializer.validated_data['new_password']

        try:
            token_obj = PasswordResetToken.objects.get(reset_token=reset_token)
        except PasswordResetToken.DoesNotExist:
            return Response(
                {'error': 'Invalid or expired reset token.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if not token_obj.is_valid:
            return Response(
                {'error': 'Invalid or expired reset token.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        user = token_obj.user
        user.set_password(new_password)
        user.save()

        token_obj.is_used = True
        token_obj.save()

        return Response({'message': 'Password reset successfully.'}, status=status.HTTP_200_OK)


class PasswordResetVerifyFirebaseView(generics.GenericAPIView):
    permission_classes = (AllowAny,)
    authentication_classes = []

    def post(self, request, *args, **kwargs):
        id_token = request.data.get('firebase_id_token')
        if not id_token:
            return Response(
                {'error': 'Firebase ID token is required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        decoded = firebase_service.verify_id_token(id_token)
        if decoded is None:
            return Response(
                {'error': 'Invalid or expired Firebase token.'},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        phone_e164 = decoded.get('phone_number')
        if not phone_e164:
            return Response(
                {'error': 'No phone number associated with this token.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        phone_e164 = normalize_phone(phone_e164)

        try:
            user = User.objects.get(phone_number=phone_e164)
        except User.DoesNotExist:
            return Response(
                {'error': 'Phone number not registered.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        token = PasswordResetToken.objects.create(user=user)
        return Response({'reset_token': str(token.reset_token)}, status=status.HTTP_200_OK)


class StaffPasswordResetView(generics.GenericAPIView):
    serializer_class = serializers.StaffPasswordResetSerializer

    def post(self, request, *args, **kwargs):
        if not request.user.is_staff:
            return Response(
                {'error': 'Staff permission required.'},
                status=status.HTTP_403_FORBIDDEN
            )

        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        phone_number = serializer.validated_data['phone_number']
        new_password = serializer.validated_data['new_password']

        user = User.objects.get(phone_number=phone_number)
        user.set_password(new_password)
        user.save()

        return Response(
            {'message': 'Password reset successfully.', 'phone_number': phone_number},
            status=status.HTTP_200_OK
        )


class StaffCreateUserView(generics.GenericAPIView):
    serializer_class = serializers.StaffCreateUserSerializer

    def post(self, request, *args, **kwargs):
        if not request.user.is_staff:
            return Response(
                {'error': 'Staff permission required.'},
                status=status.HTTP_403_FORBIDDEN
            )

        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        return Response(
            {'message': 'Staff user created successfully.', 'phone_number': user.phone_number},
            status=status.HTTP_201_CREATED
        )
