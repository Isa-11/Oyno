from django.contrib import admin
from django.urls import path, include
from games.views import GroupListView

urlpatterns = [
    path('admin/', admin.site.urls),

    # Auth & Profile
    path('api/auth/', include('accounts.urls')),

    # Venues + slots
    path('api/', include('venues.urls')),

    # Games (list, detail, my, history, join)
    path('api/games/', include('games.urls')),

    # Groups — открытые игры для главного экрана (GET /api/groups/?sport=)
    path('api/groups/', GroupListView.as_view(), name='groups'),

    # Bookings
    path('api/bookings/', include('bookings.urls')),

    # Chats (REST)
    path('api/chats/', include('chats.urls')),

    # Notifications
    path('api/notifications/', include('notifications.urls')),
]
