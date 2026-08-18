import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../l10n/app_locale_scope.dart';
import '../services/session_controller.dart';
import '../theme/apple_theme.dart';
import '../widgets/ios_grouped_section.dart';
import '../widgets/user_avatar.dart';
import 'login_screen.dart';
import '../widgets/apple_navigation.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.session});

  final SessionController session;

  String _providerLabel(String? provider, dynamic s) {
    switch (provider) {
      case 'yandex':
        return s.providerYandex;
      case 'vk':
        return s.providerVk;
      case 'local':
        return s.providerLocal;
      case 'google':
        return s.providerGoogle;
      default:
        return provider ?? '—';
    }
  }

  Future<void> _logout(BuildContext context) async {
    await session.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      applePageRoute(LoginScreen(session: session)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocaleScope.of(context).strings;
    final user = session.user;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(s.profileTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppleTheme.groupedBackground,
      appBar: AppBar(title: Text(s.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          Center(
            child: UserAvatar(user: user, radius: 48),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              user.username,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          if (user.email != null && user.email!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(
                user.email!,
                style: const TextStyle(color: AppleTheme.secondaryLabel),
              ),
            ),
          ],
          const SizedBox(height: 28),
          IosGroupedSection(
            header: s.profileAccount,
            children: [
              IosListRow(
                icon: Icons.person_outline,
                title: s.displayName,
                subtitle: user.username,
                onTap: () {},
              ),
              if (user.email != null)
                IosListRow(
                  icon: Icons.mail_outline,
                  title: s.email,
                  subtitle: user.email!,
                  onTap: () {},
                ),
              IosListRow(
                icon: Icons.link,
                title: s.profileProvider,
                subtitle: _providerLabel(user.provider, s),
                onTap: () {},
              ),
            ],
          ),
          IosGroupedSection(
            children: [
              IosListRow(
                icon: CupertinoIcons.square_arrow_right,
                title: s.logout,
                iconBackground: AppleTheme.red,
                onTap: () => _logout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
