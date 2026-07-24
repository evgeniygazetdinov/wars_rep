import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_models.dart';
import 'api_client.dart';

/// Сессия пользователя: JWT + профиль в SharedPreferences.
class SessionController extends ChangeNotifier {
  SessionController(this._api);

  static const _tokenKey = 'auth_access_token';
  static const _userKey = 'auth_user_json';

  final ApiClient _api;
  ChatUser? _user;
  bool _ready = false;

  ApiClient get api => _api;
  ChatUser? get user => _user;
  bool get isLoggedIn => _user != null && (_api.accessToken?.isNotEmpty ?? false);
  bool get ready => _ready;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final rawUser = prefs.getString(_userKey);
    if (token != null && token.isNotEmpty && rawUser != null) {
      _api.accessToken = token;
      try {
        _user = ChatUser.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
        // Проверка токена
        _user = await _api.me();
        await _persist(token, _user!);
      } catch (_) {
        await clear();
      }
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> applyAuth({
    required String accessToken,
    required ChatUser user,
  }) async {
    _api.accessToken = accessToken;
    _user = user;
    await _persist(accessToken, user);
    notifyListeners();
  }

  Future<void> loginDev({
    required String email,
    required String username,
    String provider = 'yandex',
  }) async {
    final result = await _api.loginDev(
      email: email,
      username: username,
      provider: provider,
    );
    await applyAuth(accessToken: result.accessToken, user: result.user);
  }

  Future<void> loginOAuth({
    required String provider,
    required String providerAccessToken,
  }) async {
    final result = await _api.loginOAuth(
      provider: provider,
      accessToken: providerAccessToken,
    );
    await applyAuth(accessToken: result.accessToken, user: result.user);
  }

  Future<void> logout() async {
    await clear();
    notifyListeners();
  }

  Future<void> clear() async {
    _user = null;
    _api.accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<void> _persist(String token, ChatUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
}
