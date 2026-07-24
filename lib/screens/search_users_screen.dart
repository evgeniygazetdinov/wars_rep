import 'package:flutter/material.dart';

import '../l10n/app_locale_scope.dart';
import '../models/chat_models.dart';
import '../services/api_client.dart';
import '../services/session_controller.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_navigation.dart';
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
  bool _loading = false;
  String? _error;
  String? _hint;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search(String raw) async {
    final q = raw.trim();
    final s = AppLocaleScope.of(context).strings;
    if (q.isEmpty) {
      setState(() {
        _results = [];
        _hint = s.searchPrompt;
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocaleScope.of(context).strings;

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
              onChanged: _search,
              onSubmitted: _search,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppleTheme.secondaryGrouped,
                hintText: s.searchHint,
                prefixIcon: const Icon(Icons.search),
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
          if (_hint != null && _results.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _hint!,
                style: const TextStyle(color: AppleTheme.secondaryLabel),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: ListView.separated(
              itemCount: _results.length,
              separatorBuilder: (_, __) => const Divider(height: 0.5, indent: 72),
              itemBuilder: (context, i) {
                final u = _results[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppleTheme.blue.withValues(alpha: 0.15),
                    foregroundColor: AppleTheme.blue,
                    child: Text(
                      u.username.isNotEmpty ? u.username[0].toUpperCase() : '?',
                    ),
                  ),
                  title: Text(u.username),
                  subtitle: Text(u.subtitle),
                  onTap: () => _openChat(u),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
