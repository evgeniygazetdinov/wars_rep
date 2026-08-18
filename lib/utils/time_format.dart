import '../l10n/app_strings.dart';

class TimeFormat {
  static String chatListTime(DateTime? dt, AppStrings s) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);

    if (diff.inMinutes < 1) return s.timeJustNow;
    if (diff.inHours < 1) return s.timeMinutesAgo(diff.inMinutes);
    if (_isSameDay(now, local)) {
      return '${_two(local.hour)}:${_two(local.minute)}';
    }
    if (_isYesterday(now, local)) return s.timeYesterday;
    if (now.difference(local).inDays < 7) {
      return s.weekdayShort(local.weekday);
    }
    return '${_two(local.day)}.${_two(local.month)}.${local.year % 100}';
  }

  static String bubbleTime(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    return '${_two(local.hour)}:${_two(local.minute)}';
  }

  static String daySeparator(DateTime dt, AppStrings s) {
    final local = dt.toLocal();
    final now = DateTime.now();
    if (_isSameDay(now, local)) return s.dayToday;
    if (_isYesterday(now, local)) return s.dayYesterday;
    return s.dayDate(local.day, local.month, local.year);
  }

  static bool isSameDay(DateTime a, DateTime b) => _isSameDay(a, b);

  static String _two(int n) => n.toString().padLeft(2, '0');

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool _isYesterday(DateTime now, DateTime dt) {
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    return _isSameDay(yesterday, dt);
  }
}
