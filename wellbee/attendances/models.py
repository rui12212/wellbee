from datetime import datetime
from django.db import models
from django.conf import settings
# ここからはUser登録時に作成されるカスタムUser作成で必要になるimportr
from django.dispatch import receiver
from django.db.models.signals import pre_save,post_save
from django.utils import timezone
from dateutil.relativedelta import relativedelta
from django.core.validators import RegexValidator
from accounts.models import User



class Course(models.Model):
    COURSE_NAME=(
        # ('Trial Yoga', 'Trial Yoga'),
        ('Yoga','Yoga'),
        ('Kids Yoga','Kids Yoga'),
        ('Zumba','Zumba'),
        ('Dance', 'Dance'),
        ('Kids Dance', 'Kids Dance'),
        ('Karate','Karate'),
        ('Kids Karate','Kids Karate'),
        ('Kids Taiso','Kids Taiso'),
        ('Music', 'Music'),
        ('Kids Music','Kids Music'),
        ('Pilates','Pilates'),
        ('Family Pilates','Family Pilates'),
        ('Family Yoga','Family Yoga'),
    )
    course_name=models.CharField(verbose_name="course_name", choices=COURSE_NAME,max_length=20, default='Yoga',blank=False, null=False)
    

    def __str__(self):
        return self.course_name
    
class Attendee(models.Model):
     GENDER = (
        ('male', 'male'),
        ('female', 'female'),
        ('Not specified', 'Not specified')
    )
     user=models.ForeignKey(settings.AUTH_USER_MODEL, verbose_name='user', on_delete=models.PROTECT, null=False, blank=False)
     name=models.CharField(verbose_name="name", null=False, blank=False, max_length=50)
     gender=models.CharField(verbose_name='gender', max_length=20, choices=GENDER,blank= False, null=False,)
     date_of_birth=models.DateField(verbose_name="date_of_birth",null=False,)
     created_date = models.DateTimeField(verbose_name='created_date',auto_now_add=True,null=False, blank=False)
     any_comment=models.CharField(verbose_name="any_comment", null=True, blank=True, max_length=150)
     reason = models.CharField(verbose_name='reason', max_length=150, null=True, blank=True)
     goal = models.CharField(verbose_name='goal', max_length=150, null=True, blank=True)
     last_survey_date = models.DateTimeField(default=datetime(2000, 1, 1),null=False,blank=False)

     def __str__(self):
        return f"UserMobile#-{self.user} / Attendee-{self.name}"

class Interview(models.Model):
    attendee=models.ForeignKey(Attendee, verbose_name='attendee', null=False, blank=False,on_delete=models.CASCADE)
    emotion_state = models.CharField(verbose_name='reason', max_length=300, null=False, blank=False)
    physical_state = models.CharField(verbose_name='goal', max_length=300, null=False, blank=False)
    any_comment=models.CharField(verbose_name="any_comment", null=True, blank=True, max_length=300)
    created_at= models.DateTimeField(verbose_name='date',auto_now_add=True,null=False, blank=False)

    def __str__(self):
        return f"Name-{self.attendee.name} / {self.created_at}"

def get_today():
    return timezone.now().date()

class Membership(models.Model):
    ORIGINAL_PRICE=(
        (10,'10$'),
        (20,'20$'),
        (30,'30$'),
        (40,'40$'),
        (50,'50$'),
        (60,'60$'),
        (70,'70$'),
        (80,'80$'),
        (90,'90$'),
        (100,'100$'),
        (110,'110$'),
        (120,'120$'),
        (130,'130$'),
        (140,'140$'),
        (150,'150$'),
    )
    # ('DBに登録する値', 'Web上に表示するなどわかりやすい値')
    TIMES_PER_WEEK=(
        (1,'1 time'),
        (2,'2 times'),
    )
    
    DURATION=(
        (1, '1 month'),
        (3, '3 months'),
        (6, '6 months'),
        (12, '1 year'),
    )

    NUM_PERSON=(
        (1,'1'),
        (2,'2'),
        (3,'3'),
        (4,'4'),
        (5,'5'),
    )

    DISCOUNT_RATE=( 
        (1.0, 'No Discount'),
        (0.95,'5% OFF'),
        (0.9, '10% OFF'),
        (0.85,'15% OFF'),
        (0.8, '20% OFF'),
        (0.75,'25% OFF'),
        (0.7, '30% OFF'),
        (0.65,'35% OFF'),
        (0.6, '40% OFF'),
        (0.55,'45% OFF'),
        (0.5, '50% OFF'),
        (0.45,'55% OFF'),
        (0.4, '60% OFF'),
    )

    user = models.ForeignKey(User, verbose_name='user',on_delete=models.PROTECT, null=False)
    attendee = models.ForeignKey(Attendee,verbose_name='attendee', on_delete=models.PROTECT, null=False, blank=False)
    course = models.ForeignKey(Course,on_delete=models.CASCADE, null=True)
    original_price=models.IntegerField(verbose_name="original_price", choices=ORIGINAL_PRICE, blank= False, null=False)
    times_per_week= models.IntegerField(verbose_name="times_per_week", choices=TIMES_PER_WEEK,blank= False, null=False)
    num_person = models.IntegerField(verbose_name='num_person', choices=NUM_PERSON, blank=False, null=False)
    duration=models.IntegerField(verbose_name="duration", choices=DURATION,blank= False, null=False,)
    request_time = models.DateTimeField(auto_now_add=True)
    is_approved=models.BooleanField(verbose_name='is_approved', default=True)
    total_price =models.IntegerField(verbose_name='total_price',blank= False, null=True,)
    discount_rate=models.FloatField(verbose_name="discount_rate", choices=DISCOUNT_RATE,blank= False, null=False,)
    discounted_total_price=models.IntegerField(verbose_name='discounted_total_price',blank= False, null=True,)
    max_join_times = models.IntegerField(verbose_name='max_times_join', blank=False, null=True)
    requested_join_times = models.IntegerField(verbose_name='requested_join_times', blank=False, null=True,default=0)
    already_join_times=models.IntegerField(verbose_name='already_join_times', blank=False, null=True,default=0)
    expire_day=models.DateField(verbose_name='expire_day',blank=False, null=False, default=get_today) 
    is_expired=models.BooleanField(verbose_name='is_expired', default=False)
    def __str__(self):
        # return str(self.attendee.name)
        return f"{self.attendee.name} - {self.course}"
    
