from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone


class Venue(models.Model):
    SPORT_CHOICES = [
        ('football', 'Футбол'),
        ('basketball', 'Баскетбол'),
        ('volleyball', 'Волейбол'),
        ('tennis', 'Теннис'),
        ('swimming', 'Плавание'),
        ('other', 'Другое'),
    ]

    owner = models.ForeignKey(
        User, on_delete=models.SET_NULL, null=True, blank=True, related_name='owned_venues'
    )
    name = models.CharField(max_length=200)
    address = models.CharField(max_length=300)
    description = models.TextField(blank=True)
    sport = models.CharField(max_length=50, choices=SPORT_CHOICES)
    price_per_hour = models.DecimalField(max_digits=8, decimal_places=2)
    # Несколько фото через запятую (URL)
    image_url = models.URLField(max_length=500, blank=True)
    rating = models.DecimalField(max_digits=3, decimal_places=1, default=0.0)
    opens_at = models.TimeField(default='07:00')   # начало работы
    closes_at = models.TimeField(default='23:00')  # конец работы

    class Meta:
        ordering = ['-rating']

    def __str__(self):
        return self.name


class Review(models.Model):
    """Отзывы о площадках"""
    venue = models.ForeignKey(Venue, on_delete=models.CASCADE, related_name='reviews')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='venue_reviews')
    rating = models.IntegerField(choices=[(i, i) for i in range(1, 6)])
    text = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
        unique_together = ('venue', 'user')

    def __str__(self):
        return f'{self.user.username} - {self.venue.name} ({self.rating}★)'


class TimeSlot(models.Model):
    venue = models.ForeignKey(Venue, on_delete=models.CASCADE, related_name='time_slots')
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()
    is_booked = models.BooleanField(default=False)

    class Meta:
        ordering = ['start_time']

    def __str__(self):
        status = 'забронирован' if self.is_booked else 'свободен'
        return f'{self.venue.name} | {self.start_time:%d.%m %H:%M}–{self.end_time:%H:%M} ({status})'
