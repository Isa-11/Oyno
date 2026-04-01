import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from rest_framework_simplejwt.exceptions import InvalidToken, TokenError


class ChatConsumer(AsyncWebsocketConsumer):

    async def connect(self):
        # Аутентификация через JWT из query string: ws://...?token=<access>
        token_str = self.scope['query_string'].decode()
        token_str = dict(
            part.split('=') for part in token_str.split('&') if '=' in part
        ).get('token', '')

        self.user = await self._get_user(token_str)
        if self.user is None:
            await self.close(code=4001)
            return

        # Тип чата: game_<id> или direct_<user_id>
        self.chat_type = self.scope['url_route']['kwargs']['chat_type']
        self.chat_id = self.scope['url_route']['kwargs']['chat_id']
        self.room_name = f'{self.chat_type}_{self.chat_id}'

        # Проверяем доступ
        has_access = await self._check_access()
        if not has_access:
            await self.close(code=4003)
            return

        await self.channel_layer.group_add(self.room_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, 'room_name'):
            await self.channel_layer.group_discard(self.room_name, self.channel_name)

    async def receive(self, text_data):
        data = json.loads(text_data)
        text = data.get('text', '').strip()
        if not text:
            return

        # Сохраняем в БД
        msg = await self._save_message(text)
        if msg is None:
            return

        # Рассылаем всем в комнате
        await self.channel_layer.group_send(
            self.room_name,
            {
                'type': 'chat_message',
                'id': msg['id'],
                'sender_username': msg['sender_username'],
                'is_mine_for': self.user.id,
                'text': msg['text'],
                'time': msg['time'],
            }
        )

    async def chat_message(self, event):
        await self.send(text_data=json.dumps({
            'id': event['id'],
            'sender_username': event['sender_username'],
            'is_mine': event['is_mine_for'] == self.user.id,
            'text': event['text'],
            'time': event['time'],
        }))

    # ── helpers ──────────────────────────────────────────────

    @database_sync_to_async
    def _get_user(self, token_str):
        from django.contrib.auth.models import User
        from rest_framework_simplejwt.tokens import AccessToken
        try:
            token = AccessToken(token_str)
            return User.objects.get(id=token['user_id'])
        except (InvalidToken, TokenError, User.DoesNotExist):
            return None

    @database_sync_to_async
    def _check_access(self):
        from games.models import GameParticipant
        from chats.models import GameChat, DirectChat
        user = self.user

        if self.chat_type == 'game':
            try:
                gc = GameChat.objects.select_related('game').get(game_id=self.chat_id)
                return (
                    gc.game.creator_id == user.id or
                    GameParticipant.objects.filter(game_id=self.chat_id, user=user).exists()
                )
            except GameChat.DoesNotExist:
                return False

        elif self.chat_type == 'direct':
            from django.db.models import Q
            return DirectChat.objects.filter(
                Q(user1=user) | Q(user2=user),
                Q(user1_id=self.chat_id) | Q(user2_id=self.chat_id)
            ).exists()

        return False

    @database_sync_to_async
    def _save_message(self, text):
        from chats.models import GameChat, DirectChat, Message

        try:
            if self.chat_type == 'game':
                gc = GameChat.objects.get(game_id=self.chat_id)
                msg = Message.objects.create(
                    game_chat=gc, sender=self.user, text=text
                )
            else:
                from django.contrib.auth.models import User as U
                other = U.objects.get(id=self.chat_id)
                dc = DirectChat.get_or_create_for(self.user, other)
                msg = Message.objects.create(
                    direct_chat=dc, sender=self.user, text=text
                )
            return {
                'id': msg.id,
                'sender_username': msg.sender.username,
                'text': msg.text,
                'time': msg.created_at.strftime('%H:%M'),
            }
        except Exception:
            return None
