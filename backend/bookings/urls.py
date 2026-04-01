from django.urls import path
from .views import BookingListCreateView, BookingCancelView

urlpatterns = [
    path('', BookingListCreateView.as_view(), name='bookings'),
    path('<int:pk>/', BookingCancelView.as_view(), name='booking-cancel'),
]
