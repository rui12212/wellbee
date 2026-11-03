from django.contrib import admin
from django.urls import path,include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('wellbee_122024/', admin.site.urls),
    # v6（審査用）。app-prod がこのコードで動く
    path('api/v6/accounts/', include('accounts.urls')),
    path('api/v6/attendances/', include('attendances.urls')),
    path('api/v6/questionnaires/', include('questionnaires.urls')),
    path('api/v6/reservations/', include('reservations.urls')),
    path('api/v6/versions/', include('versions.urls')),
    path('api/v6/notifications/', include('notifications.urls')),
    path('api/v6/authen/', include('djoser.urls.jwt')),
    # v5（現行ユーザー）。app-review が本番として動いている間は残す
    path('api/v5/accounts/', include('accounts.urls')),
    path('api/v5/attendances/', include('attendances.urls')),
    path('api/v5/questionnaires/', include('questionnaires.urls')),
    path('api/v5/reservations/', include('reservations.urls')),
    path('api/v5/versions/', include('versions.urls')),
    path('api/v5/notifications/', include('notifications.urls')),
    # /authen/jwt/create/にアクセスすることで、phonenumberとpasswordでPOSTするとJWTトークンを返してくれる
    path('api/v5/authen/', include('djoser.urls.jwt')),
    path('accounts/', include('accounts.urls')),
    path('attendances/', include('attendances.urls')),
    path('questionnaires/', include('questionnaires.urls')),
    path('reservations/', include('reservations.urls')),
    path('versions/', include('versions.urls')),
    # /authen/jwt/create/にアクセスすることで、phonenumberとpasswordでPOSTするとJWTトークンを返してくれる
    path('authen/', include('djoser.urls.jwt')),
]
