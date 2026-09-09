import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';
import 'package:go_router/go_router.dart';

class ChildQuickActions extends StatelessWidget {
  final String childId;

  const ChildQuickActions({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final actions = [
      QuickActionItem(
        icon: Icons.schedule,
        label: l10n.screenTime,
        color: AppTheme.primaryColor,
        onTap: () => context.go('/screen-time?childId=$childId'),
      ),
      QuickActionItem(
        icon: Icons.apps,
        label: l10n.applications,
        color: AppTheme.secondaryColor,
        onTap: () => context.go('/applications?childId=$childId'),
      ),
      QuickActionItem(
        icon: Icons.bedtime,
        label: l10n.schedules,
        color: AppTheme.successColor,
        onTap: () => context.go('/schedules?childId=$childId'),
      ),
      QuickActionItem(
        icon: Icons.web,
        label: l10n.webSafety,
        color: AppTheme.warningColor,
        onTap: () => context.go('/web-safety?childId=$childId'),
      ),
      QuickActionItem(
        icon: Icons.location_on,
        label: l10n.location,
        color: AppTheme.errorColor,
        onTap: () => context.go('/location?childId=$childId'),
      ),
      QuickActionItem(
        icon: Icons.psychology,
        label: l10n.tara,
        color: AppTheme.accentColor,
        onTap: () => context.go('/tara?childId=$childId'),
      ),
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return Padding(
            padding: EdgeInsets.only(right: index == actions.length - 1 ? 16 : 8),
            child: _QuickActionCard(action: action),
          ),
        },
      ),
    );
  }
}

class QuickActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final QuickActionItem action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 90,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(action.icon, color: action.color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}