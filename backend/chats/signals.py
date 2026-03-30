from django.db.models.signals import post_save
from django.dispatch import receiver
from games.models import Game
from .models import GameChat


@receiver(post_save, sender=Game)
def create_game_chat(sender, instance, created, **kwargs):
    if created:
        GameChat.objects.get_or_create(game=instance)
