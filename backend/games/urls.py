from django.urls import path
from .views import GameListCreateView, MyGamesView, MyGamesHistoryView, GameJoinView

urlpatterns = [
    path('', GameListCreateView.as_view(), name='games'),
    path('my/', MyGamesView.as_view(), name='my-games'),
    path('history/', MyGamesHistoryView.as_view(), name='games-history'),
    path('<int:pk>/join/', GameJoinView.as_view(), name='game-join'),
]
