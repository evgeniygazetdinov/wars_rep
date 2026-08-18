import '../l10n/app_strings.dart';
import '../models/emoji_catalog.dart';

String messagePreview(String raw, AppStrings s) {
  final sticker = StickerCodec.decode(raw);
  if (sticker != null) return s.stickerPreview(sticker);
  final normalized = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  return normalized;
}
