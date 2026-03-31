from django.contrib.auth import authenticate
from django.utils import timezone
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import RegisterSerializer
from .models import PhoneVerification, UserProfile
from .sms import send_sms


class RegisterView(APIView):
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
    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')

        user = authenticate(username=username, password=password)
        if user is None:
            return Response(
                {'detail': 'Неверное имя пользователя или пароль'},
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
            'games_total': games_total,
            'upcoming_games': upcoming,
        })

    def patch(self, request):
        user = request.user
        username = request.data.get('username', '').strip()
        email = request.data.get('email', '').strip()

        if username and username != user.username:
            from django.contrib.auth.models import User
            if User.objects.filter(username=username).exclude(pk=user.pk).exists():
                return Response({'detail': 'Имя уже занято'}, status=400)
            user.username = username

        if email:
            user.email = email

        user.save()
        return Response({
            'id': user.id,
            'username': user.username,
            'email': user.email or '',
        })


class SendOtpView(APIView):
    """
    POST /api/auth/send-otp/
    {"phone": "+996700123456", "purpose": "register"|"reset"}
    """
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


class RegisterPhoneView(APIView):
    """
    POST /api/auth/register-phone/
    {"phone": "+996700123456", "code": "123456", "username": "...", "password": "..."}
    """
    def post(self, request):
        phone = request.data.get('phone', '').strip()
        code = request.data.get('code', '').strip()
        username = request.data.get('username', '').strip()
        password = request.data.get('password', '')

        import logging
        logger = logging.getLogger(__name__)
        logger.warning(f'[register-phone] phone={repr(phone)} code={repr(code)} username={repr(username)}')
        print(f'[DEBUG register-phone] phone={repr(phone)} code={repr(code)} username={repr(username)}')
        # Показать все записи OTP в базе для сравнения
        existing = list(PhoneVerification.objects.filter(purpose='register').values('phone', 'code'))
        print(f'[DEBUG register-phone] OTP records in DB: {existing}')

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

    return None
