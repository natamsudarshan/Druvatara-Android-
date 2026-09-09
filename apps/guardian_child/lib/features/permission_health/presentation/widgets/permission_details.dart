import 'package:flutter/material.dart';
import 'package:guardian_child/core/theme/app_theme.dart';
import 'package:guardian_child/core/localization/app_localizations.dart';

class PermissionDetails extends StatelessWidget {
  const PermissionDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock permissions data
    final permissions = [
      {
        'name': 'Notifications',
        'icon': Icons.notifications_active,
        'description': 'Receive alerts and updates from your parents',
        'status': true,
        'mandatory': true,
        'action': 'Granted',
      },
      {
        'name': 'Usage Access',
        'icon': Icons.apps,
        'description': 'Allow monitoring of app usage and screen time',
        'status': true,
        'mandatory': true,
        'action': 'Granted',
      },
      {
        'name': 'Location',
        'icon': Icons.location_on,
        'description': 'Share your location for safety and safe zones',
        'status': true,
        'mandatory': true,
        'action': 'Granted',
      },
      {
        'name': 'Background Location',
        'icon': Icons.location_history,
        'description': 'Enable safe zone alerts even when app is closed',
        'status': false,
        'mandatory': false,
        'action': 'Enable',
      },
      {
        'name': 'VPN Permission',
        'icon': Icons.vpn_key,
        'description': 'Enable web safety filtering and threat blocking',
        'status': true,
        'mandatory': true,
        'action': 'Granted',
      },
      {
        'name': 'Battery Optimization',
        'icon': Icons.battery_saver,
        'description': 'Disable battery optimization for continuous protection',
        'status': false,
        'mandatory': false,
        'action': 'Disable',
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permission Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Control what data you share with us',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            ...permissions.map((permission) => _PermissionTile(permission: permission)),
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
    final description = permission['description'] as String;
    final icon = permission['icon'] as IconData;
    final action = permission['action'] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
                      permission['name'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (permission['mandatory'] as bool) ...[
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
                  permission['description'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Open permission settings
            },
            child: Text(permission['action'] as String),
          ),
        ],
      ),
    );
  }
}