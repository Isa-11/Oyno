from django.urls import path
from .views import RegisterView, LoginView, ProfileView, SendOtpView, RegisterPhoneView, ResetPasswordView, SettingsView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('profile/', ProfileView.as_view(), name='profile'),
    path('settings/', SettingsView.as_view(), name='settings'),
    path('send-otp/', SendOtpView.as_view(), name='send-otp'),
    path('register-phone/', RegisterPhoneView.as_view(), name='register-phone'),
    path('reset-password/', ResetPasswordView.as_view(), name='reset-password'),
]
