from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from games.models import GameParticipant
from .models import Notification


@receiver(post_save, sender=GameParticipant)
def notify_on_join(sender, instance, created, **kwargs):
    if not created:
        return

    game = instance.game
    joiner = instance.user
    creator = game.creator

    # Уведомить создателя игры что кто-то вступил
    if creator != joiner:
        Notification.send(
            user=creator,
            type='game_join',
            title='Новый игрок',
            body=f'{joiner.username} вступил в вашу игру ({game.sport_emoji} {game.date} {game.time})',
            related_id=game.id,
        )

    # Если игра заполнена — уведомить всех участников
    if game.slots_needed == 0:
        participant_users = game.participants.exclude(user=joiner).values_list('user', flat=True)
        for uid in list(participant_users) + [creator.id]:
            Notification.send(
                user_id=uid,
                type='game_full',
                title='Игра заполнена',
                body=f'Игра {game.sport_emoji} {game.date} {game.time} собрала всех игроков!',
                related_id=game.id,
            )


@receiver(post_delete, sender=GameParticipant)
def notify_on_leave(sender, instance, **kwargs):
    game = instance.game
    creator = game.creator
    leaver = instance.user

    if creator != leaver:
        Notification.send(
            user=creator,
            type='game_join',
            title='Игрок покинул игру',
            body=f'{leaver.username} вышел из вашей игры ({game.sport_emoji} {game.date} {game.time})',
            related_id=game.id,
        )
