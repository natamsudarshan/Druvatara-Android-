import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class CoParentList extends StatelessWidget {
  const CoParentList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock data
    final coParents = [
      {
        'id': 'coparent_1',
        'name': 'Sarah Johnson',
        'email': 'sarah@example.com',
        'avatar': 'avatar_01',
        'children': ['Alex'],
        'permissions': {
          'viewAlerts': true,
          'viewLocation': true,
          'approveRequests': true,
          'modifyPolicies': false,
          'viewReports': true,
          'manageDevices': false,
        },
        'status': 'ACTIVE',
      },
    ];

    if (coParents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.people_outline, size: 60, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.noCoParentsYet,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.inviteCoParentDescription,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add),
                label: Text(l10n.inviteCoParent),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: coParents.length,
      itemBuilder: (context, index) {
        final coParent = coParents[index];
        return _CoParentCard(coParent: coParent);
      },
    );
  }
}

class _CoParentCard extends StatelessWidget {
  final Map<String, dynamic> coParent;

  const _CoParentCard({required this.coParent});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final status = coParent['status'] as String;
    final permissions = coParent['permissions'] as Map<String, bool>;
    final children = coParent['children'] as List<String>;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'ACTIVE':
        statusColor = AppTheme.successColor;
        statusText = l10n.active;
        statusIcon = Icons.check_circle;
        break;
      case 'PENDING':
        statusColor = AppTheme.warningColor;
        statusText = l10n.pending;
        statusIcon = Icons.hourglass_empty;
        break;
      default:
        statusColor = AppTheme.textSecondaryColor;
        statusText = status;
        statusIcon = Icons.help_outline;
    }

    final activePermissions = permissions.entries.where((e) => e.value).length;
    final totalPermissions = permissions.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    coParent['name'][0].toUpperCase(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              coParent['name'],
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, size: 14, color: statusColor),
                                const SizedBox(width: 4),
                                Text(
                                  statusText,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coParent['email'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondaryColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoColumn(
                    context,
                    l10n.children,
                    children.join(', '),
                    Icons.child_care,
                  ),
                ),
                Expanded(
                  child: _buildInfoColumn(
                    context,
                    l10n.permissions,
                    '$activePermissions/$totalPermissions',
                    Icons.security,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: permissions.entries.map((entry) {
                final isGranted = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isGranted ? AppTheme.successColor.withOpacity(0.1) : AppTheme.dividerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isGranted ? Icons.check_circle : Icons.cancel,
                        size: 14,
                        color: isGranted ? AppTheme.successColor : AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatPermission(entry.key),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isGranted ? AppTheme.successColor : AppTheme.textSecondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.textSecondaryColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatPermission(String key) {
    switch (key) {
      case 'viewAlerts': return 'View Alerts';
      case 'viewLocation': return 'View Location';
      case 'approveRequests': return 'Approve Requests';
      case 'modifyPolicies': return 'Modify Policies';
      case 'viewReports': return 'View Reports';
      case 'manageDevices': return 'Manage Devices';
      default: return key;
    }
  }
}