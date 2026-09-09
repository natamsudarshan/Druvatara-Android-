import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class ScheduleTemplates extends StatelessWidget {
  const ScheduleTemplates({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final templates = [
      {
        'id': 'bedtime',
        'name': l10n.bedtime,
        'description': l10n.bedtimeDescription,
        'icon': Icons.bedtime,
        'color': AppTheme.primaryColor,
        'defaultStart': '21:00',
        'defaultEnd': '07:00',
      },
      {
        'id': 'school',
        'name': l10n.schoolTime,
        'description': l10n.schoolTimeDescription,
        'icon': Icons.school,
        'color': AppTheme.secondaryColor,
        'defaultStart': '08:00',
        'defaultEnd': '15:00',
      },
      {
        'id': 'homework',
        'name': l10n.homeworkTime,
        'description': l10n.homeworkTimeDescription,
        'icon': Icons.assignment,
        'color': AppTheme.successColor,
        'defaultStart': '16:00',
        'defaultEnd': '18:00',
      },
      {
        'id': 'dinner',
        'name': l10n.familyDinner,
        'description': l10n.familyDinnerDescription,
        'icon': Icons.restaurant,
        'color': AppTheme.accentColor,
        'defaultStart': '19:00',
        'defaultEnd': '20:00',
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.scheduleTemplates,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...templates.map((template) => _TemplateTile(template: template)),
          ],
        ),
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  final Map<String, dynamic> template;

  const _TemplateTile({required this.template});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = template['color'] as Color;
    final name = template['name'] as String;
    final description = template['description'] as String;
    final icon = template['icon'] as IconData;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: AppTheme.textSecondaryColor),
                        const SizedBox(width: 4),
                        Text(
                          '${template['defaultStart']} - ${template['defaultEnd']}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}