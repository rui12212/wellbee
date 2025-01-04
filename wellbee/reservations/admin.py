from sys import path
from django.contrib import admin
from django import forms
from django.shortcuts import render, redirect
from reservations.models import Reservation, Slot
from django.contrib.admin.widgets import AdminDateWidget


admin.site.register(Slot)
admin.site.register(Reservation)

