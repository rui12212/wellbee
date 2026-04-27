
from django import forms


class StaffLoginForm(forms.Form):
    phone_number = forms.CharField(max_length=16)
    password = forms.CharField(widget=forms.PasswordInput)