import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class DeviceHealthCard extends StatelessWidget {
  final Map<String, dynamic> device;

  const DeviceHealthCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock health data
    final healthChecks = [
      {'name': l10n.backendConnected, 'status': true, 'icon': Icons.cloud_done},
      {'name': l10n.authValid, 'status': true, 'icon': Icons.verified},
      {'name': l10n.usageAccess, 'status': true, 'icon': Icons.apps},
      {'name': l10n.vpnActive, 'status': true, 'icon': Icons.vpn_key},
      {'name': l10n.locationEnabled, 'status': true, 'icon': Icons.location_on},
      {'name': l10n.notificationsEnabled, 'status': true, 'icon': Icons.notifications_active},
      {'name': l10n.backgroundService, 'status': true, 'icon': Icons.settings_suggest'},
      {'name': l10n.batteryOptimized, 'status': false, 'icon': Icons.battery_saver},
    ];

    final passed = healthChecks.where((h) => h['status'] == true).length;
    final total = healthChecks.length;

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
                  l10n.deviceHealth,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$passed/$total ${l10n.checksPassed}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            ...healthChecks.map((check) => _HealthCheckTile(check: check)),
          ],
        ),
      ),
    );
  }
}

class _HealthCheckTile extends StatelessWidget {
  final Map<String, dynamic> check;

  const _HealthCheckTile({required this.check});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = check['status'] as bool;
    final name = check['name'] as String;
    final icon = check['icon'] as IconData;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: status ? AppTheme.successColor.withOpacity(0.1) : AppTheme.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              check['icon'] as IconData,
              color: status ? AppTheme.successColor : AppTheme.errorColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Icon(
            status ? Icons.check_circle : Icons.cancel,
            color: status ? AppTheme.successColor : AppTheme.errorColor,
          ),
        ],
      ),
    );
  }
}