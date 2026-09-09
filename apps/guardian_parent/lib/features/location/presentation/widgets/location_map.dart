import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class LocationMap extends StatelessWidget {
  const LocationMap({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock data
    const status = 'LIVE';
    const lastUpdate = '2 min ago';
    const children = [
      {'name': 'Alex', 'lat': 12.9716, 'lng': 77.5946, 'accuracy': 10, 'battery': 85},
      {'name': 'Sam', 'lat': 12.9786, 'lng': 77.5986, 'accuracy': 15, 'battery': 45},
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
                  l10n.liveLocation,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.successColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.live,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Map placeholder
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.dividerColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, size: 48, color: AppTheme.textSecondaryColor),
                        const SizedBox(height: 8),
                        Text(
                          'Map View',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Google Maps / Mapbox integration',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton.small(
                      onPressed: () {},
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: children.map((child) => _ChildLocationTile(child: child)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildLocationTile extends StatelessWidget {
  final Map<String, dynamic> child;

  const _ChildLocationTile({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = child['name'] as String;
    final accuracy = child['accuracy'] as int;
    final battery = child['battery'] as int;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.gps_fixed, size: 16, color: AppTheme.successColor),
                const SizedBox(width: 4),
                Text(
                  '±${child['accuracy']}m',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.battery_charging_full, size: 16, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 4),
                Text(
                  '${child['battery']}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}