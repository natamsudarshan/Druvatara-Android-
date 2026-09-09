import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
import 'package:guardian_child/core/theme/app_theme.dart'
import 'package:guardian_child/core/localization/app_localizations.dart'
import 'package:guardian_child/features/privacy/presentation/widgets/child_privacy_policy.dart'
import 'package:guardian_child/features/privacy/presentation/widgets/data_collection_info.dart'
import 'package:guardian_child/features/privacy/presentation/widgets/your_rights.dart'

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
            const ChildPrivacyPolicy(),
            const SizedBox(height: 16),
            const DataCollectionInfo(),
            const SizedBox(height: 16),
            const YourRights(),
          ],
        ),
      ),
    );
  }
}