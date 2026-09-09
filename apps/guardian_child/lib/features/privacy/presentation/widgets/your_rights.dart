import 'package:flutter/material.dart'
import 'package:guardian_child/core/theme/app_theme.dart'
import 'package:guardian_child/core/localization/app_localizations.dart'

class YourRights extends StatelessWidget {
  const YourRights({super.key})

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)
    final theme = Theme.of(context)

    final rights = [
      {
        'title': 'Right to Access',
        'description': 'Ask your parents to show you all data collected about you',
        'icon': Icons.visibility,
        'action': 'Ask Parent',
      },
      {
        'title': 'Right to Export',
        'description': 'Get a copy of all your data in a readable format',
        'icon': Icons.download,
        'action': 'Request Export',
      },
      {
        'title': 'Right to Delete',
        'description': 'Ask to have your data permanently deleted',
        'icon': Icons.delete_outline,
        'action': 'Request Deletion',
      },
      {
        'title': 'Right to Restrict',
        'description': 'Turn off optional features like location history',
        'icon': Icons.toggle_off,
        'action': 'Manage in Settings',
      },
      {
        'title': 'Right to Object',
        'description': 'Stop processing for features you don\'t want',
        'icon': Icons.block,
        'action': 'Disable Feature',
      },
      {
        'title': 'Right to Complain',
        'description': 'Contact privacy regulators if concerned',
        'icon': Icons.gavel,
        'action': 'Learn More',
      },
    ]

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Privacy Rights',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Under GDPR, COPPA, and other privacy laws',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            ...rights.map((right) => _RightTile(right: right)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'For Parents',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'As a parent, you can exercise these rights on behalf of your child. Use the parent app to export, delete, or manage your child\'s data.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {},
              child: Text('Open Parent App'),
            ),
          ],
        ),
      ),
    )
  }
}

class _RightTile extends StatelessWidget {
  final Map<String, dynamic> right

  const _RightTile({required this.right})

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context)
    final title = right['title'] as String
    final description = right['description'] as String
    final icon = right['icon'] as IconData
    final action = right['action'] as String

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 22,
            ),
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
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(action),
          ),
        ],
      ),
    )
  }
}