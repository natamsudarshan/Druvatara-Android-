import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';
import 'package:guardian_parent/features/web_safety/presentation/widgets/web_safety_config.dart';
import 'package:guardian_parent/features/web_safety/presentation/widgets/blocked_categories.dart';
import 'package:guardian_parent/features/web_safety/presentation/widgets/allow_block_lists.dart';
import 'package:guardian_parent/features/web_safety/presentation/widgets/blocked_attempts.dart';

class WebSafetyScreen extends ConsumerWidget {
  const WebSafetyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.webSafety),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditDialog(context, l10n),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WebSafetyConfig(),
            const SizedBox(height: 16),
            const BlockedCategories(),
            const SizedBox(height: 16),
            const AllowBlockLists(),
            const SizedBox(height: 16),
            const BlockedAttempts(),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.webSafetySettings),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filter mode selector
              // Safe search toggle
              // Category checkboxes
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}