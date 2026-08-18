import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/chat_models.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String baseUrl;
  String? accessToken;

  Uri _uri(String path, [Map<String, String>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalized').replace(queryParameters: query);
  }

  Map<String, String> _headers({bool jsonBody = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (jsonBody) headers['Content-Type'] = 'application/json';
    final token = accessToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _decodeMap(http.Response response) {
    final body = response.body.isEmpty ? '{}' : response.body;
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return Future.value(decoded);
    throw ApiException('Некорректный ответ сервера', statusCode: response.statusCode);
  }

  Never _throwFor(http.Response response) {
    String detail = 'Ошибка ${response.statusCode}';
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['detail'] != null) {
        final d = data['detail'];
        if (d is String) {
          detail = d;
        } else if (d is Map && d['message'] != null) {
          detail = d['message'].toString();
        } else {
          detail = d.toString();
        }
      }
    } catch (_) {}
    throw ApiException(detail, statusCode: response.statusCode);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final response = await _client.post(
      _uri(path, query),
      headers: _headers(jsonBody: true),
      body: jsonEncode(body ?? {}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwFor(response);
    }
    return _decodeMap(response);
  }

  Future<dynamic> getJson(String path, {Map<String, String>? query}) async {
    final response = await _client.get(
      _uri(path, query),
      headers: _headers(),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwFor(response);
    }
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  Future<({String accessToken, ChatUser user})> loginDev({
    required String email,
    required String username,
    String provider = 'yandex',
  }) async {
    final data = await postJson('/auth/dev', body: {
      'email': email.trim(),
      'username': username.trim(),
      'provider': provider,
    });
    accessToken = data['access_token'] as String;
    final user = ChatUser.fromJson(data['user'] as Map<String, dynamic>);
    return (accessToken: accessToken!, user: user);
  }

  Future<({String accessToken, ChatUser user})> loginPassword({
    required String email,
    required String password,
  }) async {
    final data = await postJson('/auth/login', body: {
      'email': email.trim(),
      'password': password,
    });
    accessToken = data['access_token'] as String;
    final user = ChatUser.fromJson(data['user'] as Map<String, dynamic>);
    return (accessToken: accessToken!, user: user);
  }

  Future<({String accessToken, ChatUser user})> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final data = await postJson('/auth/register', body: {
      'email': email.trim(),
      'password': password,
      'username': username.trim(),
    });
    accessToken = data['access_token'] as String;
    final user = ChatUser.fromJson(data['user'] as Map<String, dynamic>);
    return (accessToken: accessToken!, user: user);
  }

  Future<({String accessToken, ChatUser user})> loginOAuth({
    required String provider,
    required String accessToken,
  }) async {
    final data = await postJson('/auth/oauth', body: {
      'provider': provider,
      'access_token': accessToken,
    });
    this.accessToken = data['access_token'] as String;
    final user = ChatUser.fromJson(data['user'] as Map<String, dynamic>);
    return (accessToken: this.accessToken!, user: user);
  }

  Future<ChatUser> me() async {
    final data = await getJson('/auth/me') as Map<String, dynamic>;
    return ChatUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<List<ChatUser>> searchUsers(String query, {String? excludeUid}) async {
    final data = await getJson('/users/search', query: {
      'q': query,
      if (excludeUid != null) 'exclude_uid': excludeUid,
    }) as Map<String, dynamic>;
    final list = data['users'] as List<dynamic>? ?? [];
    return list
        .map((e) => ChatUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ChatSummary>> listChats(String userUid) async {
    final data = await getJson('/users/$userUid/chats') as Map<String, dynamic>;
    final list = data['chats'] as List<dynamic>? ?? [];
    return list
        .map((e) => ChatSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> createOrGetChat({
    required String myUid,
    required String peerUid,
  }) async {
    try {
      final data = await postJson('/private_chat/', body: {
        'user_one_uid': myUid,
        'user_two_uid': peerUid,
      });
      return (data['new_chat'] as Map<String, dynamic>)['id'] as int;
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        // detail может быть Map с chat_id — парсим из сообщения ненадёжно,
        // повторим запрос через raw decode
        rethrow;
      }
      rethrow;
    }
  }

  /// Создаёт чат или возвращает существующий id (409).
  Future<int> openChat({
    required String myUid,
    required String peerUid,
  }) async {
    final response = await _client.post(
      _uri('/private_chat/'),
      headers: _headers(jsonBody: true),
      body: jsonEncode({
        'user_one_uid': myUid,
        'user_two_uid': peerUid,
      }),
    );
    final data = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 || response.statusCode == 201) {
      return (data['new_chat'] as Map<String, dynamic>)['id'] as int;
    }
    if (response.statusCode == 409) {
      final detail = data['detail'];
      if (detail is Map && detail['chat_id'] != null) {
        return detail['chat_id'] as int;
      }
    }
    _throwFor(response);
  }

  Future<List<ChatMessage>> allMessages(int chatId) async {
    final data = await getJson('/private_chat/$chatId/all_messages');
    if (data is! List) return [];
    return data
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChatMessage> sendMessage({
    required int chatId,
    required String text,
  }) async {
    final data = await postJson('/private_chat/$chatId/message', body: {
      'text': text,
    });
    final raw = Map<String, dynamic>.from(
      data['new_message'] as Map? ?? <String, dynamic>{},
    );
    raw.putIfAbsent('chat_id', () => chatId);
    raw.putIfAbsent('text', () => text);
    return ChatMessage.fromJson(raw);
  }

  Future<bool> deleteMessage({
    required int chatId,
    required int messageId,
  }) async {
    final response = await _client.delete(
      _uri('/private_chat/$chatId/$messageId'),
      headers: _headers(),
    );
    if (response.statusCode == 200) return true;
    _throwFor(response);
  }

  Future<void> deleteChat(int chatId) async {
    final response = await _client.delete(
      _uri('/private_chat/$chatId'),
      headers: _headers(),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwFor(response);
    }
  }

  Future<bool> healthCheck() async {
    try {
      final data = await getJson('/healf_check');
      return data is Map && data['message'] == 'alive';
    } catch (_) {
      return false;
    }
  }
}
