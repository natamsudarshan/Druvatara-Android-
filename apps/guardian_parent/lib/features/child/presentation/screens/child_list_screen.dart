import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';
import 'package:guardian_parent/features/child/presentation/screens/child_detail_screen.dart';
import 'package:guardian_parent/features/child/presentation/widgets/child_card.dart';

class ChildListScreen extends ConsumerWidget {
  const ChildListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // Mock data
    final children = [
      {
        'id': 'child_1',
        'name': 'Alex',
        'ageGroup': 'PRE_TEEN',
        'avatar': 'avatar_04',
        'devices': 1,
        'alerts': 2,
        'screenTimeToday': '2h 34m',
      },
      {
        'id': 'child_2',
        'name': 'Sam',
        'ageGroup': 'YOUNG_CHILD',
        'avatar': 'avatar_02',
        'devices': 1,
        'alerts': 0,
        'screenTimeToday': '1h 15m',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.children),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/children/add'),
          ),
        ],
      ),
      body: children.isEmpty
          ? _buildEmptyState(context, l10n)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                return ChildCard(
                  child: child,
                  onTap: () => context.go('/children/${child['id']}'),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
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
              child: Icon(Icons.child_care_outlined, size: 60, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noChildrenYet,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.addFirstChild,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/children/add'),
              icon: const Icon(Icons.add),
              label: Text(l10n.addChild),
            ),
          ],
        ),
      ),
    );
  }
}