import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class GeofenceList extends StatelessWidget {
  const GeofenceList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock data
    final geofences = [
      {
        'id': 'geo_1',
        'name': 'Home',
        'lat': 12.9716,
        'lng': 77.5946,
        'radius': 200,
        'alertOnEnter': true,
        'alertOnExit': true,
        'active': true,
      },
      {
        'id': 'geo_2',
        'name': 'School',
        'lat': 12.9786,
        'lng': 77.5986,
        'radius': 500,
        'alertOnEnter': true,
        'alertOnExit': true,
        'active': true,
      },
      {
        'id': 'geo_3',
        'name': 'Grandma\'s House',
        'lat': 12.9856,
        'lng': 77.6026,
        'radius': 100,
        'alertOnEnter': false,
        'alertOnExit': true,
        'active': false,
      },
    ];

    if (geofences.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.location_on_outlined, size: 48, color: AppTheme.textSecondaryColor),
              const SizedBox(height: 16),
              Text(
                'No safe zones yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add safe zones to get alerts when your child enters or leaves',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.safeZones,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${geofences.where((g) => g['active'] == true).length}/${geofences.length} ${l10n.active}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...geofences.map((geofence) => _GeofenceTile(geofence: geofence)),
        ],
      ),
    );
  }
}

class _GeofenceTile extends StatelessWidget {
  final Map<String, dynamic> geofence;

  const _GeofenceTile({required this.geofence});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = geofence['active'] as bool;
    final name = geofence['name'] as String;
    final radius = geofence['radius'] as int;
    final alertOnEnter = geofence['alertOnEnter'] as bool;
    final alertOnExit = geofence['alertOnExit'] as bool;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: active ? AppTheme.successColor.withOpacity(0.1) : AppTheme.textSecondaryColor.withOpacity(0.1),
        child: Icon(
          Icons.location_on,
          color: active ? AppTheme.successColor : AppTheme.textSecondaryColor,
        ),
      ),
      title: Text(
        name,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: active ? null : AppTheme.textSecondaryColor,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: active ? AppTheme.successColor.withOpacity(0.1) : AppTheme.textSecondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  active ? l10n.active : l10n.inactive,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: active ? AppTheme.successColor : AppTheme.textSecondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(geofence['radius'] as int) / 1000} km radius',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (geofence['alertOnEnter'] == true)
                _AlertBadge(icon: Icons.login, label: l10n.enterAlert, color: AppTheme.successColor),
              if (geofence['alertOnExit'] == true)
                _AlertBadge(icon: Icons.logout, label: l10n.exitAlert, color: AppTheme.warningColor),
            ],
          ),
        ],
      ),
      trailing: Switch(
        value: active,
        onChanged: (v) {},
        activeColor: AppTheme.primaryColor,
      ),
      onTap: () {},
    );
  }
}

class _AlertBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _AlertBadge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}