from django.db import models
from django.contrib.auth.models import User


class GameChat(models.Model):
    """Групповой чат привязанный к игре"""
    game = models.OneToOneField('games.Game', on_delete=models.CASCADE, related_name='chat')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'Chat for game #{self.game_id}'

    def get_members(self):
        from games.models import GameParticipant
        participant_ids = GameParticipant.objects.filter(game=self.game).values_list('user_id', flat=True)
        return User.objects.filter(
            models.Q(id=self.game.creator_id) | models.Q(id__in=participant_ids)
        )


class DirectChat(models.Model):
    """Личный чат между двумя пользователями"""
    user1 = models.ForeignKey(User, on_delete=models.CASCADE, related_name='direct_chats_as_user1')
    user2 = models.ForeignKey(User, on_delete=models.CASCADE, related_name='direct_chats_as_user2')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user1', 'user2')

    def __str__(self):
        return f'Chat: {self.user1.username} <-> {self.user2.username}'

    def other_user(self, me):
        return self.user2 if self.user1_id == me.id else self.user1

    @staticmethod
    def get_or_create_for(user_a, user_b):
        u1, u2 = (user_a, user_b) if user_a.id < user_b.id else (user_b, user_a)
        chat, _ = DirectChat.objects.get_or_create(user1=u1, user2=u2)
        return chat


class Message(models.Model):
    game_chat = models.ForeignKey(
        GameChat, on_delete=models.CASCADE, null=True, blank=True, related_name='messages'
    )
    direct_chat = models.ForeignKey(
        DirectChat, on_delete=models.CASCADE, null=True, blank=True, related_name='messages'
    )
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent_messages')
    text = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    read_by = models.ManyToManyField(User, related_name='read_messages', blank=True)

    class Meta:
        ordering = ['created_at']

    def __str__(self):
        return f'{self.sender.username}: {self.text[:40]}'
