from django.urls import path
from .views import GameListCreateView, GameDetailView, MyGamesView, MyGamesHistoryView, GameJoinView, GroupListView

urlpatterns = [
    path('', GameListCreateView.as_view(), name='games'),
    path('my/', MyGamesView.as_view(), name='my-games'),
    path('history/', MyGamesHistoryView.as_view(), name='games-history'),
    path('<int:pk>/', GameDetailView.as_view(), name='game-detail'),
    path('<int:pk>/join/', GameJoinView.as_view(), name='game-join'),
    # /api/groups/ регистрируется отдельно в oyno/urls.py
    path('groups-list/', GroupListView.as_view(), name='group-list'),
]
