import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../l10n/app_locale_scope.dart';
import '../services/api_client.dart';
import '../services/oauth_service.dart';
import '../services/session_controller.dart';
import '../theme/apple_theme.dart';
import '../widgets/ios_grouped_section.dart';
import '../widgets/language_switch_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.session});

  final SessionController session;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _busy = false;
  bool _showDevForm = false;
  String? _error;
  String _devProvider = 'yandex';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _oauth(String provider) async {
    final s = AppLocaleScope.of(context).strings;
    if (provider == 'yandex' && !ApiConfig.hasYandexOAuth) {
      setState(() {
        _error = s.oauthNotConfigured;
        _showDevForm = true;
      });
      return;
    }
    if (provider == 'vk' && !ApiConfig.hasVkOAuth) {
      setState(() {
        _error = s.oauthNotConfigured;
        _showDevForm = true;
      });
      return;
    }
    await _run(() async {
      final authUrl =
          provider == 'yandex' ? OAuthService.yandexAuthUrl() : OAuthService.vkAuthUrl();
      await OAuthService.openBrowser(authUrl);
      if (!mounted) return;
      final pasted = await showDialog<String>(
        context: context,
        builder: (ctx) {
          final ctrl = TextEditingController();
          return AlertDialog(
            title: const Text('Завершение входа'),
            content: TextField(
              controller: ctrl,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Вставьте URL после редиректа или access_token',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(s.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, ctrl.text),
                child: Text(s.continueAction),
              ),
            ],
          );
        },
      );
      if (pasted == null || pasted.trim().isEmpty) return;
      final token = OAuthService.extractToken(pasted);
      if (token == null) {
        throw StateError('Не удалось найти access_token');
      }
      await widget.session.loginOAuth(
        provider: provider,
        providerAccessToken: token,
      );
    });
  }

  Future<void> _devLogin() async {
    final email = _emailCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    if (email.isEmpty || name.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Укажите имя и корректный email');
      return;
    }
    await _run(() => widget.session.loginDev(
          email: email,
          username: name,
          provider: _devProvider,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocaleScope.of(context).strings;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppleTheme.groupedBackground,
      appBar: AppBar(
        title: Text(s.loginTitle),
        actions: const [LanguageSwitchButton()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            Text(
              'Chat Volc',
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              s.loginSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppleTheme.secondaryLabel,
              ),
            ),
            const SizedBox(height: 28),
            IosGroupedSection(
              children: [
                IosListRow(
                  icon: Icons.mail_outline,
                  title: s.loginYandex,
                  subtitle: ApiConfig.hasYandexOAuth
                      ? s.providerYandex
                      : 'нужен YANDEX_CLIENT_ID',
                  iconBackground: const Color(0xFFFC3F1D),
                  onTap: _busy ? () {} : () => _oauth('yandex'),
                ),
                IosListRow(
                  icon: Icons.chat_bubble_outline,
                  title: s.loginVk,
                  subtitle: ApiConfig.hasVkOAuth ? s.providerVk : 'нужен VK_CLIENT_ID',
                  iconBackground: const Color(0xFF0077FF),
                  onTap: _busy ? () {} : () => _oauth('vk'),
                ),
              ],
            ),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() => _showDevForm = !_showDevForm),
              child: Text(s.loginDev),
            ),
            if (_showDevForm) ...[
              const SizedBox(height: 8),
              IosGroupedSection(
                header: 'Тестовый вход',
                footer:
                    'Работает при ALLOW_DEV_AUTH=1 на бекенде. API: ${ApiConfig.baseUrl}',
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: TextField(
                      controller: _nameCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: s.displayName,
                        hintText: s.displayNameHint,
                      ),
                    ),
                  ),
                  const Divider(height: 0.5, thickness: 0.5),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _devLogin(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: s.email,
                        hintText: s.emailHint,
                      ),
                    ),
                  ),
                  const Divider(height: 0.5, thickness: 0.5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: Text(s.providerYandex),
                          selected: _devProvider == 'yandex',
                          onSelected: (_) =>
                              setState(() => _devProvider = 'yandex'),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(s.providerVk),
                          selected: _devProvider == 'vk',
                          onSelected: (_) => setState(() => _devProvider = 'vk'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              FilledButton(
                onPressed: _busy ? null : _devLogin,
                child: Text(s.continueAction),
              ),
            ],
            if (_busy) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppleTheme.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
