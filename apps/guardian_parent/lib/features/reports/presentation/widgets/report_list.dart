import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class ReportList extends StatelessWidget {
  const ReportList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock data
    final reports = [
      {
        'id': 'report_1',
        'type': 'WEEKLY',
        'child': 'Alex',
        'period': 'Aug 12 - Aug 18, 2026',
        'generated': 'Aug 18, 2026',
        'status': 'READY',
      },
      {
        'id': 'report_2',
        'type': 'WEEKLY',
        'child': 'Sam',
        'period': 'Aug 12 - Aug 18, 2026',
        'generated': 'Aug 18, 2026',
        'status': 'READY',
      },
      {
        'id': 'report_3',
        'type': 'MONTHLY',
        'child': 'Alex',
        'period': 'July 2026',
        'generated': 'Aug 1, 2026',
        'status': 'READY',
      },
    ];

    return Column(
      children: [
        // Report types
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Types',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _ReportTypeTile(
                      id: 'DAILY',
                      name: 'Daily Summary',
                      icon: Icons.today,
                      color: AppTheme.primaryColor,
                      onTap: () {},
                    ),
                    _ReportTypeTile(
                      id: 'WEEKLY',
                      name: 'Weekly Report',
                      icon: Icons.date_range,
                      color: AppTheme.secondaryColor,
                      onTap: () {},
                    ),
                    _ReportTypeTile(
                      id: 'MONTHLY',
                      name: 'Monthly Report',
                      icon: Icons.calendar_month,
                      color: AppTheme.successColor,
                      onTap: () {},
                    ),
                    _ReportTypeTile(
                      id: 'SAFETY',
                      name: 'Safety Report',
                      icon: Icons.shield,
                      color: AppTheme.warningColor,
                      onTap: () {},
                    ),
                    _ReportTypeTile(
                      id: 'USAGE',
                      name: 'Usage Report',
                      icon: Icons.analytics,
                      color: AppTheme.accentColor,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Generated reports
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Generated Reports',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...reports.map((report) => _ReportTile(report: report)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportTypeTile extends StatelessWidget {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ReportTypeTile({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final Map<String, dynamic> report;

  const _ReportTile({required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = report['type'] as String;
    final status = report['status'] as String;

    Color typeColor;
    IconData typeIcon;

    switch (type) {
      case 'DAILY':
        typeColor = AppTheme.primaryColor;
        typeIcon = Icons.today;
        break;
      case 'WEEKLY':
        typeColor = AppTheme.secondaryColor;
        typeIcon = Icons.date_range;
        break;
      case 'MONTHLY':
        typeColor = AppTheme.successColor;
        typeIcon = Icons.calendar_month;
        break;
      default:
        typeColor = AppTheme.textSecondaryColor;
        typeIcon = Icons.description;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(typeIcon, color: typeColor, size: 24),
        ),
        title: Text(
          '$type Report - ${report['child']}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${report['period']}'),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 4),
                Text('Generated: ${report['generated']}'),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Ready',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.successColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () {},
      ),
    );
  }
}