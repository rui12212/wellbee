from rest_framework import serializers
from django.contrib.auth import get_user_model
from attendances.models import Course, Interview, Membership,Attendee, CheckIn
from accounts.models import User


class MembershipSerializer(serializers.ModelSerializer):
    attendee_name = serializers.CharField(source='attendee.name', read_only=True)
    attendee_gender = serializers.CharField(source='attendee.gender', read_only=True)
    attendee_birthday = serializers.DateField(source='attendee.date_of_birth', read_only=True)
    course_name = serializers.CharField(source='course.course_name', read_only=True)
    # user_id = serializers.PrimaryKeyRelatedField(queryset=User.objects.all())

    # attendee = serializers.PrimaryKeyRelatedField(queryset=Attendee.objects.all())
    # course = serializers.PrimaryKeyRelatedField(queryset=Course.objects.all(), required=False, allow_null=True)


    class Meta:
        model = Membership
        # fields = '__all__'
        fields=('id','user_id','course','expire_day','times_per_week','max_join_times','already_join_times','requested_join_times','duration','request_time', 'is_approved', 'total_price','attendee_name','attendee_gender','attendee_birthday','course_name','original_price','num_person','discounted_total_price','attendee')
        extra_kwargs = {
            'user_id': {'read_only': True},
            'id': {'read_only': True},
            'course': {'read_only': True},
            }
    
    # def create(self, validated_data):
    #     # 必要なフィールドを取得
    #     original_price = validated_data.get('original_price')
    #     times_per_week = validated_data.get('times_per_week')
    #     duration = validated_data.get('duration')
    #     num_person = validated_data.get('num_person')
    #     discount_rate = validated_data.get('discount_rate')
    #     total_price = original_price * times_per_week * duration * num_person
    #     discounted_total_price = int(total_price *  discount_rate)

    #     validated_data['total_price'] = total_price
    #     validated_data['discounted_total_price'] = discounted_total_price

    #     membership = Membership.objects.create(**validated_data)
    #     return membership


class CourseSerializer(serializers.ModelSerializer):
    class Meta:
        model= Course
        fields=('id', 'course_name',)
        extra_kwargs = {
            'id': {'read_only': True},
            }

class AttendeeSerializer(serializers.ModelSerializer):
    user_id = serializers.CharField(source = 'user.id', read_only=True)
    user_phone = serializers.CharField(source='user.phone_number', read_only=True)
    points = serializers.IntegerField(source='user.points', read_only=True)

    class Meta:
        model = Attendee
        fields = ('id','user', 'name', 'gender', 'date_of_birth', 'any_comment', 'created_date', 'reason', 'goal','last_survey_date','user_id','user_phone','points')
        extra_kwargs = {
            'user': {'read_only': True},
            'created_date': {'read_only': True},
        }

class InterviewSerializer(serializers.ModelSerializer):
    user_id = serializers.CharField(source = 'attendee.user.id', read_only=True)
    attendee_name = serializers.CharField(source = 'attendee.name', read_only=True)
    class Meta:
        model = Interview
        fields = ('attendee','emotion_state','physical_state','any_comment','created_at','user_id','attendee_name')
        extra_kwargs = {
            'attendee': {'read_only': True},
            'created_at': {'read_only': True},
        }

class CheckInSerializer(serializers.ModelSerializer):
    class Meta:
        model=CheckIn
        fields=('id','created_at','checked_by','reservation','num_person')
        extra_kwargs = {
            'id': {'read_only': True},
            'checked_by': {'read_only': True},
            }

# class PaymentSerializer(serializers.ModelSerializer):
#     class Meta:
#         model=Payment
#         fields=('membership', 'discount_rate', 'discounted_total_price', 'points_used','payment_date')
#         extra_kwargs = {
#             'membership': {'read_only': True},
#         }

        