@receiver(pre_save, sender=Membership)
def set_total_price(sender, instance, **kwargs):
    instance.total_price = int(instance.original_price * instance.times_per_week * instance.duration * instance.num_person)

@receiver(pre_save, sender=Membership)
def set_discounted_total_price(sender, instance, **kwargs):
        # ポイント使用前金額計算＝オリジナルの合計金額からディスカウントをする
        instance.discounted_total_price = int(instance.total_price * instance.discount_rate)

@receiver(pre_save, sender=Membership)
def set_max_join_times(sender, instance, **kwargs):
    instance.max_join_times = int(instance.times_per_week * instance.duration * 4)

@receiver(pre_save, sender=Membership)
def set_expire_day(sender, instance, **kwargs):
    if instance.request_time:
        instance.expire_day = (instance.request_time + relativedelta(months=instance.duration)).date()
    else:
        instance.expire_day = (timezone.now() + relativedelta(months=instance.duration)).date()


# @receiver(pre_save, sender=Payment)
# # ディスカウントされた最終金額を計算する
# def set_discounted_total_price(sender, instance, **kwargs):
#     if instance.points_used>0:
#         # ポイント使用前金額計算＝オリジナルの合計金額からディスカウントをする
#         instance.discounted_total_price = int(instance.membership.total_price * instance.discount_rate)
#         # ポイント使用後の最終金額計算＝使用ポイント分だけ、ポイント使用前金額
#         if instance.points_used>instance.discounted_total_price:
#             raise ValueError('The points cannot be used more than the total price')
#         instance.discounted_total_price -= instance.points_used
#     else:
#         instance.discounted_total_price = int(instance.membership.total_price * instance.discount_rate)
# userのpointsフィールドにポイントを追加する


     
class CheckIn(models.Model):
    NUM_PERSON=(
        (1,'1'),
        (2,'2'),
        (3,'3'),
        (4,'4'),
        (5,'5'),
    )
    # membership=models.ForeignKey(Membership, verbose_name="membership",on_delete=models.PROTECT)
    checked_by=models.ForeignKey(settings.AUTH_USER_MODEL, verbose_name='checked_by', on_delete=models.PROTECT)
    reservation = models.OneToOneField('reservations.Reservation',  verbose_name='reservation', on_delete=models.PROTECT,null=False,blank=False)
    num_person = models.IntegerField(verbose_name='num_person',choices=NUM_PERSON,null=False,blank=False)
    created_at= models.DateTimeField(verbose_name='date',auto_now_add=True,null=False, blank=False)

    def __str__(self):
        return str(self.created_at)
    
@receiver(pre_save, sender=CheckIn)
def validate_staff(sender, instance, **kwargs):
    if not instance.checked_by.is_staff:
        raise  ValueError('The confirmation of the checking must be a staff member')

@receiver(post_save, sender=CheckIn)
def set_points_for_checkin(sender, created, instance, **kwargs):
    if created:
        instance.reservation.membership.user.points = instance.reservation.membership.user.points + instance.num_person
        instance.reservation.membership.user.save()
        
@receiver(post_save, sender=CheckIn)
def set_already_join_times(sender,created, instance, **kwargs):
    if created:
        if instance.reservation.membership.already_join_times < instance.reservation.membership.max_join_times:
            instance.reservation.membership.already_join_times += 1
            instance.reservation.membership.save()
        else:
            raise ValueError('You have reached the maximum number of times you can join this course. Please apply for a new membership')
@receiver(post_save, sender=CheckIn)
def set_boolean_reservation(sender, created, instance, **kwargs):
    if created:
        instance.reservation.attended = True
        instance.reservation.save()