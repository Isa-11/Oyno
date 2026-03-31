import os
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.security.websocket import AllowedHostsOriginValidator
import oyno.routing

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'oyno.settings')

application = ProtocolTypeRouter({
    'http': get_asgi_application(),
    'websocket': AllowedHostsOriginValidator(
        URLRouter(oyno.routing.websocket_urlpatterns)
    ),
})
