import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class ConsentManagement extends StatelessWidget {
  const ConsentManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final consents = [
      {
        'id': 'analytics',
        'title': 'Analytics & Usage Statistics',
        'description': 'Help us improve by sharing anonymous usage data',
        'required': false,
        'granted': true,
      },
      {
        'id': 'crash_reporting',
        'title': 'Crash Reporting',
        'description': 'Automatically send crash reports for debugging',
        'required': false,
        'granted': true,
      },
      {
        'id': 'marketing',
        'title': 'Marketing Communications',
        'description': 'Receive product updates and tips via email',
        'required': false,
        'granted': false,
      },
      {
        'id': 'third_party_ai',
        'title': 'Third-Party AI Processing',
        'description': 'Allow TARA to use external AI providers for enhanced responses',
        'required': false,
        'granted': true,
      },
      {
        'id': 'location_history',
        'title': 'Location History Storage',
        'description': 'Store location history for 30 days for safety reports',
        'required': false,
        'granted': true,
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consent Management',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Control what data you share with us',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            ...consents.map((consent) => _ConsentTile(consent: consent)),
          ],
        ),
      ),
    );
  }
}

class _ConsentTile extends StatelessWidget {
  final Map<String, dynamic> consent;

  const _ConsentTile({required this.consent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final required = consent['required'] as bool;
    final granted = consent['granted'] as bool;
    final title = consent['title'] as String;
    final description = consent['description'] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Switch(
            value: granted,
            onChanged: required ? null : (v) {},
            activeColor: AppTheme.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (required) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Required',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.errorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
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
        ],
      ),
    );
  }
}