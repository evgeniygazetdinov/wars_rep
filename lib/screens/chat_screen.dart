import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_locale_scope.dart';
import '../l10n/app_strings.dart';
import '../models/chat_models.dart';
import '../models/emoji_catalog.dart';
import '../services/api_client.dart';
import '../services/chat_socket.dart';
import '../services/session_controller.dart';
import '../theme/apple_theme.dart';
import '../utils/time_format.dart';
import '../widgets/emoji_sticker_panel.dart';
import '../widgets/user_avatar.dart';

class _FeedEntry {
  const _FeedEntry.day(this.label) : message = null;
  const _FeedEntry.message(this.message) : label = null;

  final String? label;
  final ChatMessage? message;
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.session,
    required this.chatId,
    required this.peer,
  });

  final SessionController session;
  final int chatId;
  final ChatUser peer;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textCtrl = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();

  List<ChatMessage> _messages = [];
  List<_FeedEntry> _feed = [];
  ChatSocket? _socket;
  StreamSubscription<SocketEvent>? _sub;

  bool _sending = false;
  String? _error;
  bool _showPanel = false;
  EmojiPanelTab _panelTab = EmojiPanelTab.emoji;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _connectSocket();
    _focus.addListener(() {
      if (_focus.hasFocus && _showPanel) setState(() => _showPanel = false);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _socket?.dispose();
    _textCtrl.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  // ────────────────────────── данные ──────────────────────────────────────── //

  Future<void> _loadHistory() async {
    try {
      final msgs = await widget.session.api.allMessages(widget.chatId);
      if (!mounted) return;
      setState(() {
        _messages = msgs;
        _rebuildFeed();
      });
      _scrollToBottom();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  void _connectSocket() {
    final token = widget.session.api.accessToken;
    if (token == null) return;

    final socket = ChatSocket(chatId: widget.chatId, accessToken: token);
    _socket = socket;
    socket.connect();

    _sub = socket.stream.listen((event) {
      if (!mounted) return;
      if (event.type == SocketEventType.message && event.message != null) {
        final msg = event.message!;
        // Если сообщение уже есть (по id) — не добавлять повторно
        if (_messages.any((m) => m.id == msg.id)) return;
        setState(() {
          _messages = [..._messages, msg];
          _rebuildFeed();
        });
        _scrollToBottom();
      }
    });
  }

  void _rebuildFeed() {
    final s = AppLocaleScope.of(context).strings;
    _feed = _buildFeed(_messages, s);
  }

  static List<_FeedEntry> _buildFeed(List<ChatMessage> msgs, AppStrings s) {
    final feed = <_FeedEntry>[];
    DateTime? lastDay;
    for (final m in msgs) {
      final created = m.createdAt?.toLocal();
      if (created != null) {
        if (lastDay == null || !TimeFormat.isSameDay(lastDay, created)) {
          feed.add(_FeedEntry.day(TimeFormat.daySeparator(created, s)));
          lastDay = created;
        }
      }
      feed.add(_FeedEntry.message(m));
    }
    return feed;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ─────────────────────────── отправка ───────────────────────────────────── //

  Future<void> _sendText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      // Отправляем через REST (возвращает сохранённое сообщение);
      // WS-событие придёт всем участникам от Redis.
      await widget.session.api.sendMessage(chatId: widget.chatId, text: trimmed);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _send() async {
    final text = _textCtrl.text;
    _textCtrl.clear();
    await _sendText(text);
  }

  Future<void> _sendSticker(String emoji) async {
    setState(() => _showPanel = false);
    await _sendText(StickerCodec.encode(emoji));
  }

  void _insertEmoji(String emoji) {
    final sel = _textCtrl.selection;
    final text = _textCtrl.text;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    final next = text.replaceRange(start, end, emoji);
    _textCtrl.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
  }

  void _togglePanel() {
    FocusScope.of(context).unfocus();
    setState(() => _showPanel = !_showPanel);
  }

  // ───────────────────────── удаление сообщения ───────────────────────────── //

  Future<void> _deleteMessage(ChatMessage m) async {
    try {
      final response = await widget.session.api.deleteMessage(
        chatId: widget.chatId,
        messageId: m.id,
      );
      if (response && mounted) {
        setState(() {
          _messages = _messages.where((x) => x.id != m.id).toList();
          _rebuildFeed();
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  void _showMessageActions(BuildContext context, ChatMessage m, bool mine) {
    final s = AppLocaleScope.of(context).strings;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: Text(s.copyMessage),
              onTap: () {
                Clipboard.setData(ClipboardData(text: m.text));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(s.copiedToClipboard)),
                );
              },
            ),
            if (mine)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppleTheme.red),
                title: Text(s.deleteMessage,
                    style: const TextStyle(color: AppleTheme.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteMessage(m);
                },
              ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────── UI ────────────────────────────────────────── //

  Widget _dayChip(String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppleTheme.secondaryGrouped,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppleTheme.secondaryLabel,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );

  Widget _bubble(ChatMessage m, bool mine) {
    final s = AppLocaleScope.of(context).strings;
    final time = TimeFormat.bubbleTime(m.createdAt);
    final sticker = StickerCodec.decode(m.text);

    Widget content;
    if (sticker != null) {
      content = Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Column(
            crossAxisAlignment:
                mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(sticker, style: const TextStyle(fontSize: 64)),
              if (time.isNotEmpty)
                Text(time,
                    style: const TextStyle(
                        fontSize: 11, color: AppleTheme.tertiaryLabel)),
            ],
          ),
        ),
      );
    } else {
      content = Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          constraints:
              BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
          decoration: BoxDecoration(
            color: mine ? AppleTheme.blue : AppleTheme.secondaryGrouped,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(mine ? 18 : 4),
              bottomRight: Radius.circular(mine ? 4 : 18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  m.text,
                  style: TextStyle(
                    color: mine ? Colors.white : AppleTheme.primaryLabel,
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
              ),
              if (time.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: mine
                        ? Colors.white.withValues(alpha: 0.75)
                        : AppleTheme.tertiaryLabel,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onLongPress: () => _showMessageActions(context, m, mine),
      child: Tooltip(
        message: mine ? s.longPressMessageHint : '',
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocaleScope.of(context).strings;
    final myUid = widget.session.user?.uid;

    return Scaffold(
      backgroundColor: AppleTheme.groupedBackground,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserAvatar(user: widget.peer, radius: 16),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.peer.username, overflow: TextOverflow.ellipsis),
                  if (widget.peer.email != null)
                    Text(
                      widget.peer.email!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppleTheme.secondaryLabel),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_error != null)
            Material(
              color: AppleTheme.red.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child:
                    Text(_error!, style: const TextStyle(color: AppleTheme.red)),
              ),
            ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                if (_showPanel) setState(() => _showPanel = false);
              },
              child: ListView.builder(
                controller: _scroll,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                itemCount: _feed.length,
                itemBuilder: (context, i) {
                  final entry = _feed[i];
                  if (entry.label != null) return _dayChip(entry.label!);
                  final m = entry.message!;
                  return _bubble(m, m.userUid == myUid);
                },
              ),
            ),
          ),
          SafeArea(
            top: false,
            bottom: !_showPanel,
            child: Container(
              color: AppleTheme.secondaryGrouped,
              padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: s.emojiPanelTooltip,
                    onPressed: _togglePanel,
                    icon: Icon(
                      _showPanel
                          ? Icons.keyboard_alt_outlined
                          : Icons.emoji_emotions_outlined,
                      color: AppleTheme.blue,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      focusNode: _focus,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onTap: () {
                        if (_showPanel) setState(() => _showPanel = false);
                      },
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: s.messageHint,
                        filled: true,
                        fillColor: AppleTheme.groupedBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_upward),
                  ),
                ],
              ),
            ),
          ),
          if (_showPanel)
            EmojiStickerPanel(
              tab: _panelTab,
              onTabChanged: (t) => setState(() => _panelTab = t),
              onEmoji: _insertEmoji,
              onSticker: _sendSticker,
            ),
        ],
      ),
    );
  }
}
