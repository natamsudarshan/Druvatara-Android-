import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class ProtectionStatusCard extends StatelessWidget {
  const ProtectionStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock data - would come from provider
    const status = 'PROTECTED';
    const devicesOnline = 2;
    const devicesTotal = 2;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'PROTECTED':
        statusColor = AppTheme.successColor;
        statusIcon = Icons.shield;
        statusText = l10n.protected;
        break;
      case 'PARTIALLY_PROTECTED':
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.warning_amber;
        statusText = l10n.attentionRequired;
        break;
      case 'OFFLINE':
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.wifi_off;
        statusText = l10n.offline;
        break;
      default:
        statusColor = AppTheme.textSecondaryColor;
        statusIcon = Icons.help_outline;
        statusText = l10n.attentionRequired;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$devicesOnline of $devicesTotal ${l10n.devicesOnline}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatusItem(
                  context,
                  Icons.vpn_key,
                  l10n.vpnActive,
                  true,
                ),
                _buildStatusItem(
                  context,
                  Icons.apps,
                  l10n.usageAccess,
                  true,
                ),
                _buildStatusItem(
                  context,
                  Icons.location_on,
                  l10n.locationEnabled,
                  true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, IconData icon, String label, bool isActive) {
    final theme = Theme.of(context);
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: isActive ? AppTheme.successColor : AppTheme.textSecondaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isActive ? AppTheme.successColor : AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}