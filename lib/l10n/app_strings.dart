import 'app_locale.dart';

class AppStrings {
  const AppStrings(this._lang);

  final AppLanguage _lang;

  bool get _ru => _lang == AppLanguage.ru;

  String get appTitle => _ru ? 'Chat Volc' : 'Chat Volc';

  String get chats => _ru ? 'Чаты' : 'Chats';

  String get loginTitle => _ru ? 'Вход' : 'Sign in';

  String get loginSubtitle => _ru
      ? 'Войдите через Яндекс или ВК, чтобы начать переписку'
      : 'Sign in with Yandex or VK to start chatting';

  String get loginYandex => _ru ? 'Войти через Яндекс' : 'Sign in with Yandex';

  String get loginVk => _ru ? 'Войти через ВК' : 'Sign in with VK';

  String get loginDev => _ru ? 'Войти по email (тест)' : 'Sign in with email (dev)';

  String get email => _ru ? 'Email' : 'Email';

  String get emailHint => _ru ? 'name@yandex.ru' : 'name@yandex.ru';

  String get displayName => _ru ? 'Имя' : 'Name';

  String get displayNameHint => _ru ? 'Как вас показывать' : 'Display name';

  String get continueAction => _ru ? 'Продолжить' : 'Continue';

  String get logout => _ru ? 'Выйти' : 'Log out';

  String get search => _ru ? 'Поиск' : 'Search';

  String get searchHint =>
      _ru ? 'Имя или email' : 'Name or email';

  String get searchEmpty =>
      _ru ? 'Никого не нашли' : 'No users found';

  String get searchPrompt =>
      _ru ? 'Введите имя или почту' : 'Enter a name or email';

  String get newChat => _ru ? 'Новый чат' : 'New chat';

  String get emptyChats =>
      _ru ? 'Пока нет чатов. Найдите собеседника.' : 'No chats yet. Find someone.';

  String get messageHint => _ru ? 'Сообщение' : 'Message';

  String get send => _ru ? 'Отправить' : 'Send';

  String get cancel => _ru ? 'Отмена' : 'Cancel';

  String get save => _ru ? 'Сохранить' : 'Save';

  String get errorGeneric => _ru ? 'Что-то пошло не так' : 'Something went wrong';

  String get serverUnreachable => _ru
      ? 'Сервер недоступен. Проверьте, что бекенд на порту 8080.'
      : 'Server unreachable. Check backend on port 8080.';

  String get oauthNotConfigured => _ru
      ? 'OAuth не настроен. Задайте CLIENT_ID через --dart-define или войдите по email.'
      : 'OAuth is not configured. Pass CLIENT_ID via --dart-define or use email login.';

  String get you => _ru ? 'Вы' : 'You';

  String get providerYandex => 'Яндекс';

  String get providerVk => 'ВК';
}
