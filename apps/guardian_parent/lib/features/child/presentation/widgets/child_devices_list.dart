import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';
import 'package:go_router/go_router.dart';

class ChildDevicesList extends StatelessWidget {
  final String childId;

  const ChildDevicesList({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock data
    final devices = [
      {
        'id': 'dev_1',
        'name': 'Alex Phone',
        'platform': 'ANDROID',
        'status': 'ACTIVE',
        'lastSeen': '2 min ago',
        'battery': 85,
      },
    ];

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.devices,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.go('/pairing/$childId'),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addDevice),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...devices.map((device) => _DeviceTile(device: device)),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final Map<String, dynamic> device;

  const _DeviceTile({required this.device});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = device['status'] as String;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'ACTIVE':
        statusColor = AppTheme.successColor;
        statusText = 'Protected';
        statusIcon = Icons.check_circle;
        break;
      case 'PARTIALLY_PROTECTED':
        statusColor = AppTheme.warningColor;
        statusText = 'Attention needed';
        statusIcon = Icons.warning_amber;
        break;
      case 'OFFLINE':
        statusColor = AppTheme.errorColor;
        statusText = 'Offline';
        statusIcon = Icons.wifi_off;
        break;
      default:
        statusColor = AppTheme.textSecondaryColor;
        statusText = 'Unknown';
        statusIcon = Icons.help_outline;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        child: Icon(
          device['platform'] == 'ANDROID' ? Icons.android : Icons.phone_iphone,
          color: AppTheme.primaryColor,
        ),
      ),
      title: Text(
        device['name'] as String,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(device['platform'] as String),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.battery_charging_full, size: 14, color: AppTheme.textSecondaryColor),
              const SizedBox(width: 4),
              Text('${device['battery']}%'),
              const SizedBox(width: 12),
              Icon(Icons.access_time, size: 14, color: AppTheme.textSecondaryColor),
              const SizedBox(width: 4),
              Text(device['lastSeen'] as String),
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
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
                  statusText,
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
      onTap: () {},
    );
  }
}