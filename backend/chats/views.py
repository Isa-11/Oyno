from django.contrib.auth.models import User
from django.db.models import Q
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from games.models import GameParticipant
from .models import GameChat, DirectChat, Message
from .serializers import MessageSerializer, ChatListItemSerializer


def _fmt_time(dt):
    if dt is None:
        return ''
    return dt.strftime('%H:%M')


def _unread_count(messages_qs, user):
    return messages_qs.exclude(sender=user).exclude(read_by=user).count()


class ChatListView(APIView):
    """GET /api/chats/ — все чаты пользователя"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        me = request.user
        result = []

        # Игровые чаты (создатель или участник)
        my_game_ids = set(GameParticipant.objects.filter(user=me).values_list('game_id', flat=True))
        my_game_ids |= set(GameChat.objects.filter(game__creator=me).values_list('game_id', flat=True))
        game_chats = GameChat.objects.filter(game_id__in=my_game_ids).select_related('game__creator')

        for gc in game_chats:
            last_msg = gc.messages.last()
            result.append({
                'id': gc.id,
                'type': 'game',
                'name': f"{gc.game.creator.username} • {gc.game.sport_emoji} {gc.game.date}",
                'sport_emoji': gc.game.sport_emoji,
                'last_message': last_msg.text if last_msg else 'Чат создан',
                'last_message_time': _fmt_time(last_msg.created_at) if last_msg else '',
                'unread_count': _unread_count(gc.messages, me),
                'game_id': gc.game_id,
                'other_user_id': None,
                'other_username': None,
            })

        # Личные чаты
        direct_chats = DirectChat.objects.filter(Q(user1=me) | Q(user2=me)).select_related('user1', 'user2')
        for dc in direct_chats:
            other = dc.other_user(me)
            last_msg = dc.messages.last()
            result.append({
                'id': dc.id,
                'type': 'direct',
                'name': other.username.upper(),
                'sport_emoji': '💬',
                'last_message': last_msg.text if last_msg else 'Напишите первым',
                'last_message_time': _fmt_time(last_msg.created_at) if last_msg else '',
                'unread_count': _unread_count(dc.messages, me),
                'game_id': None,
                'other_user_id': other.id,
                'other_username': other.username,
            })

        result.sort(key=lambda x: x['last_message_time'], reverse=True)
        return Response(ChatListItemSerializer(result, many=True).data)


class GameChatMessagesView(APIView):
    """GET /api/chats/game/<game_id>/  POST /api/chats/game/<game_id>/"""
    permission_classes = [IsAuthenticated]

    def _get_chat(self, game_id, user):
        try:
            gc = GameChat.objects.select_related('game__creator').get(game_id=game_id)
        except GameChat.DoesNotExist:
            return None, Response({'detail': 'Чат не найден'}, status=404)
        is_member = (
            gc.game.creator_id == user.id or
            GameParticipant.objects.filter(game_id=game_id, user=user).exists()
        )
        if not is_member:
            return None, Response({'detail': 'Нет доступа'}, status=403)
        return gc, None

    def get(self, request, game_id):
        gc, err = self._get_chat(game_id, request.user)
        if err:
            return err
        messages = gc.messages.select_related('sender').all()
        for msg in messages:
            if msg.sender_id != request.user.id:
                msg.read_by.add(request.user)
        return Response(MessageSerializer(messages, many=True, context={'request': request}).data)

    def post(self, request, game_id):
        gc, err = self._get_chat(game_id, request.user)
        if err:
            return err
        text = request.data.get('text', '').strip()
        if not text:
            return Response({'detail': 'Текст пустой'}, status=400)
        msg = Message.objects.create(game_chat=gc, sender=request.user, text=text)
        msg.read_by.add(request.user)
        return Response(MessageSerializer(msg, context={'request': request}).data, status=201)


class DirectChatView(APIView):
    """GET /api/chats/direct/<user_id>/  POST /api/chats/direct/<user_id>/"""
    permission_classes = [IsAuthenticated]

    def _get_other(self, user_id, me):
        try:
            other = User.objects.get(pk=user_id)
        except User.DoesNotExist:
            return None, Response({'detail': 'Пользователь не найден'}, status=404)
        if other == me:
            return None, Response({'detail': 'Нельзя писать себе'}, status=400)
        return other, None

    def get(self, request, user_id):
        other, err = self._get_other(user_id, request.user)
        if err:
            return err
        dc = DirectChat.get_or_create_for(request.user, other)
        messages = dc.messages.select_related('sender').all()
        for msg in messages:
            if msg.sender_id != request.user.id:
                msg.read_by.add(request.user)
        return Response(MessageSerializer(messages, many=True, context={'request': request}).data)

    def post(self, request, user_id):
        other, err = self._get_other(user_id, request.user)
        if err:
            return err
        text = request.data.get('text', '').strip()
        if not text:
            return Response({'detail': 'Текст пустой'}, status=400)
        dc = DirectChat.get_or_create_for(request.user, other)
        msg = Message.objects.create(direct_chat=dc, sender=request.user, text=text)
        msg.read_by.add(request.user)
        return Response(MessageSerializer(msg, context={'request': request}).data, status=201)


class UserListView(APIView):
    """GET /api/chats/users/ — список пользователей для поиска"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        query = request.query_params.get('q', '').strip()
        users = User.objects.exclude(id=request.user.id)
        if query:
            users = users.filter(username__icontains=query)
        users = users.order_by('username').values('id', 'username')[:20]
        return Response(list(users))
