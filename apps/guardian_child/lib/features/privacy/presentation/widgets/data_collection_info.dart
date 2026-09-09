import 'package:flutter/material.dart'
import 'package:guardian_child/core/theme/app_theme.dart'
import 'package:guardian_child/core/localization/app_localizations.dart'

class DataCollectionInfo extends StatelessWidget {
  const DataCollectionInfo({super.key})

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)
    final theme = Theme.of(context)

    final dataTypes = [
      {
        'name': 'App Usage',
        'icon': Icons.apps,
        'collected': true,
        'description': 'Which apps you use and for how long',
        'purpose': 'Screen time limits and reports',
      },
      {
        'name': 'Location',
        'icon': Icons.location_on,
        'collected': true,
        'description': 'Your current location and safe zone status',
        'purpose': 'Safe zones and location safety',
      },
      {
        'name': 'Safety Events',
        'icon': Icons.warning_amber,
        'collected': true,
        'description': 'Screen time limits, blocked content, zone alerts',
        'purpose': 'Alerts and safety reports',
      },
      {
        'name': 'Device Info',
        'icon': Icons.phone_android,
        'collected': true,
        'description': 'Device model, OS version, app version, battery',
        'purpose': 'Compatibility and health monitoring',
      },
      {
        'name': 'Messages/Calls',
        'icon': Icons.message,
        'collected': false,
        'description': 'Your private messages and call logs',
        'purpose': 'Never collected',
      },
      {
        'name': 'Photos/Media',
        'icon': Icons.photo_library,
        'collected': false,
        'description': 'Your personal photos and media files',
        'purpose': 'Never collected',
      },
      {
        'name': 'Browsing History',
        'icon': Icons.history,
        'collected': false,
        'description': 'Full URLs and page content you visit',
        'purpose': 'Only category-level filtering',
      },
      {
        'name': 'Passwords',
        'icon': Icons.lock,
        'collected': false,
        'description': 'Your passwords and login credentials',
        'purpose': 'Never collected',
      },
    ]

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What We Collect vs. Don\'t Collect',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Transparent about your data',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            ...dataTypes.map((data) => _DataTypeTile(data: data)),
          ],
        ),
      ),
    )
  }
}

class _DataTypeTile extends StatelessWidget {
  final Map<String, dynamic> data

  const _DataTypeTile({required this.data})

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context)
    final collected = data['collected'] as bool
    final name = data['name'] as String
    final description = data['description'] as String
    final purpose = data['purpose'] as String
    final icon = data['icon'] as IconData

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: collected ? AppTheme.successColor.withOpacity(0.1) : AppTheme.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: collected ? AppTheme.successColor : AppTheme.errorColor,
              size = 22,
            ),
          ),
          const SizedBox(width = 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: collected ? AppTheme.successColor.withOpacity(0.1) : AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        collected ? 'Collected' : 'Not Collected',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: collected ? AppTheme.successColor : AppTheme.errorColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height = 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height = 2),
                Text(
                  'Purpose: $purpose',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
  }
}