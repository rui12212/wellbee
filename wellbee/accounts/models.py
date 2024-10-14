from django.db import models
from django.conf import settings
# from django.utiles import timezone
# ここからはUser登録時に作成されるカスタムUser作成で必要になるimport
from django.contrib.auth.models import AbstractBaseUser,PermissionsMixin, BaseUserManager
import uuid
from django.core.validators import MinValueValidator, MaxValueValidator
from django.core.validators import RegexValidator
from datetime import datetime, date, timedelta
from dateutil.relativedelta import relativedelta
from django.dispatch import receiver
from django.db.models.signals import pre_save,post_save
from django.core.validators import MinLengthValidator

class UserManager(BaseUserManager):
    def create_user(self, phone_number, password):
        use_in_migrations = True

        if not phone_number:
            raise ValueError('Mobile number must be put')
        user = self.model(phone_number=phone_number)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, phone_number, password):
        user = self.create_user(phone_number, password)
        user.is_staff=True
        user.is_superuser= True
        user.save(using=self._db)
        return user
    
class User(AbstractBaseUser, PermissionsMixin):
    id = models.UUIDField(default=uuid.uuid4, primary_key = True, editable=False,)
    phone_number_regex =  RegexValidator(regex=r'^[0-9]+$', message = ("Tel Number must be entered in the format: '07501234567'. Only 11 digits allowed."))
    phone_number = models.CharField(validators=[phone_number_regex], max_length=11, verbose_name='phone number', unique=True, null=False)
    points = models.IntegerField(default=0, verbose_name='points')
    is_staff = models.BooleanField(default=False,)
    is_active = models.BooleanField(default=True,)
    objects = UserManager()
    USERNAME_FIELD = 'phone_number'
# USERNAME_FIELD = 'phone_number'に入れている項目はrequired fieldsから抜くこと
    REQUIRED_FIELDS= 'password',

    def __str__(self):
        return self.phone_number


class Profile(models.Model):
    GENDER = (
        ('male', 'male'),
        ('female', 'female'),
        ('Not specified', 'Not specified'),
    )
    userProfile=models.OneToOneField(
        settings.AUTH_USER_MODEL, related_name='userProfile',
        on_delete=models.CASCADE
    )
    user_name = models.CharField(max_length=50, verbose_name='name',null=False,)
    gender = models.CharField(verbose_name='gender', max_length=20, choices=GENDER,blank= False, null=False,)
    date_of_birth= models.DateField(verbose_name="date of birth",null=False,)
    created_date = models.DateTimeField(default=datetime.now)

    def __str__(self):
        return self.user_name