from rest_framework import serializers
from .models import Game, GameParticipant


class GameSerializer(serializers.ModelSerializer):
    sport_emoji = serializers.ReadOnlyField()
    current_players_count = serializers.ReadOnlyField()
    slots_needed = serializers.ReadOnlyField()
    creator_username = serializers.CharField(source='creator.username', read_only=True)
    is_joined = serializers.SerializerMethodField()
    is_creator = serializers.SerializerMethodField()

    class Meta:
        model = Game
        fields = [
            'id', 'creator_username', 'sport', 'sport_emoji',
            'venue_name', 'location', 'date', 'time', 'level',
            'max_players', 'current_players_count', 'slots_needed',
            'status', 'created_at', 'is_joined', 'is_creator',
        ]
        read_only_fields = ['id', 'created_at', 'status']

    def get_is_joined(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.participants.filter(user=request.user).exists()
        return False

    def get_is_creator(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.creator == request.user
        return False

    def create(self, validated_data):
        validated_data['creator'] = self.context['request'].user
        game = super().create(validated_data)
        # Автоматически обновляем статус если мест нет
        if game.slots_needed == 0:
            game.status = 'full'
            game.save()
        return game
