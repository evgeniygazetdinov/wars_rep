import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_locale_scope.dart';
import '../models/chat_models.dart';
import '../models/emoji_catalog.dart';
import '../services/api_client.dart';
import '../services/session_controller.dart';
import '../theme/apple_theme.dart';
import '../widgets/emoji_sticker_panel.dart';

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
  Timer? _poll;
  bool _sending = false;
  String? _error;
  bool _showPanel = false;
  EmojiPanelTab _panelTab = EmojiPanelTab.emoji;

  @override
  void initState() {
    super.initState();
    _refresh();
    _poll = Timer.periodic(const Duration(seconds: 3), (_) => _refresh(silent: true));
    _focus.addListener(() {
      if (_focus.hasFocus && _showPanel) {
        setState(() => _showPanel = false);
      }
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    _textCtrl.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _refresh({bool silent = false}) async {
    try {
      final msgs = await widget.session.api.allMessages(widget.chatId);
      if (!mounted) return;
      final grew = msgs.length > _messages.length;
      setState(() {
        _messages = msgs;
        _error = null;
      });
      if (grew) {
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
    } on ApiException catch (e) {
      if (!silent && mounted) setState(() => _error = e.message);
    } catch (e) {
      if (!silent && mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _sendText(String text) async {
    final me = widget.session.user;
    final trimmed = text.trim();
    if (trimmed.isEmpty || me == null || _sending) return;
    setState(() => _sending = true);
    try {
      await widget.session.api.sendMessage(
        chatId: widget.chatId,
        userUid: me.uid,
        text: trimmed,
      );
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
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
    final text = _textCtrl.text;
    final sel = _textCtrl.selection;
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

  Widget _bubble(ChatMessage m, bool mine) {
    final sticker = StickerCodec.decode(m.text);
    if (sticker != null) {
      return Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Text(sticker, style: const TextStyle(fontSize: 64)),
        ),
      );
    }

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        decoration: BoxDecoration(
          color: mine ? AppleTheme.blue : AppleTheme.secondaryGrouped,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 18 : 4),
            bottomRight: Radius.circular(mine ? 4 : 18),
          ),
        ),
        child: Text(
          m.text,
          style: TextStyle(
            color: mine ? Colors.white : AppleTheme.primaryLabel,
            fontSize: 16,
            height: 1.3,
          ),
        ),
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
        title: Column(
          children: [
            Text(widget.peer.username),
            if (widget.peer.email != null)
              Text(
                widget.peer.email!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppleTheme.secondaryLabel,
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
                child: Text(_error!, style: const TextStyle(color: AppleTheme.red)),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  final mine = m.userUid == myUid;
                  return _bubble(m, mine);
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
                    tooltip: 'Смайлы и стикеры',
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
                          horizontal: 16,
                          vertical: 10,
                        ),
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
                            child: CircularProgressIndicator(strokeWidth: 2),
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
