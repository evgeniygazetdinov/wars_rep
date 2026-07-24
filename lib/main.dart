import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_locale.dart';
import 'l10n/app_locale_scope.dart';
import 'screens/chats_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_client.dart';
import 'services/session_controller.dart';
import 'theme/apple_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiClient();
  final session = SessionController(api);
  await session.load();
  runApp(ChatVolcApp(session: session));
}

class ChatVolcApp extends StatefulWidget {
  const ChatVolcApp({super.key, required this.session});

  final SessionController session;

  @override
  State<ChatVolcApp> createState() => _ChatVolcAppState();
}

const _appSupportedLocales = [
  Locale('en'),
  Locale('ru'),
];

const _appLocalizationsDelegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

class _ChatVolcAppState extends State<ChatVolcApp> {
  AppLocaleController? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
    widget.session.addListener(_onSession);
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSession);
    super.dispose();
  }

  void _onSession() {
    if (mounted) setState(() {});
  }

  Future<void> _loadLocale() async {
    final ctrl = await AppLocaleController.load();
    if (!mounted) return;
    setState(() => _locale = ctrl);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _locale;
    if (ctrl == null || !widget.session.ready) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppleTheme.light(),
        localizationsDelegates: _appLocalizationsDelegates,
        supportedLocales: _appSupportedLocales,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AppLocaleScope(
      controller: ctrl,
      child: ListenableBuilder(
        listenable: ctrl,
        builder: (context, _) {
          return MaterialApp(
            title: ctrl.strings.appTitle,
            debugShowCheckedModeBanner: false,
            locale: ctrl.locale,
            localizationsDelegates: _appLocalizationsDelegates,
            supportedLocales: _appSupportedLocales,
            theme: AppleTheme.light(),
            home: widget.session.isLoggedIn
                ? ChatsScreen(session: widget.session)
                : LoginScreen(session: widget.session),
          );
        },
      ),
    );
  }
}
