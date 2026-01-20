from rest_framework import serializers
from django.contrib.auth import get_user_model
from reservations.models import Slot, Reservation
from attendances.serializers import CourseSerializer


class SlotSerializer(serializers.ModelSerializer):
    slot_course_name = serializers.CharField(source='course.course_name', read_only=True)

    class Meta:
        model = Slot
        fields=('id','course','start_time','date', 'end_time', 'max_people', 'reserved_people','is_cancelled','created_at','is_max','updated_at','slot_course_name')
        extra_kwargs = {
            'id': {'read_only': True},
            'course': {'read_only': True},
            }

class ReservationSerializer(serializers.ModelSerializer):
    slot_course_name = serializers.CharField(source='slot.course.course_name', read_only=True)
    slot_course_image_url = serializers.SerializerMethodField()
    slot_start_time = serializers.TimeField(source='slot.start_time',read_only=True)
    slot_end_time = serializers.TimeField(source='slot.end_time', read_only=True)
    slot_date = serializers.DateField(source='slot.date', read_only=True)
    slot_reserved_people=serializers.IntegerField(source='slot.reserved_people', read_only=True)
    slot_max_people=serializers.IntegerField(source='slot.max_people', read_only = True)
    slot_is_cancelled=serializers.BooleanField(source='slot.is_cancelled',read_only=True)
    attendee_name=serializers.CharField(source='membership.attendee.name', read_only=True)
    attendee_gender=serializers.CharField(source='membership.attendee.gender',read_only=True)
    attendee_birthday=serializers.DateField(source='membership.attendee.date_of_birth',read_only=True)
    attendee_goal = serializers.CharField(source = 'membership.attendee.goal',read_only=True)
    attendee_reason = serializers.CharField(source='membership.attendee.reason',read_only=True)
    attendee_any_comment = serializers.CharField(source='membership.attendee.any_comment',read_only=True)
    user_phone = serializers.IntegerField(source='membership.user.phone_number',read_only=True)
    user_id = serializers.CharField(source='membership.user_id',read_only=True)
    points = serializers.IntegerField(source='membership.user.points', read_only=True)
    
    class Meta:
        model= Reservation
        fields=('id','membership', 'date', 'slot', 'reserved_at','attended', 'updated_at','slot_course_name','slot_course_image_url','slot_start_time','slot_end_time','slot_date','slot_reserved_people','slot_max_people','slot_is_cancelled','attendee_name','attendee_gender','attendee_birthday','attendee_goal','attendee_reason','user_phone','user_id','points','attendee_any_comment')
        extra_kwargs = {
            # 'membership_id': {'read_only': True},
            # 'slot': {'read_only': True},
            }

    def get_slot_course_image_url(self, obj):
        """予約スロットのコースS3画像URLを返す"""
        if obj.slot and obj.slot.course and obj.slot.course.course_image:
            return obj.slot.course.course_image.url
        return None
