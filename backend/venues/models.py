from django.db import models


class Venue(models.Model):
    SPORT_CHOICES = [
        ('football', 'Футбол'),
        ('basketball', 'Баскетбол'),
        ('volleyball', 'Волейбол'),
        ('tennis', 'Теннис'),
        ('swimming', 'Плавание'),
        ('other', 'Другое'),
    ]

    name = models.CharField(max_length=200)
    address = models.CharField(max_length=300)
    description = models.TextField(blank=True)
    sport = models.CharField(max_length=50, choices=SPORT_CHOICES)
    price_per_hour = models.DecimalField(max_digits=8, decimal_places=2)
    image_url = models.URLField(max_length=500)
    rating = models.DecimalField(max_digits=3, decimal_places=1, default=0.0)

    class Meta:
        ordering = ['-rating']

    def __str__(self):
        return self.name
