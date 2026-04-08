from django.urls import path
from .views import NotificationListView, NotificationReadView, NotificationReadAllView

urlpatterns = [
    path('', NotificationListView.as_view(), name='notifications'),
    path('mark-all-read/', NotificationReadAllView.as_view(), name='notifications-read-all'),
    path('<int:pk>/read/', NotificationReadView.as_view(), name='notification-read'),
]
