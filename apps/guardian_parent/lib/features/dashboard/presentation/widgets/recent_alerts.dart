import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';
import 'package:go_router/go_router.dart';

class RecentAlerts extends StatelessWidget {
  const RecentAlerts({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock data
    final alerts = [
      {
        'type': 'SCREEN_TIME_LIMIT_REACHED',
        'title': 'Daily limit reached',
        'message': 'Alex has reached the 3h daily screen time limit',
        'severity': 'HIGH',
        'time': '2 min ago',
        'childName': 'Alex',
      },
      {
        'type': 'GEOFENCE_EXITED',
        'title': 'Left safe zone',
        'message': 'Alex left the "School" safe zone',
        'severity': 'MEDIUM',
        'time': '15 min ago',
        'childName': 'Alex',
      },
      {
        'type': 'APP_LIMIT_REACHED',
        'title': 'App limit reached',
        'message': 'YouTube time limit (1h) reached',
        'severity': 'MEDIUM',
        'time': '1 hour ago',
        'childName': 'Sam',
      },
      {
        'type': 'WEB_CATEGORY_BLOCKED',
        'title': 'Website blocked',
        'message': 'Attempt to access gambling site blocked',
        'severity': 'HIGH',
        'time': '3 hours ago',
        'childName': 'Alex',
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
                  l10n.recentAlerts,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/alerts'),
                  child: Text(l10n.viewAll),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...alerts.map((alert) => _AlertTile(alert: alert, onTap: () => context.go('/alerts'))),
            if (alerts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline, size: 48, color: AppTheme.successColor),
                      const SizedBox(height: 12),
                      Text(
                        l10n.noAlerts,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final Map<String, String> alert;
  final VoidCallback onTap;

  const _AlertTile({required this.alert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severity = alert['severity'] ?? 'LOW';

    Color severityColor;
    IconData severityIcon;

    switch (severity) {
      case 'CRITICAL':
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
        severityIcon = Icons.info_outline;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                          alert['title'] ?? '',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        alert['time'] ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert['message'] ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: severityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          alert['childName'] ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: severityColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}