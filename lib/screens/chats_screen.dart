import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../l10n/app_locale_scope.dart';
import '../models/chat_models.dart';
import '../services/api_client.dart';
import '../services/session_controller.dart';
import '../theme/apple_theme.dart';
import '../utils/message_preview.dart';
import '../utils/time_format.dart';
import '../widgets/apple_navigation.dart';
import '../widgets/language_switch_button.dart';
import '../widgets/user_avatar.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'search_users_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key, required this.session});

  final SessionController session;

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<ChatSummary> _chats = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final me = widget.session.user;
    if (me == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final chats = await widget.session.api.listChats(me.uid);
      if (!mounted) return;
      setState(() {
        _chats = chats;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<bool> _confirmDelete(ChatSummary chat) async {
    final s = AppLocaleScope.of(context).strings;
    final peer = chat.peer;
    final name = peer?.username ?? s.chatFallbackTitle(chat.id);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteChatTitle),
        content: Text(s.deleteChatBody(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppleTheme.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;

    try {
      await widget.session.api.deleteChat(chat.id);
      return true;
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocaleScope.of(context).strings;
    final me = widget.session.user;

    return Scaffold(
      backgroundColor: AppleTheme.groupedBackground,
      appBar: AppBar(
        title: Text(s.chats),
        actions: [
          const LanguageSwitchButton(),
          IconButton(
            tooltip: s.search,
            onPressed: () async {
              await Navigator.of(context).push(
                applePageRoute(SearchUsersScreen(session: widget.session)),
              );
              _load();
            },
            icon: const Icon(CupertinoIcons.search),
          ),
          IconButton(
            tooltip: s.profileTitle,
            onPressed: () {
              Navigator.of(context).push(
                applePageRoute(ProfileScreen(session: widget.session)),
              );
            },
            icon: UserAvatar(user: me, radius: 14),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            applePageRoute(SearchUsersScreen(session: widget.session)),
          );
          _load();
        },
        child: const Icon(CupertinoIcons.pencil),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _error != null
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: AppleTheme.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${s.serverUnreachable}\n${ApiConfig.baseUrl}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppleTheme.secondaryLabel),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: _load, child: Text(s.retry)),
                    ],
                  )
                : _chats.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 80),
                          const Icon(
                            CupertinoIcons.chat_bubble_2,
                            size: 48,
                            color: AppleTheme.tertiaryLabel,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            s.emptyChats,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppleTheme.secondaryLabel),
                          ),
                          if (me != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              me.email ?? me.username,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppleTheme.tertiaryLabel,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      )
                    : ListView.separated(
                        itemCount: _chats.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 0.5, indent: 72),
                        itemBuilder: (context, i) {
                          final chat = _chats[i];
                          final peer = chat.peer;
                          final title =
                              peer?.username ?? s.chatFallbackTitle(chat.id);
                          final preview = messagePreview(
                            chat.lastMessage?.text ?? '',
                            s,
                          );
                          final time = TimeFormat.chatListTime(
                            chat.lastMessage?.createdAt,
                            s,
                          );
                          return Dismissible(
                            key: ValueKey('chat-${chat.id}'),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) => _confirmDelete(chat),
                            background: Container(
                              color: AppleTheme.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: ListTile(
                              leading: UserAvatar(user: peer),
                              title: Text(title),
                              subtitle: preview.isEmpty
                                  ? null
                                  : Text(
                                      preview,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                              trailing: time.isEmpty
                                  ? null
                                  : Text(
                                      time,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppleTheme.secondaryLabel,
                                      ),
                                    ),
                              onTap: peer == null
                                  ? null
                                  : () async {
                                      await Navigator.of(context).push(
                                        applePageRoute(
                                          ChatScreen(
                                            session: widget.session,
                                            chatId: chat.id,
                                            peer: peer,
                                          ),
                                        ),
                                      );
                                      _load();
                                    },
                              onLongPress: peer == null
                                  ? null
                                  : () async {
                                      final deleted = await _confirmDelete(chat);
                                      if (deleted && mounted) {
                                        setState(() {
                                          _chats.removeAt(i);
                                        });
                                      }
                                    },
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
