from django.contrib import admin
from .models import Venue


@admin.register(Venue)
class VenueAdmin(admin.ModelAdmin):
    list_display = ('name', 'sport', 'address', 'price_per_hour', 'rating', 'opens_at', 'closes_at')
    list_filter = ('sport',)
    search_fields = ('name', 'address')
    list_editable = ('rating',)
    fieldsets = (
        ('Основная информация', {
            'fields': ('name', 'sport', 'address', 'description', 'owner')
        }),
        ('Фото и цена', {
            'fields': ('image_url', 'price_per_hour', 'rating')
        }),
        ('Часы работы', {
            'fields': ('opens_at', 'closes_at')
        }),
    )
