import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final sections = [
      {
        'title': 'Data We Collect',
        'content': 'We collect minimal data necessary for child safety features including device info, app usage, location (with consent), and safety events. We do not collect message content, call logs, or browsing history.',
      },
      {
        'title': 'How We Use Your Data',
        'content': 'Data is used solely for safety features: screen time enforcement, web filtering, location safety, alerts, and TARA AI guidance. Data is never sold or used for advertising.',
      },
      {
        'title': 'Data Sharing',
        'content': 'We do not share child data with third parties. Parent data may be shared with co-parents per your settings. Data may be disclosed if required by law.',
      },
      {
        'title': 'Your Rights',
        'content': 'You can access, export, or delete your data at any time. You can withdraw consent for optional features. Children\'s data receives extra protection under COPPA/GDPR.',
      },
      {
        'title': 'Data Retention',
        'content': 'We retain data only as long as necessary for safety features. Usage data: 13 months. Location history: 30 days (configurable). Safety events: 13 months. Account data: until deletion.',
      },
      {
        'title': 'Children\'s Privacy',
        'content': 'COPPA and GDPR compliant. No data collected from children under 13 without verified parental consent. No profiling or behavioral advertising. Age-appropriate design.',
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Privacy Policy',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('Read Full Policy'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            ...sections.map((section) => _PolicySection(section: section)),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final Map<String, String> section;

  const _PolicySection({required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section['title']!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            section['content']!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
              height: 1.6,
            ),
          ),
          if (section != sections.last) const Divider(),
        ],
      ),
    );
  }
}