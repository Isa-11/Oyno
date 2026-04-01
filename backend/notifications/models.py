from django.db import models
from django.contrib.auth.models import User


class Notification(models.Model):
    TYPE_CHOICES = [
        ('game_join',    'Кто-то вступил в игру'),
        ('game_full',    'Игра заполнена'),
        ('game_created', 'Новая игра рядом'),
        ('booking',      'Бронирование'),
        ('message',      'Новое сообщение'),
        ('system',       'Системное'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    type = models.CharField(max_length=20, choices=TYPE_CHOICES, default='system')
    title = models.CharField(max_length=200)
    body = models.TextField()
    # Необязательная ссылка на связанный объект (game_id, booking_id, …)
    related_id = models.PositiveIntegerField(null=True, blank=True)
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.user.username} — {self.title}'

    @classmethod
    def send(cls, user, type, title, body, related_id=None):
        """Хелпер для создания уведомления из любого места в коде."""
        return cls.objects.create(
            user=user, type=type, title=title, body=body, related_id=related_id
        )
