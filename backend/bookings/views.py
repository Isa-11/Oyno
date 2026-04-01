from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Booking
from .serializers import BookingSerializer


class BookingListCreateView(generics.ListCreateAPIView):
    """GET /api/bookings/ — мои бронирования  |  POST /api/bookings/ — создать"""
    serializer_class = BookingSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Booking.objects.filter(user=self.request.user).select_related('venue')

    def perform_create(self, serializer):
        venue = serializer.validated_data['venue']
        date = serializer.validated_data['date']
        time_slot = serializer.validated_data['time_slot']

        # Проверяем что слот не занят
        already_booked = Booking.objects.filter(
            venue=venue, date=date, time_slot=time_slot
        ).exclude(status='cancelled').exists()

        if already_booked:
            from rest_framework.exceptions import ValidationError
            raise ValidationError({'detail': 'Этот слот уже занят'})

        serializer.save(user=self.request.user)


class BookingCancelView(APIView):
    """DELETE /api/bookings/{id}/ — отменить бронирование"""
    permission_classes = [IsAuthenticated]

    def delete(self, request, pk):
        try:
            booking = Booking.objects.get(pk=pk, user=request.user)
        except Booking.DoesNotExist:
            return Response({'detail': 'Бронирование не найдено'}, status=status.HTTP_404_NOT_FOUND)

        if booking.status == 'cancelled':
            return Response({'detail': 'Бронирование уже отменено'}, status=status.HTTP_400_BAD_REQUEST)

        booking.status = 'cancelled'
        booking.save(update_fields=['status'])
        return Response(status=status.HTTP_204_NO_CONTENT)
