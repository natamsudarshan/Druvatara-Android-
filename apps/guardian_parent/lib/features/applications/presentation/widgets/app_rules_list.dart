import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class AppRulesList extends StatelessWidget {
  const AppRulesList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock data
    final rules = [
      {'package': 'com.instagram.android', 'name': 'Instagram', 'rule': 'LIMIT', 'limit': '1h', 'action': 'WARN'},
      {'package': 'com.roblox.client', 'name': 'Roblox', 'rule': 'LIMIT', 'limit': '2h', 'action': 'BLOCK'},
      {'package': 'com.google.android.youtube', 'name': 'YouTube', 'rule': 'LIMIT', 'limit': '1h 30m', 'action': 'WARN'},
      {'package': 'com.zhiliaoapp.musically', 'name': 'TikTok', 'rule': 'BLOCK', 'limit': '', 'action': 'BLOCK'},
    ];

    if (rules.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.apps_outlined, size: 48, color: AppTheme.textSecondaryColor),
              const SizedBox(height: 16),
              Text(
                l10n.noAppRulesYet,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.addAppRulesDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.appRules,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${rules.length} ${l10n.rules}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...rules.map((rule) => _AppRuleTile(rule: rule)),
        ],
      ),
    );
  }
}

class _AppRuleTile extends StatelessWidget {
  final Map<String, dynamic> rule;

  const _AppRuleTile({required this.rule});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ruleType = rule['rule'] as String;

    Color ruleColor;
    IconData ruleIcon;
    String ruleLabel;

    switch (ruleType) {
      case 'BLOCK':
        ruleColor = AppTheme.errorColor;
        ruleIcon = Icons.block;
        ruleLabel = 'Blocked';
        break;
      case 'LIMIT':
        ruleColor = AppTheme.warningColor;
        ruleIcon = Icons.timer;
        ruleLabel = 'Time Limited';
        break;
      case 'ALLOW':
        ruleColor = AppTheme.successColor;
        ruleIcon = Icons.check_circle;
        ruleLabel = 'Allowed';
        break;
      case 'ESSENTIAL':
        ruleColor = AppTheme.primaryColor;
        ruleIcon = Icons.star;
        ruleLabel = 'Essential';
        break;
      default:
        ruleColor = AppTheme.textSecondaryColor;
        ruleIcon = Icons.help_outline;
        ruleLabel = 'Unknown';
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        child: Icon(Icons.android, color: AppTheme.primaryColor),
      ),
      title: Text(
        rule['name'],
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(rule['package']),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ruleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(ruleIcon, size: 12, color: ruleColor),
                const SizedBox(width: 4),
                Text(
                  ruleLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ruleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (rule['limit'].isNotEmpty)
            Text(
              rule['limit'],
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
        ],
      ),
      onTap: () {},
    );
  }
}