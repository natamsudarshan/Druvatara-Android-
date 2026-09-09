import 'package:flutter/material.dart';
import 'package:guardian_child/core/theme/app_theme.dart';
import 'package:guardian_child/core/localization/app_localizations.dart';

class ProtectionStatusCard extends StatelessWidget {
  const ProtectionStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    const status = 'PROTECTED';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shield,
                size: 50,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.protected,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.youAreProtected,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatusItem(context, Icons.vpn_key, 'VPN', true),
                _buildStatusItem(context, Icons.apps, 'Usage', true),
                _buildStatusItem(context, Icons.location_on, 'Location', true),
                _buildStatusItem(context, Icons.notifications_active, 'Notify', true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, IconData icon, String label, bool active) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: active ? AppTheme.successColor.withOpacity(0.1) : AppTheme.dividerColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: active ? AppTheme.successColor : AppTheme.textSecondaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: active ? AppTheme.successColor : AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}