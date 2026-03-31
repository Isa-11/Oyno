from django.conf import settings


def send_sms(phone: str, message: str) -> bool:
    """
    Отправляет SMS через Twilio.
    В DEBUG-режиме без реальных ключей — печатает код в консоль.
    """
    account_sid = getattr(settings, 'TWILIO_ACCOUNT_SID', '')
    auth_token = getattr(settings, 'TWILIO_AUTH_TOKEN', '')
    from_number = getattr(settings, 'TWILIO_FROM_NUMBER', '')

    if not account_sid or not auth_token or not from_number:
        # DEV-режим: вывод в консоль вместо реальной отправки
        print(f'\n[SMS → {phone}]: {message}\n')
        return True

    try:
        from twilio.rest import Client
        client = Client(account_sid, auth_token)
        client.messages.create(to=phone, from_=from_number, body=message)
        return True
    except Exception as e:
        print(f'[SMS ERROR] {e}')
        return False
