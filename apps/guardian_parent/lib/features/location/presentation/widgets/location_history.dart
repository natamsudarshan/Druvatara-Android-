import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class LocationHistory extends StatelessWidget {
  const LocationHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock data
    final locations = [
      {'name': 'Home', 'time': '2 min ago', 'lat': 12.9716, 'lng': 77.5946, 'accuracy': 10},
      {'name': 'School', 'time': '3 hours ago', 'lat': 12.9786, 'lng': 77.5986, 'accuracy': 15},
      {'name': 'Park', 'time': 'Yesterday', 'lat': 12.9826, 'lng': 77.6016, 'accuracy': 20},
      {'name': 'Mall', 'time': '2 days ago', 'lat': 12.9756, 'lng': 77.5966, 'accuracy': 25},
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
                  l10n.locationHistory,
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
            ...locations.map((loc) => _LocationHistoryTile(loc: loc)),
          ],
        ),
      ),
    );
  }
}

class _LocationHistoryTile extends StatelessWidget {
  final Map<String, dynamic> loc;

  const _LocationHistoryTile({required this.loc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = loc['name'] as String;
    final time = loc['time'] as String;
    final accuracy = loc['accuracy'] as int;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.location_on, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
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
                        '±${loc['accuracy']}m',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  time,
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