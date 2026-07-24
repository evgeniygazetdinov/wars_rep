import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Базовый URL API.
///
/// По умолчанию порт **8080**.
/// Android-эмулятор: `10.0.2.2` → хост-машина.
/// Переопределение: `--dart-define=API_BASE_URL=http://192.168.x.x:8080`
abstract final class ApiConfig {
  static const String _fromDefine = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_fromDefine.isNotEmpty) return _fromDefine.replaceAll(RegExp(r'/$'), '');
    if (kIsWeb) return 'http://127.0.0.1:8080';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    } catch (_) {}
    return 'http://127.0.0.1:8080';
  }

  /// Client ID Яндекс OAuth (oauth.yandex.ru). Пусто = кнопка недоступна.
  static const String yandexClientId = String.fromEnvironment('YANDEX_CLIENT_ID');

  /// App ID ВК (id.vk.com / vk.com/apps). Пусто = кнопка недоступна.
  static const String vkClientId = String.fromEnvironment('VK_CLIENT_ID');

  static const String oauthRedirectScheme = 'chatvolc';
  static String get oauthRedirectUri => '$oauthRedirectScheme://oauth';

  static bool get hasYandexOAuth => yandexClientId.isNotEmpty;
  static bool get hasVkOAuth => vkClientId.isNotEmpty;
}
