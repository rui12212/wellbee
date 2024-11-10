from django.contrib import admin
from django.urls import path,include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('wellbee_122024/', admin.site.urls),
    path('accounts/', include('accounts.urls')),
    path('attendances/', include('attendances.urls')),
    path('questionnaires/', include('questionnaires.urls')),
    path('reservations/', include('reservations.urls')),
    # /authen/jwt/create/にアクセスすることで、phonenumberとpasswordでPOSTするとJWTトークンを返してくれる
    path('authen/', include('djoser.urls.jwt')),
]
