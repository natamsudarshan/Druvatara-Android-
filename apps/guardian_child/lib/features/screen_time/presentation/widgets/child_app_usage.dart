import 'package:flutter/material.dart';
import 'package:guardian_child/core/theme/app_theme.dart';
import 'package:guardian_child/core/localization/app_localizations.dart';

class ChildAppUsage extends StatelessWidget {
  const ChildAppUsage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock data
    final apps = [
      {'name': 'YouTube', 'icon': Icons.play_circle, 'time': '1h 20m', 'color': AppTheme.errorColor, 'limited': true},
      {'name': 'Instagram', 'icon': Icons.camera_alt, 'time': '45m', 'color': AppTheme.secondaryColor, 'limited': true},
      {'name': 'Roblox', 'icon': Icons.games, 'time': '30m', 'color': AppTheme.successColor, 'limited': true},
      {'name': 'WhatsApp', 'icon': Icons.chat, 'time': '25m', 'color': AppTheme.accentColor, 'limited': false},
      {'name': 'Chrome', 'icon': Icons.web, 'time': '20m', 'color': AppTheme.primaryColor, 'limited': false},
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
                  l10n.appUsage,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...apps.map((app) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (app['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      app['icon'] as IconData,
                      color: app['color'] as Color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app['name'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (app['limited'] as bool)
                          Text(
                            l10n.timeLimited,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.warningColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    app['time'] as String,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}