import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class TroubleshootingGuides extends StatelessWidget {
  const TroubleshootingGuides({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final guides = [
      {
        'id': 'device_offline',
        'title': 'Device Shows Offline',
        'icon': Icons.wifi_off,
        'color': AppTheme.errorColor,
        'steps': [
          'Check internet connection on child device',
          'Restart Guardian app on child device',
          'Check battery optimization settings',
          'Re-pair device if needed',
        ],
      },
      {
        'id': 'vpn_not_working',
        'title': 'Web Filtering Not Working',
        'icon': Icons.vpn_key,
        'color': AppTheme.warningColor,
        'steps': [
          'Verify VPN permission granted in Settings',
          'Check for conflicting VPN apps',
          'Restart VPN from app settings',
          'Reinstall app if persistent',
        ],
      },
      {
        'id': 'location_not_updating',
        'title': 'Location Not Updating',
        'icon': Icons.location_off,
        'color': AppTheme.warningColor,
        'steps': [
          'Check location permission granted',
          'Verify background location enabled',
          'Check GPS signal (move outdoors)',
          'Restart location services on device',
        ],
      },
      {
        'id': 'screen_time_not_enforcing',
        'title': 'Screen Time Not Enforcing',
        'icon': Icons.schedule,
        'color': AppTheme.primaryColor,
        'steps': [
          'Check Usage Access permission',
          'Verify screen time limits are set',
          'Check for app exceptions',
          'Restart child device',
        ],
      },
      {
        'id': 'notifications_not_working',
        'title': 'Not Receiving Alerts',
        'icon': Icons.notifications_off,
        'color': AppTheme.secondaryColor,
        'steps': [
          'Check notification permission granted',
          'Verify app not in battery saver',
          'Check Do Not Disturb settings',
          'Reinstall app if needed',
        ],
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Troubleshooting Guides',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ...guides.map((guide) => _GuideTile(guide: guide)),
          ],
        ),
      ),
    );
  }
}

class _GuideTile extends StatelessWidget {
  final Map<String, dynamic> guide;

  const _GuideTile({required this.guide});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = guide['color'] as Color;
    final title = guide['title'] as String;
    final icon = guide['icon'] as IconData;
    final steps = guide['steps'] as List<String>;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          step,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }
}