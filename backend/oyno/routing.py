from django.urls import re_path
from chats.consumers import ChatConsumer

websocket_urlpatterns = [
    re_path(r'ws/chat/(?P<chat_type>game|direct)/(?P<chat_id>\d+)/$', ChatConsumer.as_asgi()),
]
