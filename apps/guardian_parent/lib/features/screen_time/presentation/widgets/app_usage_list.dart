import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class AppUsageList extends StatelessWidget {
  const AppUsageList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock data
    final apps = [
      {'name': 'YouTube', 'package': 'com.google.android.youtube', 'time': '1h 20m', 'icon': Icons.play_circle, 'category': 'Entertainment'},
      {'name': 'Instagram', 'package': 'com.instagram.android', 'time': '45m', 'icon': Icons.camera_alt, 'category': 'Social'},
      {'name': 'Roblox', 'package': 'com.roblox.client', 'time': '30m', 'icon': Icons.games, 'category': 'Games'},
      {'name': 'WhatsApp', 'package': 'com.whatsapp', 'time': '25m', 'icon': Icons.chat, 'category': 'Communication'},
      {'name': 'Chrome', 'package': 'com.android.chrome', 'time': '20m', 'icon': Icons.web, 'category': 'Browser'},
      {'name': 'TikTok', 'package': 'com.zhiliaoapp.musically', 'time': '15m', 'icon': Icons.music_video, 'category': 'Social'},
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
                  l10n.topApps,
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
            ...apps.asMap().entries.map((entry) {
              final index = entry.key;
              final app = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Icon(
                        app['icon'] as IconData,
                        color: AppTheme.primaryColor,
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
                          const SizedBox(height: 2),
                          Text(
                            '${app['category']} • ${app['time']}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '#${index + 1}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                );
            }),
          ],
        ),
      ),
    );
  }
}