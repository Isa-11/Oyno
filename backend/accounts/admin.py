from django.contrib import admin
from .models import UserProfile, UserSettings, PhoneVerification


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "phone", "city", "rating", "is_vendor", "game_level", "position")
    search_fields = ("user__username", "user__email", "phone")
    list_filter = ("is_vendor", "game_level", "position")
    list_editable = ("is_vendor",)
    list_select_related = ("user",)


@admin.register(UserSettings)
class UserSettingsAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "notifications", "dark_theme", "geolocation", "privacy")
    search_fields = ("user__username", "user__email")
    list_filter = ("notifications", "dark_theme", "geolocation", "privacy")
    list_select_related = ("user",)


@admin.register(PhoneVerification)
class PhoneVerificationAdmin(admin.ModelAdmin):
    list_display = ("id", "phone", "purpose", "code", "attempts", "verified", "created_at")
    search_fields = ("phone", "code")
    list_filter = ("purpose", "verified", "created_at")
