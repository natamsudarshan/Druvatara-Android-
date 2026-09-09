import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';
import 'package:guardian_parent/features/child/presentation/widgets/child_summary_header.dart';
import 'package:guardian_parent/features/child/presentation/widgets/child_usage_chart.dart';
import 'package:guardian_parent/features/child/presentation/widgets/child_devices_list.dart';
import 'package:guardian_parent/features/child/presentation/widgets/child_quick_actions.dart';

class ChildDetailScreen extends ConsumerWidget {
  final String childId;

  const ChildDetailScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // Mock data
    final child = {
      'id': childId,
      'name': 'Alex',
      'ageGroup': 'PRE_TEEN',
      'avatar': 'avatar_04',
      'devices': 1,
      'alerts': 2,
      'screenTimeToday': '2h 34m',
      'safetyScore': 87,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(child['name'] as String),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.go('/children/$childId/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptions(context, l10n),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ChildSummaryHeader(child: child),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ChildQuickActions(childId: childId),
            ),
          ),
          SliverToBoxAdapter(
            child: const ChildUsageChart(),
          ),
          SliverToBoxAdapter(
            child: ChildDevicesList(childId: childId),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(l10n.editProfile),
            onTap: () {
              Navigator.pop(context);
              context.go('/children/$childId/edit');
            },
          ),
          ListTile(
            leading: const Icon(Icons.pairing_outlined),
            title: Text(l10n.pairDevice),
            onTap: () {
              Navigator.pop(context);
              context.go('/pairing/$childId');
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
            title: Text(l10n.removeChild, style: TextStyle(color: AppTheme.errorColor)),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(context, l10n);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeChild),
        content: Text(l10n.confirmRemoveChild),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to child list
            },
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
  }
}