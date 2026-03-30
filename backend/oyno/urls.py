from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('venues.urls')),
    path('api/auth/', include('accounts.urls')),
    path('api/bookings/', include('bookings.urls')),
    path('api/games/', include('games.urls')),
    path('api/chats/', include('chats.urls')),
]
