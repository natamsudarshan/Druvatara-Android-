import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_child/core/theme/app_theme.dart';
import 'package:guardian_child/core/localization/app_localizations.dart';
import 'package:guardian_child/features/screen_time/presentation/widgets/child_screen_time_card.dart';
import 'package:guardian_child/features/screen_time/presentation/widgets/child_app_usage.dart';
import 'package:guardian_child/features/screen_time/presentation/widgets/child_schedule_status.dart';

class ScreenTimeScreen extends ConsumerWidget {
  const ScreenTimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.screenTime),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ChildScreenTimeCard(),
            const SizedBox(height: 16),
            const ChildAppUsage(),
            const SizedBox(height: 16),
            const ChildScheduleStatus(),
          ],
        ),
      ),
    );
  }
}