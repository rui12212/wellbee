from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.translation import gettext as _
from . import models
# from attendances.models import Course, Membership

class UserAdmin(BaseUserAdmin):
    ordering = ['id']
    list_display = ['phone_number']
    fieldsets = (
        (None, {'fields': ('phone_number', 'password','points')}),
        (_('Personal Info'), {'fields': ()}),
        (
            _('Permissions'),
            {
                'fields': (
                    'is_active',
                    'is_staff',
                    'is_superuser',
                )
            }
        ),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('phone_number', 'password1', 'password2','points' )
        }),
    )

admin.site.register(models.User, UserAdmin)
admin.site.register(models.Profile)

