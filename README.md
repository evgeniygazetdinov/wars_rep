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
