from rest_framework import viewsets, filters
from .models import Venue
from .serializers import VenueSerializer


class VenueViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Venue.objects.all()
    serializer_class = VenueSerializer
    filter_backends = [filters.SearchFilter]
    search_fields = ['sport', 'name']

    def get_queryset(self):
        qs = super().get_queryset()
        sport = self.request.query_params.get('sport')
        if sport:
            qs = qs.filter(sport__icontains=sport)
        return qs
