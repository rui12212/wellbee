from datetime import time
from django.utils import timezone
from django import forms
from django.conf import settings
from django.db import models
from django.dispatch import receiver
from django.db.models.signals import pre_save,post_save,post_delete
from rest_framework.exceptions import ValidationError
from attendances.models import Course, Membership
# from django.apps import apps

class TimeChoiceFormField(forms.TimeField):
    def __init__(self, *args, **kwargs):
        time_choices = [(time(hour=h, minute=m), '{:02d}:{:02d}'.format(h, m))
                        for h in range(8, 24)
                        for m in (0, 30)]
        kwargs['widget'] = forms.Select(choices=time_choices)
        super().__init__(*args, **kwargs)

class TimeChoiceField(models.TimeField):
    def formfield(self, **kwargs):
        defaults = {'form_class': TimeChoiceFormField}
        defaults.update(kwargs)
        return super().formfield(**defaults)

class Slot(models.Model):
    course = models.ForeignKey(Course, verbose_name='course', on_delete=models.CASCADE)
    date = models.DateField(verbose_name='date', null=False, blank=False)
    start_time = TimeChoiceField(verbose_name='start_time', blank=False, null=False)
    end_time = TimeChoiceField(verbose_name='end_time', blank=False, null=False)
    max_people = models.IntegerField(verbose_name='max_people', default=25, blank=False, null=False)
    reserved_people = models.IntegerField(verbose_name='reserved_people', default=0, blank=False, null=False)
    is_max = models.BooleanField(verbose_name='is_max', default=False, blank=False, null=False,)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_cancelled = models.BooleanField(verbose_name='is_cancelled', default=False, null=False, blank=False)

    def clean(self):
        if self.end_time <= self.start_time:
            raise ValidationError('end time must be later than start time')
        
        overlapping_events = Slot.objects.filter(
            course__course_name= self.course.course_name,
            date = self.date,
            start_time__lt = self.end_time,
            end_time__gt=self.start_time
        ).exists()

        # if overlapping_events:
        #     raise ValidationError('There is an overlapped course slot')

    def __str__(self):
       return f"{self.date} - {self.course} - {self.start_time} - {self.end_time}"

class Reservation(models.Model):
    membership = models.ForeignKey(Membership, verbose_name='membership', on_delete=models.CASCADE)
    date = models.DateField(verbose_name='date', null=False, blank=False)
    slot =  models.ForeignKey(Slot, verbose_name='slot', on_delete=models.PROTECT)
    attended = models.BooleanField(verbose_name='attended', default=False, blank=False, null=False)
    is_cancelled = models.BooleanField(verbose_name='is_cancelled', default=False, null=False, blank=False)
    reserved_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        name = self.membership.attendee.name if self.membership.attendee and self.membership.attendee.name else "None"
        return f"Reservation by {name} for {self.slot}"

@receiver(pre_save, sender=Reservation)
def set_date(sender, instance, **kwargs):
    instance.date = instance.slot.date

@receiver(pre_save, sender=Reservation)
def set_start_end_time(sender, instance, **kwargs):
    instance.start_time = instance.slot.start_time
    instance.end_time = instance.slot.end_time

@receiver(post_save, sender=Reservation)
def set_requested_join_times(sender, instance, created, **kwargs):
    if created:
      if instance.membership.requested_join_times < instance.membership.max_join_times:
             instance.membership.requested_join_times += 1
             instance.membership.save() 
      else:
         raise ValidationError('Reached to max times to request reservation')

@receiver(post_save, sender=Reservation)
def add_reserved_people(sender, instance, created, **kwargs):
    if created:
      if instance.slot.reserved_people < instance.slot.max_people:
          instance.slot.reserved_people += 1
          instance.slot.save()
    # createされなかったら＝19以下ではなかったらとなる。両方必要
      else:
          raise ValueError("Reservation reached to max number")
    # raiseを書かないと、エラーが発生しない。数字だけはインクリメントされて、userに通知がなく不親切

@receiver(post_save, sender=Reservation)
def set_is_max_true(sender, instance, created, **kwargs):
    if instance.slot.reserved_people == instance.slot.max_people:
        instance.slot.is_max = True
        instance.slot.save()


@receiver(pre_save, sender=Reservation)
def set_is_max_false(sender, instance, **kwargs):
    if instance.slot.reserved_people <= instance.slot.max_people-1:
        instance.slot.is_max = False
        instance.slot.save()

@receiver(post_delete, sender=Reservation)
def update_reserved_people_on_delete(sender, instance, **kwargs):
    slot = instance.slot
    if slot.reserved_people > 0:
        slot.reserved_people -= 1
        if slot.reserved_people <= instance.slot.max_people-1:
            slot.is_max = False
        slot.save()

# def cleanup_migrations():
#     from django.db.migrations.recorder import MigrationRecorder
#     MigrationRecorder.Migration.objects.all().delete()　
# cleanup_migrations()