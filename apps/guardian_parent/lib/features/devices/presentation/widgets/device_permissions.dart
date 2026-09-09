import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class DevicePermissions extends StatelessWidget {
  final String deviceId;

  const DevicePermissions({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock permissions data
    final permissions = [
      {'name': l10n.usageAccess, 'icon': Icons.apps, 'status': true, 'mandatory': true},
      {'name': l10n.vpnPermission, 'icon': Icons.vpn_key, 'status': true, 'mandatory': true},
      {'name': l10n.locationPermission, 'icon': Icons.location_on, 'status': true, 'mandatory': true},
      {'name': l10n.backgroundLocation, 'icon': Icons.location_history, 'status': false, 'mandatory': false},
      {'name': l10n.notificationPermission, 'icon': Icons.notifications_active, 'status': true, 'mandatory': true},
      {'name': l10n.batteryOptimization, 'icon': Icons.battery_saver, 'status': false, 'mandatory': false},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.permissions,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.permissionsDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            ...permissions.map((perm) => _PermissionTile(permission: perm)),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final Map<String, dynamic> permission;

  const _PermissionTile({required this.permission});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = permission['status'] as bool;
    final mandatory = permission['mandatory'] as bool;
    final name = permission['name'] as String;
    final icon = permission['icon'] as IconData;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: status ? AppTheme.successColor.withOpacity(0.1) : AppTheme.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              permission['icon'] as IconData,
              color: status ? AppTheme.successColor : AppTheme.warningColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (mandatory) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Required',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.errorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  status ? 'Granted' : 'Not granted',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: status ? AppTheme.successColor : AppTheme.warningColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (!status)
            TextButton(
              onPressed: () {
                // Open permission settings
              },
              child: Text('Grant'),
            ),
        ],
      ),
    );
  }
}