from django.contrib.auth.models import User
from rest_framework import serializers
from .models import GameChat, DirectChat, Message


class MessageSerializer(serializers.ModelSerializer):
    sender_username = serializers.CharField(source='sender.username', read_only=True)
    is_mine = serializers.SerializerMethodField()
    time = serializers.SerializerMethodField()

    class Meta:
        model = Message
        fields = ['id', 'sender_username', 'is_mine', 'text', 'time', 'created_at']

    def get_is_mine(self, obj):
        request = self.context.get('request')
        return request and obj.sender_id == request.user.id

    def get_time(self, obj):
        local = obj.created_at
        return local.strftime('%H:%M')


class ChatListItemSerializer(serializers.Serializer):
    """Единый формат для списка чатов (групповые + личные)"""
    id = serializers.IntegerField()
    type = serializers.CharField()        # 'game' | 'direct'
    name = serializers.CharField()
    sport_emoji = serializers.CharField()
    last_message = serializers.CharField()
    last_message_time = serializers.CharField()
    unread_count = serializers.IntegerField()
    game_id = serializers.IntegerField(allow_null=True)
    other_user_id = serializers.IntegerField(allow_null=True)
    other_username = serializers.CharField(allow_null=True)
