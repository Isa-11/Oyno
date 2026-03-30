from django.db import models
from django.contrib.auth.models import User


class Game(models.Model):
    SPORT_EMOJI = {
        'football': '⚽', 'basketball': '🏀',
        'volleyball': '🏐', 'swimming': '🏊', 'tennis': '🎾',
    }

    creator = models.ForeignKey(User, on_delete=models.CASCADE, related_name='created_games')
    sport = models.CharField(max_length=50)
    venue = models.ForeignKey(
        'venues.Venue', on_delete=models.SET_NULL, null=True, blank=True, related_name='games'
    )
    venue_name = models.CharField(max_length=200)
    location = models.CharField(max_length=300, blank=True)
    date = models.DateField()
    time = models.CharField(max_length=10)
    level = models.CharField(max_length=20, default='medium')
    max_players = models.PositiveIntegerField(default=10)
    status = models.CharField(max_length=20, default='open')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    @property
    def sport_emoji(self):
        return self.SPORT_EMOJI.get(self.sport, '🏅')

    @property
    def current_players_count(self):
        return self.participants.count() + 1

    @property
    def slots_needed(self):
        return max(0, self.max_players - self.current_players_count)

    def __str__(self):
        return f'{self.creator.username} — {self.sport} {self.date} {self.time}'


class GameParticipant(models.Model):
    game = models.ForeignKey(Game, on_delete=models.CASCADE, related_name='participants')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='joined_games')
    joined_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('game', 'user')
