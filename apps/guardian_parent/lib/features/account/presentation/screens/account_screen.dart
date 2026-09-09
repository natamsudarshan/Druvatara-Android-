import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';
import 'package:guardian_parent/features/account/presentation/widgets/account_profile.dart';
import 'package:guardian_parent/features/account/presentation/widgets/account_security.dart';
import 'package:guardian_parent/features/account/presentation/widgets/account_preferences.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.account),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AccountProfile(),
            const SizedBox(height: 16),
            const AccountSecurity(),
            const SizedBox(height: 16),
            const AccountPreferences(),
          ],
        ),
      ),
    );
  }
}