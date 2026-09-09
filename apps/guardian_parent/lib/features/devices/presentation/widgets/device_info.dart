import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class DeviceInfo extends StatelessWidget {
  final Map<String, dynamic> device;

  const DeviceInfo({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final status = device['status'] as String;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'ACTIVE':
        statusColor = AppTheme.successColor;
        statusText = l10n.protected;
        statusIcon = Icons.check_circle;
        break;
      case 'PARTIALLY_PROTECTED':
        statusColor = AppTheme.warningColor;
        statusText = l10n.attentionRequired;
        statusIcon = Icons.warning_amber;
        break;
      case 'OFFLINE':
        statusColor = AppTheme.errorColor;
        statusText = l10n.offline;
        statusIcon = Icons.wifi_off;
        break;
      default:
        statusColor = AppTheme.textSecondaryColor;
        statusText = l10n.unknown;
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryDarkColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(
                  device['platform'] == 'ANDROID' ? Icons.android : Icons.phone_iphone,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device['name'] as String,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${device['childName']} • ${device['platform']}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white30),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoItem(
                context,
                l10n.lastSeen,
                device['lastSeen'] as String,
                Icons.access_time,
              ),
              _buildInfoItem(
                context,
                l10n.battery,
                '${device['battery']}%',
                Icons.battery_charging_full,
              ),
              _buildInfoItem(
                context,
                l10n.appVersion,
                device['appVersion'] as String,
                Icons.info_outline,
              ),
              _buildInfoItem(
                context,
                l10n.osVersion,
                device['osVersion'] as String,
                Icons.phone_android,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoItem(
                context,
                l10n.manufacturer,
                device['manufacturer'] as String,
                Icons.business,
              ),
              _buildInfoItem(
                context,
                l10n.model,
                device['model'] as String,
                Icons.device_hub,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}