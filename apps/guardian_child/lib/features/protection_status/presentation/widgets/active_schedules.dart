import 'package:flutter/material.dart';
import 'package:guardian_child/core/theme/app_theme.dart';
import 'package:guardian_child/core/localization/app_localizations.dart';

class ActiveSchedules extends StatelessWidget {
  const ActiveSchedules({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock data
    final schedules = [
      {
        'name': 'Bedtime',
        'type': 'BEDTIME',
        'start': '21:00',
        'end': '07:00',
        'active': true,
      },
      {
        'name': 'School Time',
        'type': 'SCHOOL',
        'start': '08:00',
        'end': '15:00',
        'active': true,
      },
    ];

    if (schedules.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.schedule_outlined, size: 48, color: AppTheme.textSecondaryColor),
              const SizedBox(height: 12),
              Text(
                'No active schedules',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Schedules help automate screen time limits',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.activeSchedules,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...schedules.map((schedule) => _ScheduleTile(schedule: schedule)),
        ],
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  final Map<String, dynamic> schedule;

  const _ScheduleTile({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = schedule['active'] as bool;
    final name = schedule['name'] as String;
    final type = schedule['type'] as String;

    IconData typeIcon;
    String typeLabel;
    Color typeColor;

    switch (type) {
      case 'BEDTIME':
        typeIcon = Icons.bedtime;
        typeLabel = 'Bedtime';
        typeColor = AppTheme.primaryColor;
        break;
      case 'SCHOOL':
        typeIcon = Icons.school;
        typeLabel = 'School';
        typeColor = AppTheme.secondaryColor;
        break;
      default:
        typeIcon = Icons.schedule;
        typeLabel = 'Custom';
        typeColor = AppTheme.successColor;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: typeColor.withOpacity(0.1),
        child: Icon(typeIcon, color: typeColor),
      ),
      title: Text(
        name,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: active ? null : AppTheme.textSecondaryColor,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  typeLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: typeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${schedule['start']} - ${schedule['end']}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Switch(
        value: active,
        onChanged: (v) {},
        activeColor: AppTheme.primaryColor,
      ),
    );
  }
}