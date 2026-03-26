from rest_framework import serializers
from .models import Booking


class BookingSerializer(serializers.ModelSerializer):
    venue_name = serializers.CharField(source='venue.name', read_only=True)

    class Meta:
        model = Booking
        fields = ['id', 'venue', 'venue_name', 'date', 'time_slot', 'status', 'created_at']
        read_only_fields = ['status', 'created_at']

    def create(self, validated_data):
        validated_data['user'] = self.context['request'].user
        return super().create(validated_data)
