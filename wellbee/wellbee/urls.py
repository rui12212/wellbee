from django.contrib import admin
from django.urls import path,include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('wellbee_122024/', admin.site.urls),
    path('api/v4/accounts/', include('accounts.urls')),
    path('api/v4/attendances/', include('attendances.urls')),
    path('api/v4/questionnaires/', include('questionnaires.urls')),
    path('api/v4/reservations/', include('reservations.urls')),
    path('api/v4/versions/', include('versions.urls')),
    # /authen/jwt/create/にアクセスすることで、phonenumberとpasswordでPOSTするとJWTトークンを返してくれる
    path('api/v4/authen/', include('djoser.urls.jwt')),
    path('accounts/', include('accounts.urls')),
    path('attendances/', include('attendances.urls')),
    path('questionnaires/', include('questionnaires.urls')),
    path('reservations/', include('reservations.urls')),
    path('versions/', include('versions.urls')),
    # /authen/jwt/create/にアクセスすることで、phonenumberとpasswordでPOSTするとJWTトークンを返してくれる
    path('authen/', include('djoser.urls.jwt')),
]
