from datetime import datetime
import json
from typing import List
from rest_framework.exceptions import ValidationError
from django.http import JsonResponse
from django.utils import timezone
from django.shortcuts import get_object_or_404, render

# Create your views here.
from rest_framework import generics, viewsets, status
from rest_framework.permissions import AllowAny
from wellbee.permissions import IsStaffUser, BasePermission, ReservationPermission, SlotPermission
from . import serializers
from rest_framework.decorators import action
from reservations.models import Slot, Reservation
from attendances.models import Course, Membership
from rest_framework.response import Response
from django.db.models import F,Q
from django.utils.dateparse import parse_date
from django.views.decorators.csrf import csrf_exempt
from django.utils.timezone import make_aware
from datetime import timedelta
import pytz
from dateutil.relativedelta import relativedelta

now_utc = timezone.now()
local_timezone = pytz.timezone('Africa/Nairobi')
now_local = now_utc.astimezone(local_timezone)
today_date = now_local.date()
today_hour = now_local.time()

# admin用。削除はできないようにしたい。is_activeをFalseにする仕様にする
class SlotViewSet(viewsets.ModelViewSet):
    queryset = Slot.objects.all()
    serializer_class = serializers.SlotSerializer
    
    def get_queryset(self):
        start_date = today_date - relativedelta(months=1)
        end_date = today_date + relativedelta(years=1)

        if self.action == 'fetch_all_slots':
            slots = Slot.objects.filter(
              date__gte = start_date,
              date__lte = end_date,
            ).order_by('date', 'start_time')
            
            return slots

        if self.action =='fetch_slots_for_calendar':
            
            date_str = self.request.query_params.get('date')
            if isinstance(date_str, (tuple, list)):
                date_str = date_str[0]  # 最初の要素を取得

            try:
              query_date = datetime.strptime(date_str, '%Y-%m-%d').date()
            except ValueError:
              return Slot.objects.none()
            
            slots = Slot.objects.filter(
                  date = query_date,
                  ).order_by('course__course_name','start_time')
            return slots

        if self.action == 'fetch_course_slots_for_staff':
            course_name = self.request.query_params.get('course_name')
            date = self.request.query_params.get('date')
            slots = Slot.objects.filter(course__course_name = course_name, date = date).order_by('date','start_time')
            return slots
        
        if self.action == 'fetch_each_course_slots':
            course_name = self.request.query_params.get('course_name')
            slots = Slot.objects.filter(course__course_name = course_name).order_by('date','start_time')
            return slots

        if self.action == 'fetch_course_slots':
          

          course_name = self.request.query_params.get('course_name')
           # dateパラメータを取得してタプルではなく文字列で扱う
          date_str = self.request.query_params.get('date')
          if isinstance(date_str, (tuple, list)):
                date_str = date_str[0]  # 最初の要素を取得

          try:
              query_date = datetime.strptime(date_str, '%Y-%m-%d').date()
          except ValueError:
              return Slot.objects.none()
          
        #   今日を選択された場合、現在時刻以降のSlotを取得
          if query_date == today_date :
              slots = Slot.objects.filter(
                  course__course_name = course_name,
                  date = query_date,
                  start_time__gte = today_hour
              ).order_by('start_time')
              return slots
        #   今日以外であれば、全てのSlotを取得
          else:
              slots = Slot.objects.filter(
                  course__course_name = course_name,
                  date = query_date,
              ).order_by('start_time')
              return slots
        # if self.action == 'fetch_slots_for_staff':
        #      date_str = self.request.query_params.get('date')
        #      slots = Slot.objects.filter('date_str').order_by('start_time')
        #      return slots
            #  if isinstance(date_str, (tuple, list)):
            #       date_str = date_str[0]  # 最初の要素を取得

            #  try:
            #    query_date = datetime.strptime(date_str, '%Y-%m-%d').date()
            #  except ValueError:   
        else:
           return super().get_queryset()
        
    @action(detail=False, methods=['get'], permission_classes = [SlotPermission], url_path='course_slots_for_staff')
    def fetch_course_slots_for_staff(self, request):
        slot = self.get_queryset()
        slot_serializer = serializers.SlotSerializer(slot,many=True)
        return Response(slot_serializer.data)
    
    @action(detail=False, methods=['get'], permission_classes = [SlotPermission], url_path='each_course_slots')
    def fetch_each_course_slots(self, request):
        slot = self.get_queryset()
        slot_serializer = serializers.SlotSerializer(slot,many=True)
        return Response(slot_serializer.data)
        
    @action (detail=False, methods=['get'],
             permission_classes= [SlotPermission],
             url_path='course_slots'
             )
    def fetch_course_slots(self, request):
        slot = self.get_queryset()
        slot_serializer = serializers.SlotSerializer(slot,many=True)
        return Response(slot_serializer.data)
    
    @action(detail=False, methods=['get'], permission_classes = [SlotPermission], url_path='slots_for_calendar')
    def fetch_slots_for_calendar(self, request):
        slot = self.get_queryset()
        slot_serializer = serializers.SlotSerializer(slot,many=True)
        return Response(slot_serializer.data)
    
    @action(detail=False, methods=['get'], permission_classes = [SlotPermission], url_path='all_slots')
    def fetch_all_slots(self, request):
        slot = self.get_queryset()
        slot_serializer = serializers.SlotSerializer(slot,many=True)
        return Response(slot_serializer.data)
    
    def perform_create(self,request):
        data = self.request.data

        fetched_course = data.get('course')
        fetched_date = data.get('date')
        fetched_start_time = data.get('start_time')
        fetched_end_time = data.get('end_time')
        fetched_max_people = data.get('max_people')

        course = get_object_or_404(Course, course_name = fetched_course)

        try:
            slot = Slot.objects.create(
                course = course,
                date = fetched_date,
                start_time = fetched_start_time,
                end_time = fetched_end_time,
                max_people = fetched_max_people,
            )
            serializer = self.get_serializer(slot)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        except (ValueError, TypeError) as e:
            return Response({'error': '${e}: Failed to create slot.'}, status=status.HTTP_400_BAD_REQUEST)
        
    @action(detail=True, methods=['patch'],url_path='update_slot', permission_classes=[SlotPermission])
    def update_slot(self,request,pk=None):

        # SlotインスタンスをURLパラメーターから取得
        slot = self.get_object()
        reservation = Reservation.objects.filter(slot=slot)

        if reservation.exists():
            slot.is_cancelled = True
            slot.save()

            serializer= self.get_serializer(slot)
            return Response(serializer.data, status=status.HTTP_200_OK)
        else:
            slot.delete()
            return Response({'detail': 'Slot has been deleted'}, status=status.HTTP_204_NO_CONTENT)


