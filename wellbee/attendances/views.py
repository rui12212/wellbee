from django.conf import settings
from rest_framework import generics, viewsets, status
from rest_framework.permissions import AllowAny
from accounts.models import User
from wellbee.permissions import AttendeePermission, CheckInPermission, InterviewPermission, IsStaffUser, BasePermission, MembershipPermission
from questionnaires.models import BaseBodySurvey, SurveyResponse
from reservations.models import Reservation
from . import serializers
from rest_framework.decorators import action
from attendances.models import Course, Interview, Membership, Attendee, CheckIn
from rest_framework.response import Response
from django.db.models import F,Q
from django.db.models import OuterRef, Subquery
from django.utils import timezone
from datetime import datetime, timedelta
import pytz
from rest_framework.permissions import AllowAny
from rest_framework.exceptions import ValidationError
from django.shortcuts import get_object_or_404, render
from django.db.models import Prefetch
# admin用。削除はできないようにしたい。is_activeをFalseにする仕様にする
class MembershipViewSet(viewsets.ModelViewSet):
    queryset = Membership.objects.all()
    serializer_class = serializers.MembershipSerializer
    permission_classes = [MembershipPermission]

    def perform_create(self, serializer):
        # staff_user = request.user
        data = self.request.data
        customer_user_id = data.get('user')
        attendee_id = data.get('attendee')
        fetched_course = data.get('course')
        duration = data.get('duration')
        minus = data.get('minus')
        discount_rate=data.get('discount_rate')
        fetched_offer=data.get('offer')
        fetched_total_price=data.get('total_price')
        start_date_str = data.get('start_day')
        fetched_times = data.get('times')

        customer_user = get_object_or_404(User, id =customer_user_id)
        attendee = get_object_or_404(Attendee, id =attendee_id)
        course=get_object_or_404(Course,course_name=fetched_course)

        try:
            start_date = datetime.strptime(start_date_str,'%Y-%m-%d').date()
        except(ValueError, TypeError) as e:
            return Response(
                {'error': f'start_day\'s type is not valid:{e}'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            # add
            total_price = int(fetched_total_price)
            duration = int(duration)
            minus=int(minus)
            offer=int(fetched_offer)
            discount_rate=float(discount_rate)
            times=int(fetched_times)

        except (ValueError, TypeError) as e:
            return Response({'error': '${e}: Invalid input types.'}, status=status.HTTP_400_BAD_REQUEST)
        
        if course.is_private == False:
         membership = Membership.objects.create(
                user_id = customer_user.id,
                attendee_id=attendee.id,
                course=course,
                duration=duration,
                minus=minus,
                times=times,
                offer=offer,
                start_day=start_date,
                discount_rate=discount_rate,
                total_price = total_price,
             )
        elif course.is_private == True:
          membership = Membership.objects.create(
                user_id = customer_user.id,
                attendee_id=attendee.id,
                course=course,
                duration=duration,
                minus=minus,
                start_day=start_date,
                discount_rate=discount_rate,
                total_price = total_price,
                times=times,
                offer = offer
            )
        serializer = self.get_serializer(membership)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
 
    def get_queryset(self):
        if self.action == 'fetch_closest_membership':
            memberships = Membership.objects.all()
            return memberships
        if self.action == 'fetch_available_membership':
            memberships = Membership.objects.all()
            return  memberships
        if self.action == 'fetch_my_all_membership':
            memberships = Membership.objects.all()
            return memberships
        if self.action == 'fetch_membership_by_staff':
            memberships = Membership.objects.all()
            return memberships
        if self.action == 'fetch_course_membership':
            memberships = Membership.objects.all()
            return memberships
        if self.action == 'fetch_all_available_membership':
            memberships = Membership.objects.all()
            return memberships
        # if self.action == 'fetch_my_id':
        #     my_id = Membership.objects.all()
        else:
            return super().get_queryset()
    
    @action(detail=False, methods=['get'],permission_classes=[MembershipPermission],url_path='course_membership')
    def fetch_course_membership(self,request):
        now_utc = timezone.now()
        local_timezone = pytz.timezone('Africa/Nairobi')
        now_local = now_utc.astimezone(local_timezone)
        today_date = now_local.date()

        course_name = self.request.query_params.get('course_name')
        memberships = Membership.objects.filter(
            expire_day__gte = today_date,
            course__course_name = course_name
        ).order_by('expire_day')
        serializer = self.get_serializer(memberships,many=True)
        return Response(serializer.data)

        
    @action(detail=False, methods=['get'],permission_classes=[MembershipPermission],url_path='closest_membership')
    def fetch_closest_membership(self,request):
        now_utc = timezone.now()
        local_timezone = pytz.timezone('Africa/Nairobi')
        now_local = now_utc.astimezone(local_timezone)
        today_date = now_local.date()
        user_id = self.request.query_params.get('user_id')

        memberships = Membership.objects.filter(
            user = user_id,
            expire_day__gte = today_date,
            already_join_times__lt = F('max_join_times')
        ).order_by('expire_day').first()
        serializer = self.get_serializer(memberships)
        return Response(serializer.data)


    @action(detail=False, methods=['get'],permission_classes=[MembershipPermission],url_path='my_all_membership')
    def fetch_my_all_membership(self,request):
        now_utc = timezone.now()
        local_timezone = pytz.timezone('Africa/Nairobi')
        now_local = now_utc.astimezone(local_timezone)
        today_date = now_local.date()
        # today_hour = now_local.hour()

        memberships = Membership.objects.filter(
                user = request.user,
                is_approved = True,
                already_join_times__lte = F('max_join_times'),
                expire_day__gte = today_date
                # is_expired = False,
            ).annotate(
                attendee_name = F('attendee__name'),
                attendee_gender = F('attendee__gender'),
                attendee_birthday = F('attendee__date_of_birth'),
                course_name = F('course__course_name')
            )
        serializer = self.get_serializer(memberships, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'],permission_classes=[MembershipPermission],url_path='available_membership')
    def fetch_available_membership(self,request):
        fetched_course = self.request.query_params.get('course')
        memberships = Membership.objects.filter(
                user = request.user,
                is_approved = True,
                is_expired = False,
                course__course_name = fetched_course,
            ).annotate(
                attendee_name = F('attendee__name'),
                attendee_gender = F('attendee__gender'),
                attendee_birthday = F('attendee__date_of_birth'),
            )
        serializer = self.get_serializer(memberships, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'], permission_classes=[MembershipPermission], url_path='membership_by_staff')
    def fetch_membership_by_staff(self,request):
        user_id = self.request.query_params.get('user_id')
        memberships=Membership.objects.filter(
            user = user_id
        ).order_by('request_time').annotate(
                attendee_name = F('attendee__name'),
                attendee_gender = F('attendee__gender'),
                attendee_birthday = F('attendee__date_of_birth'),
                course_name = F('course__course_name')
            )
        serializer = self.get_serializer(memberships, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'], permission_classes=[MembershipPermission], url_path='all_available_membership')
    def fetch_all_available_membership(self, request):
        now_utc = timezone.now()
        local_timezone = pytz.timezone('Africa/Nairobi')
        now_local = now_utc.astimezone(local_timezone)
        today_date = now_local.date()
        memberships = Membership.objects.filter(
            expire_day__gte = today_date
        ).order_by('expire_day').annotate(
             attendee_name = F('attendee__name'),
                course_name = F('course__course_name')
        )
        serializer = self.get_serializer(memberships, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'], permission_classes=[MembershipPermission], url_path='all_dm_attendee')
    def fetch_all_dm_attendee(self, request):
        now_utc = timezone.now()
        local_timezone = pytz.timezone('Africa/Nairobi')
        now_local = now_utc.astimezone(local_timezone)
        today_date = now_local.date()
        memberships = Membership.objects.filter(
            expire_day__gte = today_date
        ).order_by('attendee__name').annotate(
             attendee_name = F('attendee__name'),
                course_name = F('course__course_name')
        )
        serializer = self.get_serializer(memberships, many=True)
        return Response(serializer.data)
    



class AttendeeViewSet(viewsets.ModelViewSet):
    queryset=Attendee.objects.all()
    serializer_class=serializers.AttendeeSerializer
    # permission_classes = [AttendeePermission]

    def get_queryset(self):
        if self.action == 'fetch_my_attendee':
            attendee = Attendee.objects.all()
            return attendee
        elif self.action == 'fetch_attendee_by_staff':
            attendee = Attendee.objects.all()
            return attendee
        elif self.action == 'fetch_first_page_attendee':
            attendee = Attendee.objects.all()
            return attendee
        elif self.action == 'fetch_first_attendee':
            attendee = Attendee.objects.all()
            return attendee
        elif self.action == 'fetch_attendee_health_survey':
            attendee= Attendee.objects.all()
        else:
            return Attendee.objects.all()
        
    @action(detail=False, methods=['get'], url_path='first_attendee',permission_classes=[AllowAny])
    def fetch_first_attendee(self,request):
       user_id = self.request.query_params.get('user_id')
       attendees=Attendee.objects.filter(user = user_id).annotate(
            user_phone = F('user__phone_number')
        ).order_by('created_date').first()
       serializer = self.get_serializer(attendees)
       return Response(serializer.data,status=status.HTTP_200_OK)
        
        
    @action(detail=False, methods=['get'],url_path='first_page_attendee', permission_classes = [AllowAny])
    def fetch_first_page_attendee(self, request):
        attendees = Attendee.objects.filter(user=request.user)
        serializer = self.get_serializer(attendees, many=True)
        return Response(serializer.data,status=status.HTTP_200_OK)
        
    
    @action(detail=False, methods=['get'],url_path='my_attendee')
    def fetch_my_attendee(self, request):
        latest_survey = BaseBodySurvey.objects.filter(
            attendee__user = request.user
        ).order_by('-created_at').values('created_at')[:1]
        attendees = Attendee.objects.filter(user=request.user).annotate(
            latest_survey_date=Subquery(latest_survey),
            # user_id = F('user__id'),
            points = F('user__points'),
        )
        serializer = self.get_serializer(attendees, many=True)
        return Response(serializer.data,status=status.HTTP_200_OK)
    
    
    @action(detail=False, methods=['get'], url_path='attendee_by_staff')
    def fetch_attendee_by_staff(self,request):
        user_id = self.request.query_params.get('user_id')
        # token = self.request.query_params.get('token')
        attendees=Attendee.objects.filter(user = user_id).annotate(
            user_phone = F('user__phone_number')
        )
        serializer = self.get_serializer(attendees, many=True)
        return Response(serializer.data,status=status.HTTP_200_OK)

    def perform_create(self,serializer):
        my_attendee_count = Attendee.objects.filter(user=self.request.user).count()
        if my_attendee_count >=10:
            raise ValidationError('You have reach the maximum number of Member')
        else:
         serializer.save(user=self.request.user)

    # 更新処理
    @action(detail=True, methods=['patch'], url_path='partial_update', permission_classes=[AttendeePermission])
    def custom_partial_update(self,request):
        attendee = self.get_object()
        serializer = self.get_serializer(attendee, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    @action(detail=False, methods=['get'], url_path='attendee_health_survey', permission_classes=[AttendeePermission])
    def fetch_attendee_health_survey(self,request):
        today = timezone.now().date()
        active_memberships = Membership.objects.filter(
            expire_day__gte = today
        ).order_by('expire_day')

        attendees =  Attendee.objects.filter(
            membership__expire_day__gte = today
        ).prefetch_related(
            Prefetch('membership_set', queryset=active_memberships)
        ).distinct()
        serializer = serializers.AttendeeSerializer(attendees, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
        
    
class InterviewViewSet(viewsets.ModelViewSet):
    queryset=Interview.objects.all()
    serializer_class=serializers.InterviewSerializer
    permission_classes = [InterviewPermission]

    def get_queryset(self):
        if self.action == 'fetch_interview_by_staff':
            interview = Interview.objects.all()
        else:
            return Interview.objects.all()
        
    def perform_create(self,serializer):
        data = self.request.data

        fetched_attendee_id = data.get('attendee_id')
        fetched_emotion_state = data.get('emotion_state')
        fetched_physical_state = data.get('physical_state')
        fetched_any_comment = data.get('any_comment')
        if fetched_any_comment =='':
            fetched_any_comment = None
        
        attendee_id = get_object_or_404(Attendee, id = fetched_attendee_id)

        interview = Interview.objects.create(
            attendee = attendee_id,
            emotion_state = fetched_emotion_state,
            physical_state = fetched_physical_state,
            any_comment = fetched_any_comment,
        )
        serializer = self.get_serializer(interview)
        return Response(serializer.data, status=status.HTTP_201_CREATED)


    @action(detail=False, methods=['get'], url_path='interview_by_staff')
    def fetch_interview_by_staff(self,request):
        attendee_id = self.request.query_params.get('attendee_id')
        attendees=Interview.objects.filter(attendee = attendee_id).annotate(
            attendee_name = F('attendee__name'),
            user_id = F('attendee__user__id')
        )
        serializer = self.get_serializer(attendees, many=True)
        return Response(serializer.data,status=status.HTTP_200_OK)
    

class CheckInViewSet(viewsets.ModelViewSet):
    queryset = CheckIn.objects.all()
    serializer_class = serializers.CheckInSerializer
    permission_classes = [CheckInPermission]

    # def get_queryset(self):
    #      if self.action == 'fetch_staff_checkin':
    #         check_in = CheckIn.objects.all()
    #         return check_in
         
    # @action(detail=False,methods=['get'],url_path='staff_checkin')
    # def fetch_staff_checkin(self,request):
    #     user_id = self.request.query_params.get('user_id')
    #     last_checkin = CheckIn.objects.filter(
    #         reservation__membership__user = user_id
    #     ).reverse().first()
    #     serializer = self.get_serializer(last_checkin)
    #     return Response(serializer.data,status=status.HTTP_200_OK)
    

    def perform_create(self, serializer):
       data = self.request.data
       checked_user = self.request.user
       fetch_reservation = data.get('reservation')
       fetched_num_person = data.get('num_person')

       reservation_id = get_object_or_404(Reservation,id=fetch_reservation)

    #    my_overlap_checkin = CheckIn.objects.filter(
    #        reservation = fetch_reservation
    #    )
    #    if my_overlap_checkin.exists():
    #     raise ValidationError('Same reservation already exists')

       check_in = CheckIn.objects.create(
           reservation = reservation_id,
           checked_by = checked_user,
           num_person = fetched_num_person,
       )
       serializer = self.get_serializer(check_in)
       return Response(serializer.data, status=status.HTTP_201_CREATED)


    def destroy(self, request, *args,**kwargs):
        response={'messages': 'Deleting is not allowed!'}
        return Response(response, status=status.HTTP_400_BAD_REQUEST)


# class MyCheckInViewSet(viewsets.ModelViewSet):
#     queryset = CheckIn.objects.all()
#     serializer_class = serializers.CheckInSerializer

#     @action(detail=True)
#     def perform_create(self, serializer):
#         serializer.save(user_id=self.request.user.id)

#     @action(detail=True)
#     def get_queryset(self):
#         # このuserProfileの中には自分のid情報が入っているから、ここに合うもののみ持ってこれる＋情報の変更ができる
#         return self.queryset.filter(user_id=self.request.user.id)
    
#     def destroy(self, request, *args,**kwargs):
#         response={'messages': 'Deleting is not allowed!'}
#         return Response(response, status=status.HTTP_400_BAD_REQUEST)
    
#     def update(self, request, *args,**kwargs):
#         response={'messages': 'Updating this data is not allowed!'}
#         return Response(response, status=status.HTTP_400_BAD_REQUEST)

class CourseViewSet(viewsets.ModelViewSet):
    queryset = Course.objects.all()
    serializer_class = serializers.CourseSerializer
    # permission_classes=[IsStaffUser]

    def get_queryset(self):
        return self.queryset.order_by('course_name')
    
    def perform_create(self, serializer):
        serializer.save(self)


    
# class PaymentViewSet(viewsets.ModelViewSet):
#     queryset = Payment.objects.all()
#     serializer_class = serializers.PaymentSerializer