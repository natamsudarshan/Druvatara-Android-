import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';
import 'package:guardian_parent/features/screen_time/presentation/widgets/screen_time_limit_card.dart';
import 'package:guardian_parent/features/screen_time/presentation/widgets/screen_time_usage_chart.dart';
import 'package:guardian_parent/features/screen_time/presentation/widgets/app_usage_list.dart';
import 'package:guardian_parent/features/screen_time/presentation/widgets/screen_time_events.dart';

class ScreenTimeScreen extends ConsumerWidget {
  const ScreenTimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.screenTime),
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
            const ScreenTimeLimitCard(),
            const SizedBox(height: 16),
            const ScreenTimeUsageChart(),
            const SizedBox(height: 16),
            const AppUsageList(),
            const SizedBox(height: 16),
            const ScreenTimeEvents(),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, AppLocalizations l10n) {
    final dailyLimitController = TextEditingController(text: '3');
    final warning15Controller = TextEditingController(text: '15');
    final warning5Controller = TextEditingController(text: '5');
    final warning1Controller = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editScreenTimeLimits),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dailyLimitController,
                decoration: InputDecoration(
                  labelText: l10n.dailyLimitHours,
                  hintText: '3',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Text(l10n.warningThresholds, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: warning15Controller,
                      decoration: InputDecoration(
                        labelText: '15 ${l10n.minutes}',
                        hintText: '15',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: warning5Controller,
                      decoration: InputDecoration(
                        labelText: '5 ${l10n.minutes}',
                        hintText: '5',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: warning1Controller,
                      decoration: InputDecoration(
                        labelText: '1 ${l10n.minutes}',
                        hintText: '1',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}