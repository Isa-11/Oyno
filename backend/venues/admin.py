from django.contrib import admin
from .models import Venue, TimeSlot


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


@admin.register(TimeSlot)
class TimeSlotAdmin(admin.ModelAdmin):
    list_display = ('venue', 'start_time', 'end_time', 'is_booked')
    list_filter = ('is_booked', 'venue')
    list_editable = ('is_booked',)
    search_fields = ('venue__name',)
    date_hierarchy = 'start_time'
