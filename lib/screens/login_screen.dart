import 'package:flutter/foundation.dart';
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
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _busy = false;
  bool _showDevForm = false;
  bool _showEmailForm = false;
  bool _registerMode = false;
  String? _error;
  String _devProvider = 'yandex';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
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
        if (kDebugMode) _showDevForm = true;
      });
      return;
    }
    if (provider == 'vk' && !ApiConfig.hasVkOAuth) {
      setState(() {
        _error = s.oauthNotConfigured;
        if (kDebugMode) _showDevForm = true;
      });
      return;
    }
    await _run(() async {
      final authUrl = provider == 'yandex'
          ? OAuthService.yandexAuthUrl()
          : OAuthService.vkAuthUrl();
      await OAuthService.openBrowser(authUrl);
      if (!mounted) return;
      final pasted = await showDialog<String>(
        context: context,
        builder: (ctx) {
          final ctrl = TextEditingController();
          return AlertDialog(
            title: Text(s.oauthCompleteTitle),
            content: TextField(
              controller: ctrl,
              autofocus: true,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: s.oauthCompleteHint,
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
        throw StateError(s.oauthTokenNotFound);
      }
      await widget.session.loginOAuth(
        provider: provider,
        providerAccessToken: token,
      );
    });
  }

  Future<void> _emailAuth() async {
    final s = AppLocaleScope.of(context).strings;
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || !email.contains('@') || password.isEmpty) {
      setState(() => _error = s.devLoginValidation);
      return;
    }
    if (_registerMode) {
      final name = _nameCtrl.text.trim();
      if (name.isEmpty) {
        setState(() => _error = s.devLoginValidation);
        return;
      }
      await _run(() => widget.session.register(
            email: email,
            password: password,
            username: name,
          ));
    } else {
      await _run(() => widget.session.loginPassword(
            email: email,
            password: password,
          ));
    }
  }

  Future<void> _devLogin() async {
    final s = AppLocaleScope.of(context).strings;
    final email = _emailCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    if (email.isEmpty || name.isEmpty || !email.contains('@')) {
      setState(() => _error = s.devLoginValidation);
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
            GestureDetector(
              onLongPress: kDebugMode
                  ? () => setState(() => _showDevForm = !_showDevForm)
                  : null,
              child: Text(
                'Chat Volc',
                style: theme.textTheme.displaySmall,
              ),
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
                      : 'YANDEX_CLIENT_ID',
                  iconBackground: const Color(0xFFFC3F1D),
                  onTap: _busy ? () {} : () => _oauth('yandex'),
                ),
                IosListRow(
                  icon: Icons.chat_bubble_outline,
                  title: s.loginVk,
                  subtitle: ApiConfig.hasVkOAuth ? s.providerVk : 'VK_CLIENT_ID',
                  iconBackground: const Color(0xFF0077FF),
                  onTap: _busy ? () {} : () => _oauth('vk'),
                ),
                IosListRow(
                  icon: Icons.lock_outline,
                  title: s.loginEmail,
                  subtitle: s.email,
                  iconBackground: AppleTheme.blue,
                  onTap: _busy
                      ? () {}
                      : () => setState(() {
                            _showEmailForm = !_showEmailForm;
                            _registerMode = false;
                          }),
                ),
              ],
            ),
            if (_showEmailForm) ...[
              const SizedBox(height: 8),
              IosGroupedSection(
                header: _registerMode ? s.registerTitle : s.loginTitle,
                children: [
                  if (_registerMode)
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
                  if (_registerMode)
                    const Divider(height: 0.5, thickness: 0.5),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      _registerMode ? 4 : 12,
                      16,
                      4,
                    ),
                    child: TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: s.email,
                        hintText: s.emailHint,
                      ),
                    ),
                  ),
                  const Divider(height: 0.5, thickness: 0.5),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: TextField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _emailAuth(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: s.password,
                        hintText: s.passwordHint,
                      ),
                    ),
                  ),
                ],
              ),
              FilledButton(
                onPressed: _busy ? null : _emailAuth,
                child: Text(_registerMode ? s.registerAction : s.continueAction),
              ),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() => _registerMode = !_registerMode),
                child: Text(_registerMode ? s.haveAccount : s.noAccount),
              ),
            ],
            if (kDebugMode && _showDevForm) ...[
              const SizedBox(height: 8),
              IosGroupedSection(
                header: s.devLoginHeader,
                footer: s.devLoginFooter(ApiConfig.baseUrl),
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
                child: Text(s.loginDev),
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
