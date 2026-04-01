import random
from datetime import timedelta
from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone


class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    phone = models.CharField(max_length=20, unique=True, null=True, blank=True)
    fcm_token = models.CharField(max_length=500, blank=True, default='')

    def __str__(self):
        return f'{self.user.username} — {self.phone}'


class UserSettings(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='settings')
    notifications = models.BooleanField(default=True)
    dark_theme = models.BooleanField(default=True)
    geolocation = models.BooleanField(default=False)
    privacy = models.BooleanField(default=True)

    def __str__(self):
        return f'Settings({self.user.username})'


class PhoneVerification(models.Model):
    PURPOSES = [('register', 'Регистрация'), ('reset', 'Сброс пароля')]

    phone = models.CharField(max_length=20)
    code = models.CharField(max_length=6)
    purpose = models.CharField(max_length=10, choices=PURPOSES)
    attempts = models.PositiveSmallIntegerField(default=0)
    verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def is_expired(self):
        return timezone.now() > self.created_at + timedelta(minutes=10)

    @staticmethod
    def generate_code():
        return str(random.randint(100000, 999999))
