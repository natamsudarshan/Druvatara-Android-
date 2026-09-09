import 'package:flutter/material.dart';
import 'package:guardian_child/core/theme/app_theme.dart';
import 'package:guardian_child/core/localization/app_localizations.dart';
import 'package:go_router/go_router.dart';

class ChildSettingsSections extends StatelessWidget {
  const ChildSettingsSections({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // App Settings
        Card(
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.brightness_6_outlined,
                title: l10n.theme,
                subtitle: 'System default',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.language_outlined,
                title: l10n.language,
                subtitle: 'English',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: l10n.notifications,
                subtitle: l10n.manageNotifications,
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.data_usage_outlined,
                title: l10n.dataUsage,
                subtitle: l10n.manageDataUsage,
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Account & Privacy
        Card(
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.person_outline,
                title: l10n.profile,
                subtitle: l10n.viewProfile,
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.security_outlined,
                title: l10n.permissions,
                subtitle: l10n.managePermissions,
                onTap: () => context.go('/permissions'),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: l10n.privacy,
                subtitle: l10n.managePrivacy,
                onTap: () => context.go('/privacy'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Help & Info
        Card(
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.help_outline,
                title: l10n.helpSupport,
                subtitle: l10n.getHelp,
                onTap: () => context.go('/help'),
              ),
              _SettingsTile(
                icon: Icons.info_outlined,
                title: l10n.about,
                subtitle: 'Version 1.0.0',
                onTap: () => _showAboutDialog(context, l10n),
              ),
              _SettingsTile(
                icon: Icons.article_outlined,
                title: l10n.termsOfService,
                subtitle: l10n.viewTerms,
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: l10n.privacyPolicy,
                subtitle: l10n.viewPolicy,
                onTap: () => context.go('/privacy'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Danger Zone
        Card(
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.delete_forever_outlined,
                title: l10n.deleteAccount,
                subtitle: l10n.permanentlyDeleteAccount,
                titleColor: AppTheme.errorColor,
                iconColor: AppTheme.errorColor,
                onTap: () => _confirmDeleteAccount(context, l10n),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    showAboutDialog(
      context: context,
      applicationName: 'Druvatara Guardian Child',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.shield, color: Colors.white, size: 32),
      ),
      children: [
        Text('Druvatara Guardian Child Companion'),
        const SizedBox(height: 16),
        Text('© 2026 Druvatara. All rights reserved.'),
      ],
    );
  }

  void _confirmDeleteAccount(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.confirmDeleteAccount),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () {
              Navigator.pop(context);
              // Handle account deletion
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor ?? AppTheme.primaryColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
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
    );
  }
}