class ReservationViewSet(viewsets.ModelViewSet):
    queryset = Reservation.objects.all()
    serializer_class = serializers.ReservationSerializer
    permission_classes = [ReservationPermission]

    # ★ここは何度でも見るべき場所だな。フロントエント側のリクエストデータを参照している
    def perform_create(self, serializer):
        data = self.request.data
        membership_id = data.get('membership')
        slot = data.get('slot')

    # ★上記でフロント側で指定したデータで、Django（バックエンド）の処理を記載
        membership = get_object_or_404(Membership, id=membership_id)
        slot = get_object_or_404(Slot, id=slot)
        date = data.get('date')
        
        # 重複した予約を弾く
        my_overlap_reservation = Reservation.objects.filter(
            membership=membership,
            slot=slot
        )
        
        # my_course_membership = Membership.objects.filter(
        #     id=membership_id,
        # )
        if my_overlap_reservation.exists():
            raise ValidationError('Same reservation already exists')
        # max_requested_timesを弾く
        if membership.requested_join_times == membership.max_join_times:
            raise ValidationError('Request denied. Already reached to max reservation times')
         # max_reservation_timesを弾く
        if  membership.already_join_times ==  membership.max_join_times:
            raise ValidationError('You already reached to max join times')
        # validation_day以降の予約を弾く
        if membership.expire_day < slot.date:
            raise ValidationError('Selected slot is out of your membership\'s expire day')
        
        # requested_times_joinがmax_join_timesと同数なら、createを弾く
        else:
            reservation = Reservation.objects.create(
            membership=membership,
            slot=slot,
            date=date,
            # attended=False,
            # is_cancelled=True,
        )
        serializer = self.get_serializer(reservation)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
  
    def get_queryset(self):
        if self.action == 'fetch_my_available_slots':
            my_courses = []
            my_memberships = Membership.objects.filter(
                user=self.request.user,
                is_expired=False,
                is_approved=True
            )
            for my_membership in my_memberships:
                my_courses.append(my_membership.course)
            date_str = self.request.query_params.get('date')
            if date_str:
                formattedDate = datetime.strptime(date_str, '%Y-%m-%d')
                if formattedDate:
                    available_slots = Slot.objects.filter(
                        max_people__gt=0,
                        date=formattedDate,
                        course__in=my_courses,
                    ).order_by('date').annotate(
                        slot_course_name=F('course__course_name'),
                    )
                    return available_slots
            return Slot.objects.none()
        
        elif self.action == 'fetch_qr_reservation':
            reservation_id = self.request.query_params.get('reservation_id')
            reservation = Reservation.objects.filter(
                id = reservation_id 
            )
            return reservation

        elif self.action == 'fetch_my_reservations':
            now_utc = timezone.now()
            local_timezone = pytz.timezone('Africa/Nairobi')
            now_local = now_utc.astimezone(local_timezone)

            today_date = now_local.date()
            today_hour = now_local.time()
            firstReservation = Reservation.objects.filter(
                membership__user = self.request.user,
                attended= False,
                slot__is_cancelled = False,
                slot__date__gte=today_date,
            ).order_by('slot__date')

            reservationToday = Reservation.objects.filter(
                membership__user = self.request.user,
                attended = False,
                slot__is_cancelled = False,
                slot__date = today_date,
            ).order_by('slot__start_time')

            if firstReservation.exists():
                first_reservation_date = firstReservation.first().slot.date
                if reservationToday.exists():
                    last_reservation_start_time = reservationToday.last().slot.start_time

                if first_reservation_date == today_date and last_reservation_start_time > today_hour :
                     reservations = Reservation.objects.filter(
                     membership__user=self.request.user,
                     attended=False,
                     slot__is_cancelled = False,
                     slot__date__gte=today_date,
                     slot__start_time__gte = today_hour,
                     ).order_by('date','slot__start_time').annotate(
                        slot_course_name=F('slot__course__course_name'),
                        slot_start_time=F('slot__start_time'),
                        slot_end_time=F('slot__end_time'),
                        slot_date = F('slot__date'),
                        user_Id = F('membership__user__id'),
                        point = F('membership__user__points')
                     )
                     return reservations
                elif first_reservation_date == today_date and last_reservation_start_time < today_hour :
                     reservations = Reservation.objects.filter(
                     membership__user=self.request.user,
                     slot__is_cancelled = False,
                     attended=False,
                     slot__date__gt=today_date,
                     ).order_by('date','slot__start_time').annotate(
                        slot_course_name=F('slot__course__course_name'),
                        slot_start_time=F('slot__start_time'),
                        slot_end_time=F('slot__end_time'),
                        slot_date = F('slot__date'),
                        user_Id = F('membership__user__id'),
                        point = F('membership__user__points')
                     )
                     return reservations
                else:
                    reservations = Reservation.objects.filter(
                     membership__user=self.request.user,
                     attended=False,
                     slot__is_cancelled = False,
                     slot__date__gt=today_date,
                     ).order_by('date').annotate(
                        slot_course_name=F('slot__course__course_name'),
                        slot_start_time=F('slot__start_time'),
                        slot_end_time=F('slot__end_time'),
                        slot_date = F('slot__date'),
                        user_Id = F('membership__user__id'),
                        point = F('membership__user__points')
                     )
                    return reservations
                
            else:
                reservations = Reservation.objects.none()
        elif self.action == 'fetch_slots_for_staff':
            now_utc = timezone.now()
            local_timezone = pytz.timezone('Africa/Nairobi')
            now_local = now_utc.astimezone(local_timezone)
            today_date = now_local.date()
            today_hour = now_local.time()
            staff = self.request.user
            fetched_slot_id = self.request.query_params.get('slot_id')
            slot_id = get_object_or_404(Slot, id=fetched_slot_id)

            date_str = self.request.query_params.get('date')
            if isinstance(date_str, (tuple, list)):
                date_str = date_str[0]  # 最初の要素を取得
            try:
              query_date = datetime.strptime(date_str, '%Y-%m-%d').date()
            except ValueError:
              return Slot.objects.none()

            reservations = Reservation.objects.filter(
                slot = slot_id,
                date = query_date
                     ).order_by('date','slot__start_time').annotate(
                        slot_course_name=F('slot__course__course_name'),
                        slot_start_time=F('slot__start_time'),
                        slot_end_time=F('slot__end_time'),
                        slot_date = F('slot__date'),
                        slot_reserved_people=F('slot__reserved_people'),
                        slot_mac_people=F('slot__max_people'),
                        attendee_name = F('membership__attendee__name'),
                        attendee_gender=F('membership__attendee__gender'),
                        attendee_birthday=F('membership__attendee__date_of_birth'),
                        attendee_goal = F('membership__attendee__goal'),
                        attendee_any_comment=F('membership__attendee__any_comment'),
                        attendee_reason = F('membership__attendee__reason'),
                        user_phone = F('membership__user__phone_number'),
                        user_id = F('membership__user_id')
                     )
            return reservations
        elif self.action == 'fetch_my_all_reservation':
            all_reservation = Reservation.objects.filter(membership__user = self.request.user).order_by('date','slot__start_time').annotate(
                slot_is_cancelled = F('slot__is_cancelled')
            ).reverse()
            return all_reservation
        else:
            return super().get_queryset()
        
    def destroy(self, request, *args, **kwargs):
            reservation = self.get_object()
            membership = reservation.membership

            if membership.requested_join_times >0:
                membership.requested_join_times = F('requested_join_times') - 1
                membership.save()
            if membership.requested_join_times==0:
                membership.requested_join_times=0
            
            reservation.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)


    @action(detail=False, methods=['get'], permission_classes=[ReservationPermission], url_path='my_reservations')
    def fetch_my_reservations(self, request):
        reservations = self.get_queryset()
        serializer = self.get_serializer(reservations, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'], permission_classes=[ReservationPermission], url_path='available_slots')
    def fetch_my_available_slots(self, request):
        slots = self.get_queryset()
        slots_serializer = serializers.SlotSerializer(slots, many=True)
        return Response(slots_serializer.data)
    
    @action(detail=False, methods=['get'], permission_classes=[ReservationPermission], url_path='slots_for_staff')
    def fetch_slots_for_staff(self, request):
        slots = self.get_queryset()
        slots_serializer = serializers.ReservationSerializer(slots, many=True)
        return Response(slots_serializer.data)
    
    @action(detail=False, methods=['get'], permission_classes=[ReservationPermission], url_path='qr_reservation')
    def fetch_qr_reservation(self,request):
        reservation = self.get_queryset()
        reservation_serializer = serializers.ReservationSerializer(reservation, many=True)
        return Response(reservation_serializer.data)
    
    @action(detail=False, methods=['get'], permission_classes=[ReservationPermission], url_path='my_all_reservation')
    def fetch_my_all_reservation(self, request):
        reservations = self.get_queryset()
        serializer = self.get_serializer(reservations, many=True)
        return Response(serializer.data)
    
    # @action(detail=True, methods=['patch'],url_path='delete_slot', permission_classes=[ReservationPermission])
    # def delete_slot(self,request,pk=None):

    #     # SlotインスタンスをURLパラメーターから取得
    #     reservationId = self.get_object()
    #     reservation = Reservation.objects.filter(id=reservationId)

    #     if reservation.exists():
    #         reservation.delete()
    #         return Response({'detail': 'Slot has been deleted'}, status=status.HTTP_204_NO_CONTENT)
    #     else:
    #         raise ValidationError('Reservation does not exist')
           

    
    # @action(detail=False, methods=['post'], url_path='create_reservation')
    # def create_reservation(self, request):
    #     data = request.data
    #     membership_id = data.get('membership')
    #     slot_id = data.get('slot')
    #     date = data.get('date')

    #     membership = get_object_or_404(Membership, id=membership_id)
    #     slot = get_object_or_404(Slot, id=slot_id)

    #     reservation = Reservation.objects.create(
    #         membership=membership,
    #         slot=slot,
    #         date=date,
    #         attended=False,
    #         is_cancelled=False,
    #     )
    #     serializer = self.get_serializer(reservation)
    #     return Response(serializer.data, status=status.HTTP_201_CREATED)