from django.utils import timezone
from django.conf import settings
from django.db import models
from django.dispatch import receiver
from django.db.models.signals import pre_save,post_save
from requests import Response
from attendances.models import Attendee
from rest_framework import generics,status


class BaseBodySurvey(models.Model):
    attendee=models.ForeignKey(Attendee, verbose_name='attendee', on_delete=models.CASCADE,null=False, blank=False)
    height=models.DecimalField(verbose_name='height',max_digits=4, decimal_places=1, blank=False, null=False)
    weight=models.DecimalField(verbose_name='weight', max_digits=4, decimal_places=1, blank=False, null=False)
    BMI=models.DecimalField(verbose_name='BMI', max_digits=4, default=0.0, decimal_places=1, blank=False, null=True)
    created_at=models.DateTimeField(auto_now_add=True, null=True)
    def __str__(self):
        return str(self.attendee)
    
# @receiver(pre_save, sender=BaseBodySurvey)
# def check_last_record(sender, instance, **kwargs):
#     user=instance.attendee
#     now=timezone.now()
#     last_record=BaseBodySurvey.objects.filter(attendee=user).order_by('-created_at').first()
#     if last_record and (now - last_record.created_at).days < 30:
#         return ValueError("you can only submit your data once a month")
    
@receiver(pre_save, sender=BaseBodySurvey)
def set_BMI(sender, instance, **kwargs):
    if instance.height>0:
       instance.BMI = float(instance.weight / (instance.height/100)**2)

@receiver(post_save, sender=BaseBodySurvey)
def set_points_for_survey(sender, created, instance, **kwargs):
    if created:
        user= instance.attendee.user
        user.points += 1
        user.save()

@receiver(post_save, sender=BaseBodySurvey)
def set_last_survey_date(sender, created, instance, **kwargs):
    if created:
        attendee = instance.attendee
        attendee.last_survey_date = instance.created_at
        attendee.save()



class Question(models.Model):
    TYPE_CHOICES=[
        (0, 'Somatic symptoms'),
        (1, 'Anxiety and insomnia'),
        (2, 'Social dysfunction'),
        (3, 'Severe depression')
    ]

    QUESTION_CHOICES=[
        (0, 'Been feeling bad and in bad health?'),
        (1, 'Been feeling in need of a good tonic?'),
        (2, 'Been feeling run down and out of sorts?'),
        (3, 'Been feeling that you are ill?'),
        (4, 'Been getting any pains in your head?'),
        (5, 'Been getting a feeling of tightness or pressure in your head?'),
        (6, 'Been having hot or cold spells?'),
        (7, 'Been losing much sleep over worry?'),
        (8, 'Been having difficulty in staying asleep once you fall asleep?'),
        (9, 'Been feeling constantly under strain?'),
        (10, 'Been getting edgy or bad tempered?'),
        (11, 'Been getting scared or panicky for no reason?'),
        (12, 'Been feeling everything is getting on top of you?'),
        (13, 'Been feeling nervous and strung-out all the time?'),
        (14, 'Been managing to keep yourself busy and occupied?'),
        (15, 'Been taking longer over the things you do?'),
        (16, 'Been feeling on the whole that you were doing things well?'),
        (17, 'Been satisfied with the way you have carried out your tasks?'),
        (18, 'Been feeling that you are playing a useful part in things?'),
        (19, 'Been feeling capable of making decisions about things?'),
        (20, 'Been able to enjoy your normal day-to-day activities?'),
        (21, 'Been thinking of yourself as a worthless person?'),
        (22, 'Been feeling that life is entirely hopeless?'),
        (23, 'Been feeling that life is not worth living?'),
        (24, 'Been thinking of the possibility that you may do away with yourself?'),
        (25, 'Been feeling at times that you could not do anything because your nerves were too bad?'),
        (26, 'Been finding yourself wishing you were dead and away from it all?'),
        (27, 'Been finding that the idea of taking your own life keeps coming into your mind?'),
    ]

    question = models.IntegerField(verbose_name='question', choices=QUESTION_CHOICES, blank=False, null=False)
    order = models.IntegerField()
    type =models.IntegerField(verbose_name='type', choices=TYPE_CHOICES, blank=True, null=True)

    def __str__(self):
        type_display = dict(self.TYPE_CHOICES).get(self.type, 'Unknown')
        question_display = dict(self.QUESTION_CHOICES).get(self.question, 'Unknown')
        return f"{self.order} - {type_display} - {question_display}"
    
