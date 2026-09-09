import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class BlockedCategories extends StatelessWidget {
  const BlockedCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock data
    final categories = [
      {'id': 'ADULT', 'name': 'Adult Content', 'blocked': true, 'defaultFor': ['TODDLER', 'YOUNG_CHILD', 'PRE_TEEN']},
      {'id': 'GAMBLING', 'name': 'Gambling', 'blocked': true, 'defaultFor': ['TODDLER', 'YOUNG_CHILD', 'PRE_TEEN', 'TEENAGER']},
      {'id': 'VIOLENCE', 'name': 'Violence', 'blocked': true, 'defaultFor': ['TODDLER', 'YOUNG_CHILD']},
      {'id': 'DRUGS', 'name': 'Drugs', 'blocked': true, 'defaultFor': ['TODDLER', 'YOUNG_CHILD', 'PRE_TEEN']},
      {'id': 'WEAPONS', 'name': 'Weapons', 'blocked': true, 'defaultFor': ['TODDLER', 'YOUNG_CHILD']},
      {'id': 'HATE', 'name': 'Hate/Extremism', 'blocked': true, 'defaultFor': ['TODDLER', 'YOUNG_CHILD', 'PRE_TEEN']},
      {'id': 'SELF_HARM', 'name': 'Self-Harm', 'blocked': true, 'defaultFor': ['TODDLER', 'YOUNG_CHILD', 'PRE_TEEN', 'TEENAGER']},
      {'id': 'MALWARE', 'name': 'Malware', 'blocked': true, 'defaultFor': ['TODDLER', 'YOUNG_CHILD', 'PRE_TEEN', 'TEENAGER']},
      {'id': 'PHISHING', 'name': 'Phishing', 'blocked': true, 'defaultFor': ['TODDLER', 'YOUNG_CHILD', 'PRE_TEEN', 'TEENAGER']},
      {'id': 'FRAUD', 'name': 'Fraud', 'blocked': true, 'defaultFor': ['TODDLER', 'YOUNG_CHILD', 'PRE_TEEN', 'TEENAGER']},
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
                  l10n.blockedCategories,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${categories.where((c) => c['blocked'] == true).length}/${categories.length}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...categories.map((cat) => _CategoryTile(category: cat)),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final Map<String, dynamic> category;

  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blocked = category['blocked'] as bool;
    final name = category['name'] as String;
    final defaultFor = category['defaultFor'] as List<String>;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Switch(
            value: blocked,
            onChanged: (v) {},
            activeColor: AppTheme.errorColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (defaultFor.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Default for: ${defaultFor.join(', ')}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}