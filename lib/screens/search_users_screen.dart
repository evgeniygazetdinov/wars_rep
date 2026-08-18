import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_locale_scope.dart';
import '../models/chat_models.dart';
import '../services/api_client.dart';
import '../services/session_controller.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_navigation.dart';
import '../widgets/user_avatar.dart';
import 'chat_screen.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key, required this.session});

  final SessionController session;

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  final _ctrl = TextEditingController();
  List<ChatUser> _results = [];
  List<ChatUser> _recent = [];
  bool _loading = false;
  String? _error;
  String? _hint;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  /// Берём последних собеседников из кэша чатов (уже загруженных).
  Future<void> _loadRecent() async {
    final me = widget.session.user;
    if (me == null) return;
    try {
      final chats = await widget.session.api.listChats(me.uid);
      if (!mounted) return;
      final users = chats
          .map((c) => c.peer)
          .whereType<ChatUser>()
          .take(10)
          .toList();
      setState(() => _recent = users);
    } catch (_) {}
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(value));
  }

  Future<void> _search(String raw) async {
    final q = raw.trim();
    final s = AppLocaleScope.of(context).strings;
    if (q.isEmpty) {
      setState(() {
        _results = [];
        _hint = null;
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _hint = null;
    });
    try {
      final users = await widget.session.api.searchUsers(
        q,
        excludeUid: widget.session.user?.uid,
      );
      if (!mounted) return;
      setState(() {
        _results = users;
        _hint = users.isEmpty ? s.searchEmpty : null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openChat(ChatUser peer) async {
    final me = widget.session.user;
    if (me == null) return;
    try {
      final chatId = await widget.session.api.openChat(
        myUid: me.uid,
        peerUid: peer.uid,
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        applePageRoute(
          ChatScreen(
            session: widget.session,
            chatId: chatId,
            peer: peer,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocaleScope.of(context).strings;
    final showRecent = _ctrl.text.isEmpty && _recent.isNotEmpty;

    return Scaffold(
      backgroundColor: AppleTheme.groupedBackground,
      appBar: AppBar(title: Text(s.search)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              onSubmitted: _search,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppleTheme.secondaryGrouped,
                hintText: s.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _ctrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _ctrl.clear();
                          _onChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error!, style: const TextStyle(color: AppleTheme.red)),
            ),
          if (_hint != null && _results.isEmpty && !showRecent)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _hint!,
                style: const TextStyle(color: AppleTheme.secondaryLabel),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: showRecent
                ? _buildList(
                    _recent,
                    header: s.searchRecent,
                  )
                : _buildList(_results),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<ChatUser> users, {String? header}) {
    if (users.isEmpty) return const SizedBox.shrink();
    return ListView.separated(
      itemCount: users.length + (header != null ? 1 : 0),
      separatorBuilder: (_, i) {
        if (header != null && i == 0) return const SizedBox.shrink();
        return const Divider(height: 0.5, indent: 72);
      },
      itemBuilder: (context, i) {
        if (header != null && i == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
            child: Text(
              header.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppleTheme.secondaryLabel,
                    letterSpacing: 0.4,
                  ),
            ),
          );
        }
        final u = users[header != null ? i - 1 : i];
        return ListTile(
          leading: UserAvatar(user: u),
          title: Text(u.username),
          subtitle: Text(u.subtitle),
          onTap: () => _openChat(u),
        );
      },
    );
  }
}
