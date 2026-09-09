import 'package:flutter/material.dart';
import 'package:guardian_child/core/theme/app_theme.dart';
import 'package:guardian_child/core/localization/app_localizations.dart";

class QuickStatus extends StatelessWidget {
  const QuickStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final statusItems = [
      {'icon': Icons.web, 'label': 'Web Safety', 'status': 'Active', 'color': AppTheme.primaryColor},
      {'icon': Icons.location_on, 'label': 'Location', 'status': 'Sharing', 'color': AppTheme.successColor},
      {'icon': Icons.schedule, 'label': 'Bedtime', 'status': '21:00', 'color': AppTheme.warningColor},
      {'icon': Icons.apps, 'label': 'App Limits', 'status': '3 active', 'color': AppTheme.secondaryColor},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Status',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: statusItems.map((item) => Expanded(
                child: _StatusItem(item: item),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const _StatusItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = item['icon'] as IconData;
    final label = item['label'] as String;
    final status = item['status'] as String;
    final color = item['color'] as Color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}