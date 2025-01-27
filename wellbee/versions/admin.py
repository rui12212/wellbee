from sys import path
from django.contrib import admin
from django import forms
from versions.models import Version


admin.site.register(Version)