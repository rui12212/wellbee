from django.contrib import admin
from django.utils.translation import gettext as _
from reservations.models import Slot, Reservation

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

admin.site.register(Slot)
admin.site.register(Reservation)