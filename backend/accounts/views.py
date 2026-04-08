from django.contrib.auth import authenticate
from django.utils import timezone
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.throttling import AnonRateThrottle
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import RegisterSerializer
from .models import PhoneVerification, UserProfile, UserSettings
from .sms import send_sms


class OtpRateThrottle(AnonRateThrottle):
    rate = '3/hour'


class RegisterView(APIView):
    permission_classes = [AllowAny]
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        user = serializer.save()
        refresh = RefreshToken.for_user(user)
        return Response({
            'user': {'id': user.id, 'username': user.username, 'email': user.email},
            'access': str(refresh.access_token),
            'refresh': str(refresh),
        }, status=status.HTTP_201_CREATED)


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        login = (request.data.get('username') or request.data.get('login') or '').strip()
        password = request.data.get('password') or ''

        if not login or not password:
            return Response(
                {'detail': 'Введите логин и пароль'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Support auth by username, phone number, or email.
        candidates = [login]
        if '@' in login:
            from django.contrib.auth.models import User
            found = User.objects.filter(email__iexact=login).values_list('username', flat=True).first()
            if found:
                candidates.append(found)
        else:
            profile = UserProfile.objects.select_related('user').filter(phone=login).first()
            if profile:
                candidates.append(profile.user.username)

        user = None
        for username in dict.fromkeys(candidates):
            user = authenticate(username=username, password=password)
            if user is not None:
                break

        if user is None:
            return Response(
                {'detail': 'Неверный логин или пароль'},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        refresh = RefreshToken.for_user(user)
        return Response({
            'user': {'id': user.id, 'username': user.username, 'email': user.email},
            'access': str(refresh.access_token),
            'refresh': str(refresh),
        })


class ProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        today = timezone.now().date()
        profile, _ = UserProfile.objects.get_or_create(user=user)

        from games.models import Game, GameParticipant
        joined_ids = GameParticipant.objects.filter(user=user).values_list('game_id', flat=True)
        created_ids = Game.objects.filter(creator=user).values_list('id', flat=True)
        all_ids = set(list(joined_ids) + list(created_ids))

        games_total = Game.objects.filter(id__in=all_ids, date__lt=today).count()
        upcoming = Game.objects.filter(id__in=all_ids, date__gte=today).count()

        return Response({
            'id': user.id,
            'username': user.username,
            'email': user.email or '',
            'city': profile.city or '',
            'avatar_data': profile.avatar_data or '',
            'rating': float(profile.rating or 0.0),
            'games_total': games_total,
            'upcoming_games': upcoming,
            'is_vendor': profile.is_vendor,
            'game_level': profile.game_level or '',
            'position': profile.position or '',
        })

    def patch(self, request):
        user = request.user
        username = request.data.get('username', '').strip()
        email = request.data.get('email', '').strip()
        fcm_token = request.data.get('fcm_token', '').strip()
        city = request.data.get('city', '').strip()
        avatar_data = request.data.get('avatar_data', '').strip()
        game_level = request.data.get('game_level', '').strip()
        position = request.data.get('position', '').strip()

        if username and username != user.username:
            from django.contrib.auth.models import User
            if User.objects.filter(username=username).exclude(pk=user.pk).exists():
                return Response({'detail': 'Имя уже занято'}, status=400)
            user.username = username

        if email:
            user.email = email

        user.save()

        profile, _ = UserProfile.objects.get_or_create(user=user)

        if fcm_token:
            profile.fcm_token = fcm_token
        if 'city' in request.data:
            profile.city = city
        if 'avatar_data' in request.data:
            profile.avatar_data = avatar_data
        if 'game_level' in request.data:
            profile.game_level = game_level
        if 'position' in request.data:
            profile.position = position
        if 'is_vendor' in request.data:
            profile.is_vendor = bool(request.data['is_vendor'])
        profile.save()

        return Response({
            'id': user.id,
            'username': user.username,
            'email': user.email or '',
            'city': profile.city or '',
            'avatar_data': profile.avatar_data or '',
            'rating': float(profile.rating or 0.0),
            'is_vendor': profile.is_vendor,
            'game_level': profile.game_level or '',
            'position': profile.position or '',
        })


class SendOtpView(APIView):
    """
    POST /api/auth/send-otp/
    {"phone": "+996700123456", "purpose": "register"|"reset"}
    """
    permission_classes = [AllowAny]
    throttle_classes = [OtpRateThrottle]

    def post(self, request):
        phone = request.data.get('phone', '').strip()
        purpose = request.data.get('purpose', '')

        if not phone:
            return Response({'detail': 'Укажите номер телефона'}, status=400)
        if purpose not in ('register', 'reset'):
            return Response({'detail': 'Неверный тип запроса'}, status=400)

        if purpose == 'register':
            if UserProfile.objects.filter(phone=phone).exists():
                return Response({'detail': 'Этот номер уже зарегистрирован'}, status=400)

        if purpose == 'reset':
            if not UserProfile.objects.filter(phone=phone).exists():
                return Response({'detail': 'Номер не найден'}, status=404)

        # Удаляем старые коды для этого номера+цели
        PhoneVerification.objects.filter(phone=phone, purpose=purpose).delete()

        code = PhoneVerification.generate_code()
        PhoneVerification.objects.create(phone=phone, code=code, purpose=purpose)

        msg = f'Oyno: ваш код подтверждения — {code}. Действителен 10 минут.'
        send_sms(phone, msg)

        return Response({'detail': 'Код отправлен'})


class VerifyOtpView(APIView):
    """
    POST /api/auth/verify-otp/
    {"phone": "+996700123456", "code": "123456", "purpose": "register"|"reset"}
    Проверяет код без создания пользователя. Используется на шаге 2 (Flutter).
    """
    permission_classes = [AllowAny]

    def post(self, request):
        phone = request.data.get('phone', '').strip()
        code = request.data.get('code', '').strip()
        purpose = request.data.get('purpose', '')

        if not all([phone, code, purpose]):
            return Response({'detail': 'Заполните все поля'}, status=400)

        error = _verify_code(phone, code, purpose)
        if error:
            return Response({'detail': error}, status=400)

        return Response({'detail': 'Код верный'})


class RegisterPhoneView(APIView):
    permission_classes = [AllowAny]
    """
    POST /api/auth/register-phone/
    {"phone": "+996700123456", "code": "123456", "username": "...", "password": "..."}
    """
    def post(self, request):
        phone = request.data.get('phone', '').strip()
        code = request.data.get('code', '').strip()
        username = request.data.get('username', '').strip()
        password = request.data.get('password', '')

        if not all([phone, code, username, password]):
            return Response({'detail': 'Заполните все поля'}, status=400)

        if len(password) < 6:
            return Response({'detail': 'Пароль минимум 6 символов'}, status=400)

        error = _verify_code(phone, code, 'register')
        if error:
            return Response({'detail': error}, status=400)

        from django.contrib.auth.models import User
        if User.objects.filter(username=username).exists():
            return Response({'detail': 'Имя пользователя уже занято'}, status=400)

        user = User.objects.create_user(username=username, password=password)
        UserProfile.objects.create(user=user, phone=phone)

        PhoneVerification.objects.filter(phone=phone, purpose='register').delete()

        refresh = RefreshToken.for_user(user)
        return Response({
            'user': {'id': user.id, 'username': user.username, 'email': ''},
            'access': str(refresh.access_token),
            'refresh': str(refresh),
        }, status=201)


class ResetPasswordView(APIView):
    permission_classes = [AllowAny]
    """
    POST /api/auth/reset-password/
    {"phone": "+996700123456", "code": "123456", "new_password": "..."}
    """
    def post(self, request):
        phone = request.data.get('phone', '').strip()
        code = request.data.get('code', '').strip()
        new_password = request.data.get('new_password', '')

        if not all([phone, code, new_password]):
            return Response({'detail': 'Заполните все поля'}, status=400)

        if len(new_password) < 6:
            return Response({'detail': 'Пароль минимум 6 символов'}, status=400)

        error = _verify_code(phone, code, 'reset')
        if error:
            return Response({'detail': error}, status=400)

        try:
            profile = UserProfile.objects.select_related('user').get(phone=phone)
        except UserProfile.DoesNotExist:
            return Response({'detail': 'Пользователь не найден'}, status=404)

        profile.user.set_password(new_password)
        profile.user.save()
        PhoneVerification.objects.filter(phone=phone, purpose='reset').delete()

        return Response({'detail': 'Пароль успешно изменён'})


class SettingsView(APIView):
    permission_classes = [IsAuthenticated]

    def _get_or_create(self, user):
        obj, _ = UserSettings.objects.get_or_create(user=user)
        return obj

    def get(self, request):
        s = self._get_or_create(request.user)
        return Response({
            'notifications': s.notifications,
            'dark_theme': s.dark_theme,
            'geolocation': s.geolocation,
            'privacy': s.privacy,
        })

    def patch(self, request):
        s = self._get_or_create(request.user)
        for field in ('notifications', 'dark_theme', 'geolocation', 'privacy'):
            if field in request.data:
                setattr(s, field, bool(request.data[field]))
        s.save()
        return Response({
            'notifications': s.notifications,
            'dark_theme': s.dark_theme,
            'geolocation': s.geolocation,
            'privacy': s.privacy,
        })


def _verify_code(phone: str, code: str, purpose: str):
    """Возвращает строку с ошибкой или None при успехе."""
    try:
        otp = PhoneVerification.objects.filter(
            phone=phone, purpose=purpose
        ).latest('created_at')
    except PhoneVerification.DoesNotExist:
        return 'Код не найден. Запросите новый.'

    if otp.is_expired():
        return 'Код устарел. Запросите новый.'

    otp.attempts += 1
    otp.save(update_fields=['attempts'])

    if otp.attempts > 5:
        return 'Превышено число попыток. Запросите новый код.'

    if otp.code != code:
        return 'Неверный код.'

    otp.verified = True
    otp.save(update_fields=['attempts', 'verified'])
    return None


class UserDetailView(APIView):
    """GET /api/auth/users/{pk}/ — публичный профиль другого пользователя"""
    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        from django.contrib.auth.models import User
        try:
            user = User.objects.select_related('profile').get(pk=pk)
        except User.DoesNotExist:
            return Response({'detail': 'Пользователь не найден'}, status=status.HTTP_404_NOT_FOUND)

        profile = getattr(user, 'profile', None)
        return Response({
            'id': user.id,
            'username': user.username,
            'city': profile.city if profile else '',
            'rating': float(profile.rating) if profile else 0.0,
            'game_level': profile.game_level if profile else '',
            'position': profile.position if profile else '',
            'avatar_data': profile.avatar_data if profile else '',
        })
