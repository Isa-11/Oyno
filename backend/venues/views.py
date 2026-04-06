import datetime
from rest_framework import permissions, viewsets, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Venue
from .serializers import VenueSerializer

class IsOwnerOrReadOnly(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.owner == request.user

class VenueViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticatedOrReadOnly, IsOwnerOrReadOnly]
    queryset = Venue.objects.all()
    serializer_class = VenueSerializer
    filter_backends = [filters.SearchFilter]
    search_fields = ['sport', 'name']

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)

    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def my(self, request):
        qs = self.get_queryset().filter(owner=request.user)
        serializer = self.get_serializer(qs, many=True)
        return Response(serializer.data)

    def get_queryset(self):
        qs = super().get_queryset()
        sport = self.request.query_params.get('sport')
        if sport:
            qs = qs.filter(sport__icontains=sport)
        return qs

    @action(detail=True, methods=['get'], url_path='slots')
    def slots(self, request, pk=None):
        """GET /api/venues/{id}/slots/?date=2025-10-24"""
        venue = self.get_object()
        date_str = request.query_params.get('date')
        if not date_str:
            return Response({'detail': 'Укажите параметр date (YYYY-MM-DD)'}, status=400)
        try:
            target_date = datetime.date.fromisoformat(date_str)
        except ValueError:
            return Response({'detail': 'Неверный формат даты'}, status=400)

        # Занятые слоты из игр
        from games.models import Game
        busy = set(
            Game.objects.filter(venue=venue, date=target_date)
            .exclude(status='finished')
            .values_list('time', flat=True)
        )
        # Занятые слоты из букингов
        from bookings.models import Booking
        busy |= set(
            Booking.objects.filter(venue=venue, date=target_date)
            .exclude(status='cancelled')
            .values_list('time_slot', flat=True)
        )

        # Генерируем слоты час за часом
        slots = []
        current = datetime.datetime.combine(target_date, venue.opens_at)
        end = datetime.datetime.combine(target_date, venue.closes_at)
        while current < end:
            t = current.strftime('%H:%M')
            slots.append({'time': t, 'available': t not in busy})
            current += datetime.timedelta(hours=1)

        return Response({
            'venue_id': venue.id,
            'date': date_str,
            'opens_at': venue.opens_at.strftime('%H:%M'),
            'closes_at': venue.closes_at.strftime('%H:%M'),
            'slots': slots,
        })
