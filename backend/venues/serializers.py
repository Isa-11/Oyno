from rest_framework import serializers
from .models import Venue, Review


class ReviewSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)

    class Meta:
        model = Review
        fields = ['id', 'username', 'rating', 'text', 'created_at']
        read_only_fields = ['id', 'created_at']


class VenueSerializer(serializers.ModelSerializer):
    # Форматируем цену в строку, как ожидает Flutter: "800 СОМ/ЧАС"
    price = serializers.SerializerMethodField()
    # rating отдаём как float, а не строку
    rating = serializers.FloatField()
    reviews = ReviewSerializer(many=True, read_only=True)

    class Meta:
        model = Venue
        fields = ['id', 'name', 'image_url', 'rating', 'price', 'sport', 'address', 'description', 'opens_at', 'closes_at', 'reviews']

    def get_price(self, obj) -> str:
        amount = int(obj.price_per_hour)
        return f'{amount} СОМ/ЧАС'
