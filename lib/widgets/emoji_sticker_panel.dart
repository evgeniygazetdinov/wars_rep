import 'package:flutter/material.dart';

import '../l10n/app_locale_scope.dart';
import '../models/emoji_catalog.dart';
import '../theme/apple_theme.dart';

enum EmojiPanelTab { emoji, stickers }

/// Нижняя панель: эмодзи (вставка в текст) и стикеры (отправка сразу).
class EmojiStickerPanel extends StatelessWidget {
  const EmojiStickerPanel({
    super.key,
    required this.tab,
    required this.onTabChanged,
    required this.onEmoji,
    required this.onSticker,
    this.height = 260,
  });

  final EmojiPanelTab tab;
  final ValueChanged<EmojiPanelTab> onTabChanged;
  final ValueChanged<String> onEmoji;
  final ValueChanged<String> onSticker;
  final double height;

  @override
  Widget build(BuildContext context) {
    final s = AppLocaleScope.of(context).strings;
    final items =
        tab == EmojiPanelTab.emoji ? EmojiCatalog.emojis : EmojiCatalog.stickers;
    final isSticker = tab == EmojiPanelTab.stickers;

    return Material(
      color: AppleTheme.secondaryGrouped,
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            const Divider(height: 0.5, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: [
                  _TabChip(
                    label: s.emojisTab,
                    selected: tab == EmojiPanelTab.emoji,
                    onTap: () => onTabChanged(EmojiPanelTab.emoji),
                  ),
                  const SizedBox(width: 8),
                  _TabChip(
                    label: s.stickersTab,
                    selected: tab == EmojiPanelTab.stickers,
                    onTap: () => onTabChanged(EmojiPanelTab.stickers),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isSticker ? 5 : 8,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () =>
                        isSticker ? onSticker(item) : onEmoji(item),
                    child: Center(
                      child: Text(
                        item,
                        style: TextStyle(fontSize: isSticker ? 36 : 26),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppleTheme.blue.withValues(alpha: 0.12) : const Color(0xFFE5E5EA),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? AppleTheme.blue : AppleTheme.primaryLabel,
            ),
          ),
        ),
      ),
    );
  }
}
