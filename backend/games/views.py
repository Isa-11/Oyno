from django.utils import timezone
from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated, IsAuthenticatedOrReadOnly
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Game, GameParticipant
from .serializers import GameSerializer, GameDetailSerializer


class GameListCreateView(generics.ListCreateAPIView):
    """Все открытые игры / создать игру"""
    serializer_class = GameSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        qs = Game.objects.filter(status='open').select_related('creator').prefetch_related('participants')
        sport = self.request.query_params.get('sport')
        if sport:
            qs = qs.filter(sport=sport)
        return qs


class MyGamesView(generics.ListAPIView):
    """Мои предстоящие игры (создал или вступил)"""
    serializer_class = GameSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        today = timezone.now().date()
        created = Game.objects.filter(creator=user, date__gte=today)
        joined_ids = GameParticipant.objects.filter(user=user).values_list('game_id', flat=True)
        joined = Game.objects.filter(id__in=joined_ids, date__gte=today)
        return (created | joined).distinct().select_related('creator').prefetch_related('participants')


class MyGamesHistoryView(generics.ListAPIView):
    """История моих игр"""
    serializer_class = GameSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        today = timezone.now().date()
        created = Game.objects.filter(creator=user, date__lt=today)
        joined_ids = GameParticipant.objects.filter(user=user).values_list('game_id', flat=True)
        joined = Game.objects.filter(id__in=joined_ids, date__lt=today)
        return (created | joined).distinct().select_related('creator').prefetch_related('participants')


class GameDetailView(generics.RetrieveAPIView):
    """GET /api/games/{id}/ — детали одной игры с участниками"""
    serializer_class = GameDetailSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    queryset = Game.objects.select_related('creator').prefetch_related('participants__user')


class GroupListView(generics.ListAPIView):
    """GET /api/groups/?sport= — открытые игры в формате PlayerGroup для главного экрана"""
    serializer_class = GameSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        qs = Game.objects.filter(status='open').select_related('creator').prefetch_related('participants')
        sport = self.request.query_params.get('sport')
        if sport:
            qs = qs.filter(sport=sport)
        return qs


class GameJoinView(APIView):
    """Вступить в игру"""
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        try:
            game = Game.objects.get(pk=pk, status='open')
        except Game.DoesNotExist:
            return Response({'detail': 'Игра не найдена или уже закрыта'}, status=status.HTTP_404_NOT_FOUND)

        if game.creator == request.user:
            return Response({'detail': 'Вы создатель этой игры'}, status=status.HTTP_400_BAD_REQUEST)

        if game.slots_needed == 0:
            return Response({'detail': 'В игре нет свободных мест'}, status=status.HTTP_400_BAD_REQUEST)

        _, created = GameParticipant.objects.get_or_create(game=game, user=request.user)
        if not created:
            return Response({'detail': 'Вы уже в этой игре'}, status=status.HTTP_400_BAD_REQUEST)

        # Закрыть набор если мест не осталось
        if game.slots_needed == 0:
            game.status = 'full'
            game.save()

        return Response(GameSerializer(game, context={'request': request}).data)

    def delete(self, request, pk):
        """Покинуть игру"""
        try:
            participant = GameParticipant.objects.get(game_id=pk, user=request.user)
        except GameParticipant.DoesNotExist:
            return Response({'detail': 'Вы не участник этой игры'}, status=status.HTTP_404_NOT_FOUND)
        participant.delete()

        # Открыть набор обратно если игра была full
        game = Game.objects.get(pk=pk)
        if game.status == 'full':
            game.status = 'open'
            game.save()

        return Response(status=status.HTTP_204_NO_CONTENT)
