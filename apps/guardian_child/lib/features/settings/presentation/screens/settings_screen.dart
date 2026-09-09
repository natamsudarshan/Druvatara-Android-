import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_child/core/theme/app_theme.dart';
import 'package:guardian_child/core/localization/app_localizations.dart';
import 'package:guardian_child/features/settings/presentation/widgets/child_settings_sections.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: const ChildSettingsSections(),
    );
  }
}