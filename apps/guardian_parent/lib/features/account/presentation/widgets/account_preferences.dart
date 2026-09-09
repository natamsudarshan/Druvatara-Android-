import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class AccountPreferences extends StatelessWidget {
  const AccountPreferences({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.preferences,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _PreferenceTile(
              icon: Icons.language_outlined,
              title: l10n.language,
              subtitle: 'English',
              onTap: () {},
            ),
            _PreferenceTile(
              icon: Icons.access_time_outlined,
              title: l10n.timezone,
              subtitle: 'Asia/Kolkata',
              onTap: () {},
            ),
            _PreferenceTile(
              icon: Icons.notifications_outlined,
              title: l10n.notifications,
              subtitle: l10n.manageNotifications,
              onTap: () {},
            ),
            _PreferenceTile(
              icon: Icons.brightness_6_outlined,
              title: l10n.theme,
              subtitle: 'System default',
              onTap: () {},
            ),
            _PreferenceTile(
              icon: Icons.data_usage_outlined,
              title: l10n.dataUsage,
              subtitle: l10n.manageDataUsage,
              onTap: () {},
            ),
            _PreferenceTile(
              icon: Icons.backup_outlined,
              title: l10n.backupSync,
              subtitle: l10n.manageBackup,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PreferenceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.textSecondaryColor),
            ],
          ),
        ),
      ),
    );
  }
}