from django.db import models
from django.conf import settings
from django.utils import timezone
from django.contrib.auth.models import AbstractBaseUser,PermissionsMixin, BaseUserManager
import uuid
from django.core.validators import MinValueValidator, MaxValueValidator
from django.core.validators import RegexValidator
from datetime import datetime, date, timedelta
from dateutil.relativedelta import relativedelta
from django.dispatch import receiver
from django.db.models.signals import pre_save,post_save
from django.core.validators import MinLengthValidator
from .normalizer import normalize_phone

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

    def get_by_natural_key(self, username):
        """authenticate() 経由のログイン時、入力された電話番号を E.164 に正規化
        してからルックアップする。これで `+9640111...` でも `0750...` でも
        DB に保存されている `+9647501...` 形式と一致する。"""
        return self.get(phone_number=normalize_phone(username))
    
class User(AbstractBaseUser, PermissionsMixin):
    id = models.UUIDField(default=uuid.uuid4, primary_key = True, editable=False,)
    phone_number_regex =  RegexValidator(regex=r'^\+[0-9]{7,15}$', message = ("Phone number must be in E.164 format: '+9647501234567'."))
    phone_number = models.CharField(validators=[phone_number_regex], max_length=16, verbose_name='phone number', unique=True, null=False)
    points = models.IntegerField(default=0, verbose_name='points')
    is_staff = models.BooleanField(default=False,)
    is_active = models.BooleanField(default=True,)
    objects = UserManager()
    USERNAME_FIELD = 'phone_number'
# USERNAME_FIELD = 'phone_number'に入れている項目はrequired fieldsから抜くこと
    REQUIRED_FIELDS= 'password',

    def save(self, *args, **kwargs):
        """保存前に phone_number を必ず E.164 正規化する。createsuperuser や
        Admin の直接保存からも経由する単一の正規化ポイント。"""
        if self.phone_number:
            self.phone_number = normalize_phone(self.phone_number)
        super().save(*args, **kwargs)

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


class PasswordResetToken(models.Model):
    user = models.ForeignKey(
        'User',
        on_delete=models.CASCADE,
        related_name='password_reset_tokens'
    )
    reset_token = models.UUIDField(default=uuid.uuid4, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)

    def save(self, *args, **kwargs):
        if not self.pk:
            self.expires_at = timezone.now() + timedelta(minutes=30)
        super().save(*args, **kwargs)

    @property
    def is_valid(self):
        return not self.is_used and timezone.now() < self.expires_at

    class Meta:
        indexes = [
            models.Index(fields=['reset_token']),
            models.Index(fields=['user']),
        ]

    def __str__(self):
        return f'PasswordResetToken for {self.user.phone_number}'