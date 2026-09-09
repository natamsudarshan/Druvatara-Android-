import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class AlertList extends StatelessWidget {
  const AlertList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock data
    final alerts = [
      {
        'id': 'alert_1',
        'type': 'SCREEN_TIME_LIMIT_REACHED',
        'title': 'Daily limit reached',
        'message': 'Alex has reached the 3h daily screen time limit',
        'severity': 'HIGH',
        'status': 'NEW',
        'time': '2 min ago',
        'child': 'Alex',
      },
      {
        'id': 'alert_2',
        'type': 'GEOFENCE_EXITED',
        'title': 'Left safe zone',
        'message': 'Alex left the "School" safe zone',
        'severity': 'MEDIUM',
        'status': 'NEW',
        'time': '15 min ago',
        'child': 'Alex',
      },
      {
        'id': 'alert_3',
        'type': 'APP_LIMIT_REACHED',
        'title': 'App limit reached',
        'message': 'YouTube time limit (1h) reached',
        'severity': 'MEDIUM',
        'status': 'ACKNOWLEDGED',
        'time': '1 hour ago',
        'child': 'Sam',
      },
      {
        'id': 'alert_4',
        'type': 'WEB_CATEGORY_BLOCKED',
        'title': 'Website blocked',
        'message': 'Attempt to access gambling site blocked',
        'severity': 'HIGH',
        'status': 'NEW',
        'time': '3 hours ago',
        'child': 'Alex',
      },
      {
        'id': 'alert_5',
        'type': 'VPN_DISABLED',
        'title': 'VPN disabled',
        'message': 'Web filtering VPN was turned off on Alex Phone',
        'severity': 'HIGH',
        'status': 'NEW',
        'time': '4 hours ago',
        'child': 'Alex',
      },
    ];

    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: AppTheme.successColor),
            const SizedBox(height: 16),
            Text(
              l10n.noAlerts,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.allCaughtUp,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return _AlertCard(alert: alert);
      },
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Map<String, dynamic> alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severity = alert['severity'] as String;
    final status = alert['status'] as String;

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

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (status) {
      case 'NEW':
        statusColor = AppTheme.errorColor;
        statusLabel = 'New';
        statusIcon = Icons.fiber_new;
        break;
      case 'ACKNOWLEDGED':
        statusColor = AppTheme.warningColor;
        statusLabel = 'Acknowledged';
        statusIcon = Icons.visibility;
        break;
      case 'RESOLVED':
        statusColor = AppTheme.successColor;
        statusLabel = 'Resolved';
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = AppTheme.textSecondaryColor;
        statusLabel = status;
        statusIcon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      Text(
                        alert['title'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alert['child'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: severityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        severity,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: severityColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              alert['message'],
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  alert['time'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const Spacer(),
                if (status == 'NEW') ...[
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check, size: 16),
                    label: Text('Acknowledge'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.psychology, size: 16),
                    label: Text('Ask TARA'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ] else if (status == 'ACKNOWLEDGED') ...[
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check, size: 16),
                    label: Text('Resolve'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}