import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class AccountSecurity extends StatelessWidget {
  const AccountSecurity({super.key});

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
              l10n.security,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _SecurityTile(
              icon: Icons.lock_outline,
              title: l10n.changePassword,
              subtitle: l10n.lastChangedNever,
              onTap: () {},
            ),
            _SecurityTile(
              icon: Icons.verified_user_outlined,
              title: l10n.twoFactorAuth,
              subtitle: l10n.disabled,
              trailing: Switch(
                value: false,
                onChanged: (v) {},
                activeColor: AppTheme.primaryColor,
              ),
            ),
            _SecurityTile(
              icon: Icons.fingerprint,
              title: l10n.biometricLogin,
              subtitle: l10n.enabled,
              trailing: Switch(
                value: true,
                onChanged: (v) {},
                activeColor: AppTheme.primaryColor,
              ),
            ),
            _SecurityTile(
              icon: Icons.devices_outlined,
              title: l10n.activeSessions,
              subtitle: '2 active sessions',
              onTap: () {},
            ),
            _SecurityTile(
              icon: Icons.history_outlined,
              title: l10n.loginHistory,
              subtitle: l10n.viewRecentLogins,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SecurityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
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
              if (trailing != null) trailing!,
              if (onTap != null && trailing == null)
                Icon(Icons.chevron_right, color: AppTheme.textSecondaryColor),
            ],
          ),
        ),
      ),
    );
  }
}