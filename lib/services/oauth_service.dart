import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';

/// OAuth Яндекс / ВК: открываем системный браузер.
/// На Linux нет WebView-плагина — после входа пользователь вставляет
/// redirect-URL (или access_token) из адресной строки.
class OAuthService {
  static Uri yandexAuthUrl() {
    if (!ApiConfig.hasYandexOAuth) {
      throw StateError('YANDEX_CLIENT_ID не задан');
    }
    return Uri.https('oauth.yandex.ru', '/authorize', {
      'response_type': 'token',
      'client_id': ApiConfig.yandexClientId,
      'redirect_uri': ApiConfig.oauthRedirectUri,
      'force_confirm': 'yes',
    });
  }

  static Uri vkAuthUrl() {
    if (!ApiConfig.hasVkOAuth) {
      throw StateError('VK_CLIENT_ID не задан');
    }
    return Uri.https('oauth.vk.com', '/authorize', {
      'client_id': ApiConfig.vkClientId,
      'display': 'page',
      'redirect_uri': ApiConfig.oauthRedirectUri,
      'scope': 'email',
      'response_type': 'token',
      'v': '5.199',
    });
  }

  static Future<void> openBrowser(Uri authUrl) async {
    final ok = await launchUrl(authUrl, mode: LaunchMode.externalApplication);
    if (!ok) {
      throw StateError('Не удалось открыть браузер');
    }
  }

  /// Достаёт access_token из redirect URL / fragment / сырого токена.
  static String? extractToken(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (!trimmed.contains('://') && !trimmed.contains('=')) {
      return trimmed; // уже токен
    }
    final uri = Uri.parse(trimmed.contains('://') ? trimmed : 'https://x/?$trimmed');
    final fragment = uri.fragment;
    if (fragment.isNotEmpty) {
      final params = Uri.splitQueryString(fragment);
      final token = params['access_token'];
      if (token != null && token.isNotEmpty) return token;
      if (params['error'] != null) {
        throw StateError(params['error_description'] ?? params['error']!);
      }
    }
    final q = uri.queryParameters['access_token'];
    if (q != null && q.isNotEmpty) return q;
    final hashIdx = trimmed.indexOf('#');
    if (hashIdx >= 0) {
      final params = Uri.splitQueryString(trimmed.substring(hashIdx + 1));
      final token = params['access_token'];
      if (token != null && token.isNotEmpty) return token;
    }
    return null;
  }
}
