import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../l10n/app_locale_scope.dart';
import '../models/chat_models.dart';
import '../models/emoji_catalog.dart';
import '../services/api_client.dart';
import '../services/session_controller.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_navigation.dart';
import '../widgets/language_switch_button.dart';
import 'chat_screen.dart';
import 'login_screen.dart';
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

  Future<void> _logout() async {
    await widget.session.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      applePageRoute(LoginScreen(session: widget.session)),
      (_) => false,
    );
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
            tooltip: s.logout,
            onPressed: _logout,
            icon: const Icon(CupertinoIcons.square_arrow_right),
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
                      FilledButton(onPressed: _load, child: const Text('Повторить')),
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
                          final title = peer?.username ?? 'Чат #${chat.id}';
                          final rawPreview = chat.lastMessage?.text ?? '';
                          final sticker = StickerCodec.decode(rawPreview);
                          final preview = sticker != null ? 'Стикер $sticker' : rawPreview;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppleTheme.blue.withValues(alpha: 0.15),
                              foregroundColor: AppleTheme.blue,
                              child: Text(
                                title.isNotEmpty ? title[0].toUpperCase() : '?',
                              ),
                            ),
                            title: Text(title),
                            subtitle: Text(
                              preview,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                          );
                        },
                      ),
      ),
    );
  }
}
