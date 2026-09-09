import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class TaraSuggestions extends StatelessWidget {
  const TaraSuggestions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final suggestions = [
      {'icon': Icons.schedule, 'label': 'Screen time summary', 'color': AppTheme.primaryColor},
      {'icon': Icons.warning_amber, 'label': 'Recent alerts', 'color': AppTheme.warningColor},
      {'icon': Icons.shield, 'label': 'Safety score', 'color': AppTheme.successColor},
      {'icon': Icons.apps, 'label': 'App usage', 'color': AppTheme.secondaryColor},
      {'icon': Icons.location_on, 'label': 'Location status', 'color': AppTheme.errorColor},
      {'icon': Icons.web, 'label': 'Web safety', 'color': AppTheme.accentColor},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: AppTheme.dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested questions',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((s) => _SuggestionAction(
              icon: s['icon'] as IconData,
              label: s['label'] as String,
              color: s['color'] as Color,
              onTap: () {},
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _SuggestionAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SuggestionAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ActionChip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: theme.textTheme.bodySmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
      )),
      onPressed: onTap,
      backgroundColor: color.withOpacity(0.1),
      labelStyle: theme.textTheme.bodySmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }
}