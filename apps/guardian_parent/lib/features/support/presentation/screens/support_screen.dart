import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';
import 'package:guardian_parent/features/support/presentation/widgets/faq_list.dart';
import 'package:guardian_parent/features/support/presentation/widgets/troubleshooting_guides.dart';
import 'package:guardian_parent/features/support/presentation/widgets/contact_support.dart';

class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.support),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ContactSupport(),
            const SizedBox(height: 16),
            const FAQList(),
            const SizedBox(height: 16),
            const TroubleshootingGuides(),
          ],
        ),
      ),
    );
  }
}