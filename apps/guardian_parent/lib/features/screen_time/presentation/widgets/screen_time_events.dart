import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class ScreenTimeEvents extends StatelessWidget {
  const ScreenTimeEvents({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock data
    final events = [
      {'type': 'LIMIT_REACHED', 'title': 'Daily limit reached', 'time': '2h ago', 'child': 'Alex', 'severity': 'HIGH'},
      {'type': 'WARNING_15', 'title': '15 minutes remaining', 'time': '3h ago', 'child': 'Alex', 'severity': 'MEDIUM'},
      {'type': 'WARNING_5', 'title': '5 minutes remaining', 'time': '3h 10m ago', 'child': 'Alex', 'severity': 'MEDIUM'},
      {'type': 'LIMIT_REACHED', 'title': 'App limit reached', 'time': 'Yesterday', 'child': 'Sam', 'severity': 'HIGH'},
      {'type': 'GRANTED', 'title': 'Extra time granted', 'time': 'Yesterday', 'child': 'Alex', 'severity': 'LOW'},
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
                  l10n.recentEvents,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(l10n.viewAll),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...events.map((event) => _EventTile(event: event)),
          ],
        ),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final Map<String, dynamic> event;

  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severity = event['severity'] as String;

    Color severityColor;
    IconData severityIcon;

    switch (severity) {
      case 'HIGH':
        severityColor = AppTheme.errorColor;
        severityIcon = Icons.error;
        break;
      case 'MEDIUM':
        severityColor = AppTheme.warningColor;
        severityIcon = Icons.warning_amber;
        break;
      default:
        severityColor = AppTheme.successColor;
        severityIcon = Icons.check_circle;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(severityIcon, color: severityColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event['title'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      event['time'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  event['child'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              event['type'] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                color: severityColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}