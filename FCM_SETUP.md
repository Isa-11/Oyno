# FCM (Firebase Cloud Messaging) Setup Guide

## Статус
- ✅ FCM service реализован в `lib/services/fcm_service.dart`
- ✅ Firebase инициализация включена в `lib/main.dart`
- ❌ **Required**: `google-services.json` в `android/app/`

## Шаги для включения FCM

### 1. Создать Firebase Project
1. Перейти на https://console.firebase.google.com/
2. Нажать "Создать проект"
3. Назвать проект "oyno-sports"
4. Включить Google Analytics (опционально)

### 2. Добавить Android приложение
1. В Firebase Console нажать **+ Добавить приложение** → **Android**
2. Заполнить данные:
   - **Package name**: `com.oyno.sports`
   - **App nickname**: `Oyno Sports Android`
   - SHA-1 отпечаток по желанию
3. Нажать **Зарегистрировать приложение**

### 3. Скачать google-services.json
1. На Firebase Console нажать **Скачать google-services.json**
2. Переместить файл в **`android/app/`**

```bash
# Windows
## Вручную скопировать google-services.json в android/app/
```

### 4. Включить Cloud Messaging в Firebase
1. В Firebase Console в левом меню: **Build** → **Cloud Messaging**
2. Убедиться что сервис активирован (должна быть зеленая галочка)

### 5. Проверить конфигурацию (уже сделано в коде)
- ✅ `pubspec.yaml` содержит `firebase_core` и `firebase_messaging`
- ✅ `android/build.gradle` содержит Google Services plugin
- ✅ `android/app/build.gradle` применяет google-services plugin
- ✅ `lib/services/fcm_service.dart` полностью реализован
- ✅ `lib/main.dart` инициализирует Firebase и FCM

### 6. Собрать приложение
```bash
flutter clean
flutter packages get
flutter run -d 6L9XIBYLCY6TINXK
```

## Функциональность FCM Service

### автоматически включено:
- ✅ Запрос прав на уведомления (Android 13+)
- ✅ Получение FCM token
- ✅ Обработка foreground сообщений (snackbar)
- ✅ Обработка background сообщений
- ✅ Deep linking для открытия game/chat при клике
- ✅ Интеграция с NotificationService (увеличение unread counter)

### Формат payload с бэкэнда
```json
{
  "notification": {
    "title": "Новая игра!",
    "body": "Началась игра в вашем районе"
  },
  "data": {
    "type": "game",
    "game_id": "123"
  }
}
```

## Тестирование FCM

### 1. Через Firebase Console
1. В Firebase Console: **Cloud Messaging** → **Отправить первое сообщение**
2. Заполнить Название, Текст
3. В **Целевая аудитория** выбрать **Приложение** → **Oyno Sports**
4. Отправить тестовое сообщение

### 2. Проверить в логах
```bash
# В студии Android или через adb
adb logcat | grep "[FCM]"
```

## Возможные проблемы

### Problem: "Plugin not found"
**Решение**: Убедиться что google-services.json в правильной папке:
- ✅ Правильно: `android/app/google-services.json` 
- ❌ Неправильно: `android/google-services.json`

### Problem: "Google-services plugin not found"
**Решение**: Пересобрать приложение:
```bash
flutter clean
flutter packages get
flutter run
```

### Problem: Уведомления не приходят
1. Проверить что firebase-core и firebase-messaging установлены
2. Проверить логи: `adb logcat | grep firebase`
3. Убедиться что приложение имеет права на уведомления
4. Проверить что FCM token был получен (см. логи `[FCM] Token: ...`)

## Backend интеграция

Когда backend готов отправлять уведомления, используй:

```python
# Django + firebase-admin
from firebase_admin import messaging

message = messaging.MulticastMessage(
    notification=messaging.Notification(
        title="Заголовок",
        body="Текст сообщения",
    ),
    data={
        'type': 'game',
        'game_id': '123',
    },
    tokens=fcm_tokens,  # список токенов пользователей
)

response = messaging.send_multicast(message)
```

## Полезные ссылки
- [Firebase Console](https://console.firebase.google.com/)
- [Flutter Firebase Documentation](https://firebase.flutter.dev/)
- [Firebase Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging)
- [firebase_messaging на pub.dev](https://pub.dev/packages/firebase_messaging)