class SurveyResponse(models.Model):
    
    RESPONSE_CHOICES=[
        (0,  'Better than usual'),
        (1,  'Same as usual'),
        (2, 'Worse than usual'),
        (3, 'Much worse than usual')
    ]
    response0=models.IntegerField(verbose_name='response0', choices=RESPONSE_CHOICES, blank=False, null=False)
    score0 = models.IntegerField(verbose_name='score0', blank=True, null=True,)
    response1=models.IntegerField(verbose_name='response1', choices=RESPONSE_CHOICES, blank=False, null=False)
    score1 = models.IntegerField(verbose_name='score1', blank=True, null=True,)
    response2=models.IntegerField(verbose_name='response2', choices=RESPONSE_CHOICES, blank=False, null=False)
    score2 = models.IntegerField(verbose_name='score2',  blank=True, null=True,)
    response3=models.IntegerField(verbose_name='response3', choices=RESPONSE_CHOICES, blank=False, null=False)
    score3 = models.IntegerField(verbose_name='score3',  blank=True, null=True,)
    response4=models.IntegerField(verbose_name='response4', choices=RESPONSE_CHOICES, blank=False, null=False)
    score4 = models.IntegerField(verbose_name='score4',  blank=True, null=True,)
    response5=models.IntegerField(verbose_name='response5', choices=RESPONSE_CHOICES, blank=False, null=False)
    score5 = models.IntegerField(verbose_name='score5',  blank=True, null=True,)
    response6=models.IntegerField(verbose_name='response6', choices=RESPONSE_CHOICES, blank=False, null=False)
    score6 = models.IntegerField(verbose_name='score6',  blank=True, null=True,)
    response7=models.IntegerField(verbose_name='response7', choices=RESPONSE_CHOICES, blank=False, null=False)
    score7 = models.IntegerField(verbose_name='score7',  blank=True, null=True,)
    response8=models.IntegerField(verbose_name='response8', choices=RESPONSE_CHOICES, blank=False, null=False)
    score8 = models.IntegerField(verbose_name='score8',  blank=True, null=True,)
    response9=models.IntegerField(verbose_name='response9', choices=RESPONSE_CHOICES, blank=False, null=False)
    score9 = models.IntegerField(verbose_name='score9',  blank=True, null=True,)
    response10=models.IntegerField(verbose_name='response10', choices=RESPONSE_CHOICES, blank=False, null=False)
    score10 = models.IntegerField(verbose_name='score10',  blank=True, null=True,)
    response11=models.IntegerField(verbose_name='response11', choices=RESPONSE_CHOICES, blank=False, null=False)
    score11 = models.IntegerField(verbose_name='score11',  blank=True, null=True,)
    response12=models.IntegerField(verbose_name='response12', choices=RESPONSE_CHOICES, blank=False, null=False)
    score12 = models.IntegerField(verbose_name='score12',  blank=True, null=True,)
    response13=models.IntegerField(verbose_name='response13', choices=RESPONSE_CHOICES, blank=False, null=False)
    score13 = models.IntegerField(verbose_name='score13',  blank=True, null=True,)
    response14=models.IntegerField(verbose_name='response14', choices=RESPONSE_CHOICES, blank=False, null=False)
    score14 = models.IntegerField(verbose_name='score14',  blank=True, null=True,)
    response15=models.IntegerField(verbose_name='response15', choices=RESPONSE_CHOICES, blank=False, null=False)
    score15 = models.IntegerField(verbose_name='score15',  blank=True, null=True,)
    response16=models.IntegerField(verbose_name='response16', choices=RESPONSE_CHOICES, blank=False, null=False)
    score16 = models.IntegerField(verbose_name='score16',  blank=True, null=True,)
    response17=models.IntegerField(verbose_name='response17', choices=RESPONSE_CHOICES, blank=False, null=False)
    score17 = models.IntegerField(verbose_name='score17',  blank=True, null=True,)
    response18=models.IntegerField(verbose_name='response18', choices=RESPONSE_CHOICES, blank=False, null=False)
    score18 = models.IntegerField(verbose_name='score18', blank=True, null=True,)
    response19=models.IntegerField(verbose_name='response19', choices=RESPONSE_CHOICES, blank=False, null=False)
    score19 = models.IntegerField(verbose_name='score19',  blank=True, null=True,)
    response20=models.IntegerField(verbose_name='response20', choices=RESPONSE_CHOICES, blank=False, null=False)
    score20 = models.IntegerField(verbose_name='score20',  blank=True, null=True,)
    response21=models.IntegerField(verbose_name='response21', choices=RESPONSE_CHOICES, blank=False, null=False)
    score21 = models.IntegerField(verbose_name='score21', blank=True, null=True,)
    response22=models.IntegerField(verbose_name='response22', choices=RESPONSE_CHOICES, blank=False, null=False)
    score22 = models.IntegerField(verbose_name='score22',  blank=True, null=True,)
    response23=models.IntegerField(verbose_name='response23', choices=RESPONSE_CHOICES, blank=False, null=False)
    score23 = models.IntegerField(verbose_name='score23',  blank=True, null=True,)
    response24=models.IntegerField(verbose_name='response24', choices=RESPONSE_CHOICES, blank=False, null=False)
    score24 = models.IntegerField(verbose_name='score24',  blank=True, null=True,)
    response25=models.IntegerField(verbose_name='response25', choices=RESPONSE_CHOICES, blank=False, null=False)
    score25 = models.IntegerField(verbose_name='score25',  blank=True, null=True,)
    response26=models.IntegerField(verbose_name='response26', choices=RESPONSE_CHOICES, blank=False, null=False)
    score26 = models.IntegerField(verbose_name='score26',  blank=True, null=True,)
    response27=models.IntegerField(verbose_name='response27', choices=RESPONSE_CHOICES, blank=False, null=False)
    score27 = models.IntegerField(verbose_name='score27',  blank=True, null=True,)

    attendee=models.ForeignKey(Attendee, verbose_name='attendee', on_delete=models.CASCADE,null=False, blank=False)
    total_score = total_score = models.IntegerField(default =0)
    created_at=models.DateTimeField(auto_now_add=True, blank=True, null=True)

    def __str__(self):
        return f"{self.created_at} - {self.attendee}" 

@receiver(pre_save, sender=SurveyResponse)
def convert_response_to_score(sender, instance, **kwargs):
    response_fields = [f'response{i}' for i in range(0, 28)]
    score_fields = [f'score{i}' for i in range(0, 28)]

    for response_field, score_field in zip(response_fields, score_fields):
        response_value = getattr(instance, response_field)
        score_value = 0 if response_value in [0, 1] else 1
        setattr(instance, score_field, score_value)


@receiver(pre_save, sender=SurveyResponse)
def calc_total_score(sender, instance, **kwargs):
    sum_total_score = sum(getattr(instance, f'score{i}') for i in range(0,28))
    instance.total_score = sum_total_score