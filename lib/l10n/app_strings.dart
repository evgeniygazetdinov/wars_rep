import 'app_locale.dart';

class AppStrings {
  const AppStrings(this._lang);

  final AppLanguage _lang;

  bool get _ru => _lang == AppLanguage.ru;

  String get appTitle => _ru ? 'Chat Volc' : 'Chat Volc';

  String get chats => _ru ? 'Чаты' : 'Chats';

  String get loginTitle => _ru ? 'Вход' : 'Sign in';

  String get loginSubtitle => _ru
      ? 'Войдите через Яндекс, ВК или email и пароль'
      : 'Sign in with Yandex, VK, or email and password';

  String get loginYandex => _ru ? 'Войти через Яндекс' : 'Sign in with Yandex';

  String get loginVk => _ru ? 'Войти через ВК' : 'Sign in with VK';

  String get loginEmail => _ru ? 'Email и пароль' : 'Email and password';

  String get loginDev => _ru ? 'Войти по email (тест)' : 'Sign in with email (dev)';

  String get registerTitle => _ru ? 'Регистрация' : 'Sign up';

  String get registerAction => _ru ? 'Создать аккаунт' : 'Create account';

  String get password => _ru ? 'Пароль' : 'Password';

  String get passwordHint => _ru ? 'Не менее 6 символов' : 'At least 6 characters';

  String get haveAccount => _ru ? 'Уже есть аккаунт? Войти' : 'Already have an account? Sign in';

  String get noAccount => _ru ? 'Нет аккаунта? Зарегистрироваться' : 'No account? Sign up';

  String get email => _ru ? 'Email' : 'Email';

  String get emailHint => _ru ? 'name@example.com' : 'name@example.com';

  String get displayName => _ru ? 'Имя' : 'Name';

  String get displayNameHint => _ru ? 'Как вас показывать' : 'Display name';

  String get continueAction => _ru ? 'Продолжить' : 'Continue';

  String get logout => _ru ? 'Выйти' : 'Log out';

  String get profileTitle => _ru ? 'Профиль' : 'Profile';

  String get profileAccount => _ru ? 'Аккаунт' : 'Account';

  String get profileProvider => _ru ? 'Провайдер' : 'Provider';

  String get search => _ru ? 'Поиск' : 'Search';

  String get searchHint => _ru ? 'Имя или email' : 'Name or email';

  String get searchEmpty => _ru ? 'Никого не нашли' : 'No users found';

  String get searchRecent => _ru ? 'Недавние' : 'Recent';

  String get searchPrompt => _ru ? 'Введите имя или почту' : 'Enter a name or email';

  String get newChat => _ru ? 'Новый чат' : 'New chat';

  String get emptyChats =>
      _ru ? 'Пока нет чатов. Найдите собеседника.' : 'No chats yet. Find someone.';

  String get messageHint => _ru ? 'Сообщение' : 'Message';

  String get send => _ru ? 'Отправить' : 'Send';

  String get cancel => _ru ? 'Отмена' : 'Cancel';

  String get save => _ru ? 'Сохранить' : 'Save';

  String get retry => _ru ? 'Повторить' : 'Retry';

  String get delete => _ru ? 'Удалить' : 'Delete';

  String get deleteChatTitle => _ru ? 'Удалить чат?' : 'Delete chat?';

  String deleteChatBody(String name) => _ru
      ? 'Переписка с $name будет удалена без возможности восстановления.'
      : 'Your conversation with $name will be permanently deleted.';

  String get errorGeneric => _ru ? 'Что-то пошло не так' : 'Something went wrong';

  String get serverUnreachable => _ru
      ? 'Сервер недоступен. Проверьте, что бекенд на порту 8080.'
      : 'Server unreachable. Check backend on port 8080.';

  String get oauthNotConfigured => _ru
      ? 'OAuth не настроен. Задайте CLIENT_ID через --dart-define или войдите по email.'
      : 'OAuth is not configured. Pass CLIENT_ID via --dart-define or use email login.';

  String get oauthCompleteTitle => _ru ? 'Завершение входа' : 'Complete sign-in';

  String get oauthCompleteHint => _ru
      ? 'Вставьте URL после редиректа или access_token'
      : 'Paste the redirect URL or access_token';

  String get oauthTokenNotFound => _ru
      ? 'Не удалось найти access_token'
      : 'Could not find access_token';

  String get devLoginHeader => _ru ? 'Тестовый вход' : 'Dev sign-in';

  String devLoginFooter(String baseUrl) => _ru
      ? 'Работает при ALLOW_DEV_AUTH=1 на бекенде. API: $baseUrl'
      : 'Works when ALLOW_DEV_AUTH=1 on backend. API: $baseUrl';

  String get devLoginValidation => _ru
      ? 'Укажите имя и корректный email'
      : 'Enter a name and valid email';

  String get copyMessage => _ru ? 'Копировать' : 'Copy';

  String get copiedToClipboard => _ru ? 'Скопировано' : 'Copied';

  String get deleteMessage => _ru ? 'Удалить сообщение' : 'Delete message';

  String get longPressMessageHint => _ru ? 'Удержите для действий' : 'Hold for actions';

  String get emojisTab => _ru ? 'Смайлы' : 'Emojis';

  String get stickersTab => _ru ? 'Стикеры' : 'Stickers';

  String get emojiPanelTooltip => _ru ? 'Смайлы и стикеры' : 'Emojis and stickers';

  String stickerPreview(String emoji) => _ru ? 'Стикер $emoji' : 'Sticker $emoji';

  String chatFallbackTitle(int id) => _ru ? 'Чат #$id' : 'Chat #$id';

  String get you => _ru ? 'Вы' : 'You';

  String get providerYandex => _ru ? 'Яндекс' : 'Yandex';

  String get providerVk => _ru ? 'ВК' : 'VK';

  String get providerLocal => _ru ? 'Email' : 'Email';

  String get providerGoogle => 'Google';

  String get timeJustNow => _ru ? 'только что' : 'just now';

  String timeMinutesAgo(int minutes) =>
      _ru ? '$minutes мин' : '${minutes}m';

  String get timeYesterday => _ru ? 'вчера' : 'yesterday';

  String weekdayShort(int weekday) {
    if (_ru) {
      const days = ['', 'пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'];
      return days[weekday];
    }
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday];
  }

  String get dayToday => _ru ? 'Сегодня' : 'Today';

  String get dayYesterday => _ru ? 'Вчера' : 'Yesterday';

  String dayDate(int day, int month, int year) {
    if (_ru) return '$day.${month.toString().padLeft(2, '0')}.$year';
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[month]} $day, $year';
  }
}
