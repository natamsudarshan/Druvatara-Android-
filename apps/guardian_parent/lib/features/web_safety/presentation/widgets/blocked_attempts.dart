import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class BlockedAttempts extends StatelessWidget {
  const BlockedAttempts({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock data
    final attempts = [
      {
        'url': 'malicious-site.com',
        'category': 'MALWARE',
        'time': '2 min ago',
        'child': 'Alex',
        'blocked': true,
      },
      {
        'url': 'gambling-site.net',
        'category': 'GAMBLING',
        'time': '15 min ago',
        'child': 'Sam',
        'blocked': true,
      },
      {
        'url': 'adult-content.org',
        'category': 'ADULT',
        'time': '1 hour ago',
        'child': 'Alex',
        'blocked': true,
      },
      {
        'url': 'phishing-link.com',
        'category': 'PHISHING',
        'time': '3 hours ago',
        'child': 'Sam',
        'blocked': true,
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
                  l10n.blockedAttempts,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(l10n.viewAll),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...attempts.map((attempt) => _AttemptTile(attempt: attempt)),
          ],
        ),
      ),
    );
  }
}

class _AttemptTile extends StatelessWidget {
  final Map<String, dynamic> attempt;

  const _AttemptTile({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = attempt['category'] as String;
    final blocked = attempt['blocked'] as bool;

    Color categoryColor;
    IconData categoryIcon;

    switch (category) {
      case 'MALWARE':
        categoryColor = AppTheme.errorColor;
        categoryIcon = Icons.bug_report;
        break;
      case 'PHISHING':
        categoryColor = AppTheme.errorColor;
        categoryIcon = Icons.phishing;
        break;
      case 'ADULT':
        categoryColor = AppTheme.errorColor;
        categoryIcon = Icons.adult;
        break;
      case 'GAMBLING':
        categoryColor = AppTheme.warningColor;
        categoryIcon = Icons.casino;
        break;
      default:
        categoryColor = AppTheme.textSecondaryColor;
        categoryIcon = Icons.web;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(categoryIcon, color: categoryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attempt['url'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: categoryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      attempt['time'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Blocked',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}