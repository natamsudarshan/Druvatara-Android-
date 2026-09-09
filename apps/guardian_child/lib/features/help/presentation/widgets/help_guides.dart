import 'package:flutter/material.dart';
import 'package:guardian_child/core/theme/app_theme.dart';
import 'package:guardian_child/core/localization/app_localizations.dart';

class HelpGuides extends StatelessWidget {
  const HelpGuides({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final guides = [
      {
        'id': 'getting_started',
        'title': 'Getting Started',
        'icon': Icons.play_circle_outline,
        'color': AppTheme.primaryColor,
        'steps': [
          'Install Guardian Child from Play Store',
          'Open app and tap "Scan QR Code"',
          'Scan the code on parent\'s Guardian app',
          'Grant all requested permissions',
          'Complete the setup wizard',
        ],
      },
      {
        'id': 'screen_time',
        'title': 'Understanding Screen Time',
        'icon': Icons.schedule_outlined,
        'color': AppTheme.secondaryColor,
        'steps': [
          'Daily limit set by your parent',
          'Warnings at 15 min, 5 min, 1 min remaining',
          'Non-essential apps blocked at limit',
          'Request more time if needed',
          'Essential apps (phone, messages) always work',
        ],
      },
      {
        'id': 'safe_zones',
        'title': 'Safe Zones & Location',
        'icon': Icons.location_on_outlined,
        'color': AppTheme.successColor,
        'steps': [
          'Parents set up safe zones (home, school)',
          'Get alerts when entering/leaving zones',
          'Location shared only with parents',
          'Background location for zone alerts',
          'Turn off in settings if needed',
        ],
      },
      {
        'id': 'web_safety',
        'title': 'Web Safety & VPN',
        'icon': Icons.web_outlined,
        'color': AppTheme.warningColor,
        'steps': [
          'VPN filters unsafe websites',
          'Categories blocked by parent settings',
          'Safe Search enforced on search engines',
          'Threats blocked automatically',
          'View blocked attempts in app',
        ],
      },
      {
        'id': 'requests',
        'title': 'Requesting Access',
        'icon': Icons.request_page_outlined,
        'color': AppTheme.accentColor,
        'steps': [
          'Tap "+" on Requests screen',
          'Choose type: Time, App, Website, Schedule',
          'Add details for your parent',
          'Parent approves/rejects/modifies',
          'Approved requests apply automatically',
        ],
      },
      {
        'id': 'permissions',
        'title': 'Permission Health',
        'icon': Icons.security_outlined,
        'color': AppTheme.errorColor,
        'steps': [
          'Notifications - for alerts',
          'Usage Access - for screen time',
          'Location - for safe zones',
          'Background Location - for zones',
          'VPN - for web filtering',
          'Battery Optimization - for reliability',
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
              'Guides & Tutorials',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
          child: Icon(icon, color: color, size = 20),
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