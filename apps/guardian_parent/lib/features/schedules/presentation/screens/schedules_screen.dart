import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_parent/core/theme/app_theme.dart'
import 'package:guardian_parent/core/localization/app_localizations.dart';
import 'package:guardian_parent/features/schedules/presentation/widgets/schedule_list.dart';
import 'package:guardian_parent/features/schedules/presentation/widgets/add_schedule_dialog.dart';
import 'package:guardian_parent/features/schedules/presentation/widgets/schedule_templates.dart';

class SchedulesScreen extends ConsumerWidget {
  const SchedulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.schedules),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const AddScheduleDialog(),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScheduleTemplates(),
            const SizedBox(height: 16),
            const ScheduleList(),
          ],
        ),
      ),
    );
  }
}