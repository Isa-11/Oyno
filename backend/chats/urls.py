from django.urls import path
from .views import ChatListView, GameChatMessagesView, DirectChatView, UserListView

urlpatterns = [
    path('', ChatListView.as_view()),
    path('game/<int:game_id>/', GameChatMessagesView.as_view()),
    path('direct/<int:user_id>/', DirectChatView.as_view()),
    path('users/', UserListView.as_view()),
]
