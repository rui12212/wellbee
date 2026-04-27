from django.contrib import admin
from django.utils.translation import gettext as _
from attendances.models import Membership,Course,Attendee,CheckIn

# class AttendancesAdmin(admin.ModelAdmin):
#     # ordering = ['start_day']
#     list_display = ['course_name']
#     fieldsets = (
#         (None, {'fields': ('course_name','original_price')}),
#         (_('Personal Info'), {'fields': ()}),
#     )
#     add_fieldsets = (
#         (None, {
#             'classes': ('wide',),
#             'fields': ('course_name','original_price')
#         }),
#     )
    # readonly_fields = ['start_day'] 

class AttendeeAdmin(admin.ModelAdmin):
    search_fields = ['user__phone_number', 'name']

admin.site.register(Course)
admin.site.register(Membership)
admin.site.register(Attendee, AttendeeAdmin)
admin.site.register(CheckIn)