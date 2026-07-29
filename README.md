# Chat Volc

Flutter-клиент к API `chat_volc_backend`.

```bash
flutter pub get
flutter run -d linux --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

Android-эмулятор:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Сборка APK:

```bash
flutter build apk --release
```

Опционально для OAuth:

```bash
--dart-define=YANDEX_CLIENT_ID=...
--dart-define=VK_CLIENT_ID=...
```

## Структура `lib/`

### Точка входа

| Файл | Назначение |
|------|------------|
| `main.dart` | Инициализация приложения: `ApiClient`, `SessionController`, локаль, тема Apple, выбор `LoginScreen` / `ChatsScreen` по сессии |

### Конфиг

| Файл | Назначение |
|------|------------|
| `config/api_config.dart` | Базовый URL API (`API_BASE_URL`), Client ID Яндекс/ВК, redirect URI для OAuth |

### Экраны (`screens/`)

| Файл | Назначение |
|------|------------|
| `login_screen.dart` | Вход: OAuth Яндекс/ВК, тестовый вход по email, переключатель языка |
| `chats_screen.dart` | Список чатов, выход, переход к поиску пользователей и в переписку |
| `search_users_screen.dart` | Поиск пользователей и открытие/создание чата |
| `chat_screen.dart` | Переписка: сообщения, polling, отправка текста/стикеров, панель эмодзи |

### Виджеты (`widgets/`)

| Файл | Назначение |
|------|------------|
| `apple_navigation.dart` | `CupertinoPageRoute` — переходы между экранами в стиле iOS |
| `ios_grouped_section.dart` | Секция списка в стиле iOS Settings (белый блок на сером фоне) |
| `language_switch_button.dart` | Кнопка переключения языка RU ↔ EN |
| `emoji_sticker_panel.dart` | Нижняя панель: эмодзи (вставка в текст) и стикеры (отправка сразу) |

### Сервисы (`services/`)

| Файл | Назначение |
|------|------------|
| `api_client.dart` | HTTP-клиент к бэкенду: логин, профиль, поиск, чаты, сообщения, health |
| `session_controller.dart` | Сессия: JWT + профиль в `SharedPreferences`, login/logout, проверка токена |
| `oauth_service.dart` | OAuth Яндекс/ВК: URL авторизации, открытие браузера, извлечение `access_token` |

### Модели (`models/`)

| Файл | Назначение |
|------|------------|
| `chat_models.dart` | `ChatUser`, `ChatMessage`, `ChatSummary` — модели данных API |
| `emoji_catalog.dart` | Каталог эмодзи/стикеров и `StickerCodec` (кодирование стикера в тексте) |

### Локализация (`l10n/`)

| Файл | Назначение |
|------|------------|
| `app_locale.dart` | `AppLocaleController` — язык UI (ru/en), сохранение выбора |
| `app_locale_scope.dart` | `InheritedNotifier` + удобный доступ к строкам через `context.s` |
| `app_strings.dart` | Все UI-строки на русском и английском |

### Тема

| Файл | Назначение |
|------|------------|
| `theme/apple_theme.dart` | Палитра и светлая тема в духе iOS (цвета, радиусы, `ThemeData`) |
