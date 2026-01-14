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
    course_name=models.CharField(verbose_name="course_name",max_length=25, default='Yoga',blank=False, null=False)
    is_private=models.BooleanField(verbose_name='is_private', default=False, null=False, blank=False)
    is_open=models.BooleanField(verbose_name='is_open',default=True, null=False, blank=False)
    course_image = models.ImageField(
        verbose_name="course_image",
        upload_to='courses/',  # S3のcourses/フォルダに保存
        blank=True,
        null=True,
    )

    def __str__(self):
        return self.course_name
    
class Attendee(models.Model):
     GENDER = (
        ('male', 'male'),
        ('female', 'female'),
        ('Not specified', 'Not specified')
    )
     user=models.ForeignKey(settings.AUTH_USER_MODEL, verbose_name='user', on_delete=models.SET_NULL, null=True, blank=False)
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
    
    DURATION=(
        (1, '1 month'),
        (2, '2 months'),
        (3, '3 months'),
        (6, '6 months'),
        (12, '1 year'),
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

    OFFER=(
        (0,'No offer'),
        (48,'1 month free(3 months)'),
        (42,'1 month free(6 months)'),
        (30,'1 month free(12 months)'),
        (45,'1 month free(Kids 3 months)'),
    )

    user = models.ForeignKey(User, verbose_name='user',on_delete=models.SET_NULL, null=True)
    attendee = models.ForeignKey(Attendee,verbose_name='attendee', on_delete=models.SET_NULL,null=True, blank=False)
    course = models.ForeignKey(Course,on_delete=models.CASCADE, null=True)
    # modify to default setting
    times= models.IntegerField(verbose_name="times",default=1,blank= False, null=False)
    # modify to default setting
    num_person = models.IntegerField(verbose_name='num_person', default=1, blank=False, null=False)
    duration=models.IntegerField(verbose_name="duration", choices=DURATION,blank= False, null=False,)
    offer = models.IntegerField(verbose_name="offer", choices=OFFER, blank=True, null=True,default=0)
    minus=models.IntegerField(verbose_name="minus",default=0,blank= False, null=False)  
    is_approved=models.BooleanField(verbose_name='is_approved', default=True)
    total_price =models.IntegerField(verbose_name='total_price',blank= False, null=False)
    discount_rate=models.FloatField(verbose_name="discount_rate", choices=DISCOUNT_RATE,blank= False, null=False)
    discounted_total_price=models.IntegerField(verbose_name='discounted_total_price',blank= False, null=True)
    max_join_times = models.IntegerField(verbose_name='max_join_times', blank=False, null=True)
    requested_join_times = models.IntegerField(verbose_name='requested_join_times', blank=False, null=True,default=0)
    already_join_times=models.IntegerField(verbose_name='already_join_times', blank=False, null=True,default=0)
    request_time = models.DateTimeField(auto_now_add=True)
    # 新しくStartDayを記載
    start_day = models.DateField(verbose_name='start_day',blank= False, null=True)
    expire_day=models.DateField(verbose_name='expire_day',blank=False, null=False, default=get_today) 
    is_expired=models.BooleanField(verbose_name='is_expired', default=False)
    last_check_in = models.DateField(verbose_name='last_check_in', blank=False, null=False, default=get_today)
    def __str__(self):
        name = self.attendee.name if self.attendee and self.attendee.name else "None"
        return f"{name} - {self.course}"

# delete
# @receiver(pre_save, sender=Membership)
# def set_total_price(sender, instance, **kwargs):
#     instance.total_price = int(instance.original_price * instance.times_per_week * instance.duration * instance.num_person) - int(instance.minus)

# -minusを追加
@receiver(pre_save, sender=Membership)
def set_discounted_total_price(sender, instance, **kwargs):
        # ポイント使用前金額計算＝オリジナルの合計金額からディスカウントをする
        instance.discounted_total_price = ((instance.total_price - (instance.minus + instance.offer))) * instance.discount_rate


@receiver(pre_save, sender=Membership)
def set_max_join_times(sender, instance, **kwargs):
    # もしCourseがPrivateでなかったら
    if instance.course and not instance.course.is_private:
        instance.max_join_times = int(instance.times * instance.duration * 4)
    else:
        instance.max_join_times = int(instance.times)

# ここ変更
@receiver(pre_save, sender=Membership)
def set_expire_day(sender, instance, created ,**kwargs):
    # if created:
      if instance.start_day:
          instance.expire_day = (instance.start_day + relativedelta(months=instance.duration))
      else:
          instance.expire_day = (timezone.localdate() + relativedelta(months=instance.duration))

@receiver(post_save, sender=Membership)
def plus_point(sender, instance, created, **kwargs):
    if created:
        instance.user.points += 1
        instance.user.save()


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
    reservation = models.OneToOneField('reservations.Reservation',  verbose_name='reservation', on_delete=models.CASCADE,null=False,blank=False)
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
        instance.reservation.membership.user.points += 1
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

@receiver(post_save, sender=CheckIn)
def set_last_check_in(sender, created, instance, **kwargs):
    if created:
        instance.reservation.membership.last_check_in = instance.created_at
        instance.reservation.membership.save()