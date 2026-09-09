import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
import 'package:guardian_child/core/theme/app_theme.dart';
import 'package:guardian_child/core/localization/app_localizations.dart';
import 'package:guardian_child/features/help/presentation/widgets/help_faq.dart';
import 'package:guardian_child/features/help/presentation/widgets/help_guides.dart';
import 'package:guardian_child/features/help/presentation/widgets/help_contact.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.help),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HelpContact(),
            const SizedBox(height: 16),
            const HelpFaq(),
            const SizedBox(height: 16),
            const HelpGuides(),
          ],
        ),
      ),
    );
  }
}