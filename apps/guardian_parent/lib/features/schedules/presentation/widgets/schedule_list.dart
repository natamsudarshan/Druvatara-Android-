import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class ScheduleList extends StatelessWidget {
  const ScheduleList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock data
    final schedules = [
      {
        'id': 'sched_1',
        'name': 'Bedtime',
        'type': 'BEDTIME',
        'start': '21:00',
        'end': '07:00',
        'days': [1, 2, 3, 4, 5, 6, 7],
        'active': true,
      },
      {
        'id': 'sched_2',
        'name': 'School Time',
        'type': 'SCHOOL',
        'start': '08:00',
        'end': '15:00',
        'days': [1, 2, 3, 4, 5],
        'active': true,
      },
      {
        'id': 'sched_3',
        'name': 'Homework',
        'type': 'CUSTOM',
        'start': '16:00',
        'end': '18:00',
        'days': [1, 2, 3, 4, 5],
        'active': false,
      },
    ];

    if (schedules.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.schedule_outlined, size: 48, color: AppTheme.textSecondaryColor),
              const SizedBox(height: 16),
              Text(
                l10n.noSchedulesYet,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.addScheduleDescription,
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
                  l10n.schedules,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${schedules.where((s) => s['active'] == true).length}/${schedules.length} ${l10n.active}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
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

    final days = schedule['days'] as List<int>;
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final activeDays = days.map((d) => dayLabels[d - 1]).join(', ');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: typeColor.withOpacity(0.1),
        child: Icon(typeIcon, color: typeColor),
      ),
      title: Text(
        schedule['name'],
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
          const SizedBox(height: 4),
          Text(
            activeDays,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
      trailing: Switch(
        value: active,
        onChanged: (value) {},
        activeColor: AppTheme.primaryColor,
      ),
      onTap: () {},
    );
  }
}