import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class RequestList extends StatelessWidget {
  const RequestList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock data
    final requests = [
      {
        'id': 'req_1',
        'type': 'MORE_TIME',
        'resource': 'Screen Time',
        'resourceName': 'Daily Limit',
        'requestedValue': '30 minutes',
        'currentValue': '3h',
        'status': 'PENDING',
        'time': '2 min ago',
        'child': 'Alex',
      },
      {
        'id': 'req_2',
        'type': 'APP_ACCESS',
        'resource': 'TikTok',
        'resourceName': 'TikTok',
        'requestedValue': 'Allow access',
        'currentValue': 'Blocked',
        'status': 'PENDING',
        'time': '15 min ago',
        'child': 'Sam',
      },
      {
        'id': 'req_3',
        'type': 'WEBSITE_ACCESS',
        'resource': 'youtube.com',
        'resourceName': 'YouTube',
        'requestedValue': 'Allow access',
        'currentValue': 'Blocked (category: Entertainment)',
        'status': 'APPROVED',
        'time': '1 hour ago',
        'child': 'Alex',
      },
      {
        'id': 'req_4',
        'type': 'SCHEDULE_EXCEPTION',
        'resource': 'Bedtime',
        'resourceName': 'Bedtime Schedule',
        'requestedValue': 'Extend by 30 min',
        'currentValue': '21:00 - 07:00',
        'status': 'REJECTED',
        'time': '3 hours ago',
        'child': 'Sam',
      },
    ];

    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppTheme.textSecondaryColor),
            const SizedBox(height: 16),
            Text(
              'No requests',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Child requests will appear here',
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
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _RequestCard(request: request);
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = request['type'] as String;
    final status = request['status'] as String;

    Color typeColor;
    IconData typeIcon;
    String typeLabel;

    switch (type) {
      case 'MORE_TIME':
        typeColor = AppTheme.primaryColor;
        typeIcon = Icons.schedule;
        typeLabel = 'More Time';
        break;
      case 'APP_ACCESS':
        typeColor = AppTheme.secondaryColor;
        typeIcon = Icons.apps;
        typeLabel = 'App Access';
        break;
      case 'WEBSITE_ACCESS':
        typeColor = AppTheme.errorColor;
        typeIcon = Icons.web;
        typeLabel = 'Website Access';
        break;
      case 'SCHEDULE_EXCEPTION':
        typeColor = AppTheme.successColor;
        typeIcon = Icons.schedule;
        typeLabel = 'Schedule Exception';
        break;
      default:
        typeColor = AppTheme.textSecondaryColor;
        typeIcon = Icons.help_outline;
        typeLabel = 'Request';
    }

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (status) {
      case 'PENDING':
        statusColor = AppTheme.warningColor;
        statusLabel = 'Pending';
        statusIcon = Icons.hourglass_empty;
        break;
      case 'APPROVED':
        statusColor = AppTheme.successColor;
        statusLabel = 'Approved';
        statusIcon = Icons.check_circle;
        break;
      case 'REJECTED':
        statusColor = AppTheme.errorColor;
        statusLabel = 'Rejected';
        statusIcon = Icons.cancel;
        break;
      case 'MODIFIED':
        statusColor = AppTheme.primaryColor;
        statusLabel = 'Modified';
        statusIcon = Icons.edit;
        break;
      case 'EXPIRED':
        statusColor = AppTheme.textSecondaryColor;
        statusLabel = 'Expired';
        statusIcon = Icons.access_time;
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
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            typeLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusLabel,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request['child'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  request['time'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoColumn(
                    context,
                    'Requested',
                    request['requestedValue'],
                    Icons.arrow_upward,
                    typeColor,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.dividerColor,
                ),
                Expanded(
                  child: _buildInfoColumn(
                    context,
                    'Current',
                    request['currentValue'],
                    Icons.arrow_downward,
                    AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            if (status == 'PENDING') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.close, size: 18),
                      label: Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: BorderSide(color: AppTheme.errorColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.check, size: 18),
                      label: Text('Approve'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}