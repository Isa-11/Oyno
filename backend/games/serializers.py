from rest_framework import serializers
from .models import Game, GameParticipant


class ParticipantSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)
    user_id = serializers.IntegerField(source='user.id', read_only=True)

    class Meta:
        model = GameParticipant
        fields = ['user_id', 'username', 'joined_at']


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
        if game.slots_needed == 0:
            game.status = 'full'
            game.save()
        return game


class GameDetailSerializer(GameSerializer):
    """Расширенный сериализатор для GET /api/games/{id}/ — включает список участников"""
    participants_list = ParticipantSerializer(source='participants', many=True, read_only=True)
    creator_id = serializers.IntegerField(source='creator.id', read_only=True)

    class Meta(GameSerializer.Meta):
        fields = GameSerializer.Meta.fields + ['creator_id', 'participants_list']
