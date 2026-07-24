class ChatUser {
  const ChatUser({
    required this.id,
    required this.uid,
    required this.username,
    this.email,
    this.provider,
    this.avatarUrl,
  });

  final int id;
  final String uid;
  final String username;
  final String? email;
  final String? provider;
  final String? avatarUrl;

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] as int,
      uid: json['uid'] as String,
      username: (json['username'] as String?) ?? '',
      email: json['email'] as String?,
      provider: json['provider'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uid': uid,
        'username': username,
        'email': email,
        'provider': provider,
        'avatar_url': avatarUrl,
      };

  String get subtitle {
    if (email != null && email!.isNotEmpty) return email!;
    if (provider != null && provider!.isNotEmpty) return provider!;
    return uid;
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.text,
    this.userUid,
    this.username,
    this.createdAt,
  });

  final int id;
  final int chatId;
  final int userId;
  final String text;
  final String? userUid;
  final String? username;
  final DateTime? createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    DateTime? created;
    final raw = json['created_at'];
    if (raw is String && raw.isNotEmpty) {
      created = DateTime.tryParse(raw);
    }
    return ChatMessage(
      id: (json['id'] as num?)?.toInt() ?? 0,
      chatId: (json['chat_id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      text: (json['text'] as String?) ?? '',
      userUid: json['user_uid'] as String?,
      username: json['username'] as String?,
      createdAt: created,
    );
  }
}

class ChatSummary {
  const ChatSummary({
    required this.id,
    this.peer,
    this.lastMessage,
  });

  final int id;
  final ChatUser? peer;
  final ChatMessage? lastMessage;

  factory ChatSummary.fromJson(Map<String, dynamic> json) {
    return ChatSummary(
      id: json['id'] as int,
      peer: json['peer'] is Map<String, dynamic>
          ? ChatUser.fromJson(json['peer'] as Map<String, dynamic>)
          : null,
      lastMessage: json['last_message'] is Map<String, dynamic>
          ? ChatMessage.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
    );
  }
}
