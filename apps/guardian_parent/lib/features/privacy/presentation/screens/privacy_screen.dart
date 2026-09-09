import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';
import 'package:guardian_parent/features/privacy/presentation/widgets/privacy_policy.dart';
import 'package:guardian_parent/features/privacy/presentation/widgets/data_management.dart';
import 'package:guardian_parent/features/privacy/presentation/widgets/consent_management.dart';

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PrivacyPolicy(),
            const SizedBox(height: 16),
            const DataManagement(),
            const SizedBox(height: 16),
            const ConsentManagement(),
          ],
        ),
      ),
    );
  }
}