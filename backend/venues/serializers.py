from rest_framework import serializers
from .models import Venue


class VenueSerializer(serializers.ModelSerializer):
    # Форматируем цену в строку, как ожидает Flutter: "800 СОМ/ЧАС"
    price = serializers.SerializerMethodField()
    # rating отдаём как float, а не строку
    rating = serializers.FloatField()

    class Meta:
        model = Venue
        fields = ['id', 'name', 'image_url', 'rating', 'price', 'sport', 'address', 'description']

    def get_price(self, obj) -> str:
        amount = int(obj.price_per_hour)
        return f'{amount} СОМ/ЧАС'
