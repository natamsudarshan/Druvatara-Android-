import 'package:flutter/material.dart';
import 'package:guardian_child/core/theme/app_theme.dart';
import 'package:guardian_child/core/localization/app_localizations.dart';

class HelpFaq extends StatelessWidget {
  const HelpFaq({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final faqs = [
      {
        'question': 'How do I pair with my parent\'s device?',
        'answer': 'Open the Guardian Child app, tap "Scan QR Code" or "Enter Code", then scan the QR code on your parent\'s Guardian app or enter the 7-digit code.',
        'category': 'Setup',
      },
      {
        'question': 'Why is VPN not connecting?',
        'answer': 'Check if VPN permission is granted in Settings > Network > VPN. Some devices require battery optimization to be disabled for the Guardian app.',
        'category': 'Troubleshooting',
      },
      {
        'question': 'How much screen time do I have left?',
        'answer': 'Check the home screen of the Guardian Child app. It shows your remaining time and daily limit.',
        'category': 'Screen Time',
      },
      {
        'question': 'What happens when my time runs out?',
        'answer': 'Non-essential apps will be blocked. You can tap "Request More Time" to ask your parent for extra time.',
        'category': 'Screen Time',
      },
      {
        'question': 'How do I request more time or app access?',
        'answer': 'Tap the "+" button on the Requests screen, choose the type of request, and send it to your parent.',
        'category': 'Requests',
      },
      {
        'question': 'Is my location always tracked?',
        'answer': 'Your location is only shared with your parents for safety features like safe zones. You can see when location is active in the app.',
        'category': 'Privacy',
      },
      {
        'question': 'Can my parents see my messages?',
        'answer': 'No. Guardian does not read your private messages, emails, or social media content. We only track app usage time and categories.',
        'category': 'Privacy',
      },
      {
        'question': 'What are safe zones?',
        'answer': 'Safe zones are places your parents set up (like home or school). You\'ll get alerts when you enter or leave these areas.',
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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