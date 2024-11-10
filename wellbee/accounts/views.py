# import sys
# sys.path.append('/Users/rui/dev/wellbee/env_wellbee/lib/python3.9/site-packages/rest_framework')
from django.http import JsonResponse
from django.shortcuts import get_object_or_404
# from requests import Response
from rest_framework.response import Response
from rest_framework import generics, viewsets, status
from rest_framework.permissions import AllowAny

from accounts.forms import StaffLoginForm
from wellbee.permissions import UserPermission
from . import serializers
from .models import User, Profile
from django.views.generic import ListView
from rest_framework.decorators import action
from django.db.models import F
from django.contrib.auth import authenticate, login
from django.shortcuts import render, redirect
from django.views.decorators.csrf import csrf_exempt
from rest_framework_simplejwt.views import TokenObtainPairView
import json
from django.contrib.auth import get_user_model


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
    serializer_class = serializers.StaffTokenObtainPairSerializer

@csrf_exempt
def staff_login(request):
    if request.method == "POST":
        form = StaffLoginForm(request.POST)
        if form.is_valid():
            phone_number = form.cleaned_data['phone_number']
            password = form.cleaned_data['password']
            user = authenticate(request, phone_number=phone_number, password=password)

            if user is not None and user.is_staff:
                login(request, user)
                return JsonResponse({'success':True, 'message':'Sign in success', 'redirect_url':'/staff_home/'})
            else:
                return JsonResponse({'success':False,'message': "Invalid credentials or not a staff member"})
        else:
            return JsonResponse({'success':False, 'message':'Form data is not valid'})
    else:
        return JsonResponse({'success':False, 'message': 'Invalid request method'})
    
class PasswordResetRequestViewSet(viewsets.ModelViewSet):
    serializer_class = serializers.PasswordResetRequestSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        return Response({'message': 'User confirmed. Reset password'}, status=status.HTTP_200_OK)
    
class PasswordResetConfirmViewSet(viewsets.ModelViewSet):
    serializer_class = serializers.PasswordResetSerializer

    def post(self, request, *args, **kwargs):
        phone_number = request.data.get('phone_number')
        secret_words = request.data.get('secret_words')
        new_password = request.data.get('new_password')

        try:
            user = User.objects.get(phone_number=phone_number, secret_words=secret_words)
            user.set_password(new_password)
            user.save()
            return Response({"message": "Password reset successfully"}, status=status.HTTP_200_OK)
        except User.DoesNotExist:
            return Response({"error": "Phone number or secret words is not correct"}, status=status.HTTP_400_BAD_REQUEST)
