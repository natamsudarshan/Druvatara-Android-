import 'package:flutter/material.dart'
import 'package:guardian_child/core/theme/app_theme.dart'
import 'package:guardian_child/core/localization/app_localizations.dart'

class ChildPrivacyPolicy extends StatelessWidget {
  const ChildPrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)
    final theme = Theme.of(context)

    final sections = [
      {
        'title': 'What We Collect',
        'content': 'We only collect what\'s needed to keep you safe: which apps you use and for how long, your location for safe zones, and safety events. We don\'t read your messages, see your photos, or track what websites you visit in detail.',
      },
      {
        'title': 'How We Use Your Data',
        'content': 'Your data is used ONLY for safety features: screen time limits, safe zone alerts, web filtering, and showing your parents how you\'re doing. It\'s never sold or used for ads.',
      },
      {
        'title': 'Who Sees Your Data',
        'content': 'Only your parents/guardians can see your safety information. We don\'t share it with anyone else unless required by law.',
      },
      {
        'title': 'Your Rights',
        'content': 'You can ask your parents to export or delete your data. You can turn off optional features like location history. Your data is deleted when your account is removed.',
      },
      {
        'title': 'Data Retention',
        'content': 'Usage data: 13 months. Location history: 30 days. Safety events: 13 months. Account info: until deleted.',
      },
      {
        'title': 'Your Safety',
        'content': 'This app is designed to protect you, not spy on you. Emergency features always work. You can always contact trusted adults through the app.',
      },
    ]

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
    )
  }
}

class _PolicySection extends StatelessWidget {
  final Map<String, String> section

  const _PolicySection({required this.section})

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context)

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
    )
  }
}