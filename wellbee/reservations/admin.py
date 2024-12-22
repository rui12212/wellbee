from django.contrib import admin
from django import forms
from django.shortcuts import render, redirect
from reservations.models import Reservation, Slot
from django.contrib.admin.widgets import AdminDateWidget

class SlotForm(forms.ModelForm):
    class Meta:
        model = Slot
        fields = '__all__'
        widgets = {
            'date': AdminDateWidget(),  # フィールド名が 'date' の場合
        }

# class SlotAdmin(admin.ModelAdmin):
#     def add_view(self, request, form_url='', extra_context=None):
#         SlotFormSet = forms.modelformset_factory(Slot, form=SlotForm, extra=10)
#         if request.method == 'POST':
#             formset = SlotFormSet(request.POST, request.FILES)
#             if formset.is_valid():
#                 formset.save()
#                 self.message_user(request, "複数のSlotが正常に作成されました。")
#                 return redirect('..')
#         else:
#             formset = SlotFormSet(queryset=Slot.objects.none())

#         context = {
#             'formset': formset,
#             'opts': self.model._meta,
#             'app_label': self.model._meta.app_label,
#             'title': '複数のSlotを追加',
#             'media': self.media + formset.media,
#         }
#         return render(request, 'admin/add_multiple_slots.html', context)

#     class Media:
#         css = {
#             'all': ('admin/css/widgets.css',),
#         }
#         js = ('admin/js/calendar.js', 'admin/js/admin/DateTimeShortcuts.js',)

admin.site.register(Slot)
admin.site.register(Reservation)

