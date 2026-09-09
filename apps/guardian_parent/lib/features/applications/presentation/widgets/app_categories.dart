import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class AppCategories extends StatelessWidget {
  const AppCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final categories = [
      {'id': 'SOCIAL', 'name': 'Social Media', 'icon': Icons.chat, 'color': AppTheme.primaryColor, 'count': 3},
      {'id': 'GAMES', 'name': 'Games', 'icon': Icons.games, 'color': AppTheme.warningColor, 'count': 2},
      {'id': 'ENTERTAINMENT', 'name': 'Entertainment', 'icon': Icons.movie, 'color': AppTheme.successColor, 'count': 2},
      {'id': 'EDUCATION', 'name': 'Education', 'icon': Icons.school, 'color': AppTheme.secondaryColor, 'count': 1},
      {'id': 'COMMUNICATION', 'name': 'Communication', 'icon': Icons.message, 'color': AppTheme.accentColor, 'count': 2},
      {'id': 'BROWSER', 'name': 'Browser', 'icon': Icons.web, 'color': AppTheme.errorColor, 'count': 1},
      {'id': 'SYSTEM', 'name': 'System', 'icon': Icons.settings, 'color': AppTheme.textSecondaryColor, 'count': 5},
      {'id': 'OTHER', 'name': 'Other', 'icon': Icons.apps, 'color': AppTheme.dividerColor, 'count': 3},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appCategories,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final color = cat['color'] as Color;
                return InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            cat['icon'] as IconData,
                            color: color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat['name'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${cat['count']} apps',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}