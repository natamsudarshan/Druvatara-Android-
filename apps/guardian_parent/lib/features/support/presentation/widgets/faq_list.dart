import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class FAQList extends StatelessWidget {
  const FAQList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final faqs = [
      {
        'question': 'How do I pair a child device?',
        'answer': 'Open the parent app, go to Devices > Add Device, scan the QR code on the child device.',
        'category': 'Setup',
      },
      {
        'question': 'Why is VPN not connecting?',
        'answer': 'Check if VPN permission is granted in Settings > Network > VPN. Some devices require battery optimization to be disabled.',
        'category': 'Troubleshooting',
      },
      {
        'question': 'How do I change screen time limits?',
        'answer': 'Go to Screen Time in the parent app, select the child, and adjust the daily limit.',
        'category': 'Features',
      },
      {
        'question': 'What happens when screen time limit is reached?',
        'answer': 'Non-essential apps are blocked. The child can request more time which you can approve or deny.',
        'category': 'Features',
      },
      {
        'question': 'How do I set up safe zones?',
        'answer': 'Go to Location > Safe Zones, tap Add Zone, set the location and radius.',
        'category': 'Features',
      },
      {
        'question': 'Can I monitor multiple children?',
        'answer': 'Yes, depending on your subscription plan. Free: 1 child, Basic: 2, Premium: 4, Family: 6.',
        'category': 'Subscription',
      },
      {
        'question': 'Is my child\'s data private?',
        'answer': 'Yes, we follow strict privacy standards. No data is sold or used for advertising. See Privacy Policy for details.',
        'category': 'Privacy',
      },
      {
        'question': 'How accurate is location tracking?',
        'answer': 'Location uses GPS, Wi-Fi, and cell towers. Accuracy is typically 10-50m outdoors, less indoors.',
        'category': 'Location',
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ...faqs.map((faq) => _FAQTile(faq: faq)),
          ],
        ),
      ),
    );
  }
}

class _FAQTile extends StatelessWidget {
  final Map<String, String> faq;

  const _FAQTile({required this.faq});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          faq['question']!,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Text(
            faq['category']![0],
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq['answer']!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}