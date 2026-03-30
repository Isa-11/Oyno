from django.contrib import admin
from .models import Game, GameParticipant


class GameParticipantInline(admin.TabularInline):
    model = GameParticipant
    extra = 0
    readonly_fields = ('user', 'joined_at')


@admin.register(Game)
class GameAdmin(admin.ModelAdmin):
    list_display = ('__str__', 'sport', 'venue_name', 'date', 'time', 'level', 'status', 'current_players_count', 'max_players')
    list_filter = ('sport', 'status', 'level', 'date')
    search_fields = ('venue_name', 'creator__username')
    readonly_fields = ('created_at', 'current_players_count', 'slots_needed')
    inlines = [GameParticipantInline]


@admin.register(GameParticipant)
class GameParticipantAdmin(admin.ModelAdmin):
    list_display = ('user', 'game', 'joined_at')
    list_filter = ('game__sport',)
