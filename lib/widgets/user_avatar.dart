import 'package:flutter/material.dart';

import '../models/chat_models.dart';
import '../theme/apple_theme.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.user,
    this.radius = 22,
  });

  final ChatUser? user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final name = user?.username ?? '?';
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final url = user?.avatarUrl;

    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppleTheme.blue.withValues(alpha: 0.15),
        backgroundImage: NetworkImage(url),
        onBackgroundImageError: (_, __) {},
        child: url.isEmpty ? Text(letter) : null,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppleTheme.blue.withValues(alpha: 0.15),
      foregroundColor: AppleTheme.blue,
      child: Text(
        letter,
        style: TextStyle(fontSize: radius * 0.85, fontWeight: FontWeight.w600),
      ),
    );
  }
}
