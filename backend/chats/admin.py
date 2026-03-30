from django.contrib import admin
from .models import GameChat, DirectChat, Message


@admin.register(GameChat)
class GameChatAdmin(admin.ModelAdmin):
    list_display = ['id', 'game', 'created_at']


@admin.register(DirectChat)
class DirectChatAdmin(admin.ModelAdmin):
    list_display = ['id', 'user1', 'user2', 'created_at']


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ['id', 'sender', 'text', 'game_chat', 'direct_chat', 'created_at']
