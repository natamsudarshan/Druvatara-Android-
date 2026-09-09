import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';
import 'package:guardian_parent/features/dashboard/presentation/widgets/protection_status_card.dart';
import 'package:guardian_parent/features/dashboard/presentation/widgets/quick_actions.dart';
import 'package:guardian_parent/features/dashboard/presentation/widgets/recent_alerts.dart';
import 'package:guardian_parent/features/dashboard/presentation/widgets/screen_time_summary.dart';
import 'package:guardian_parent/features/dashboard/presentation/widgets/safety_score_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go('/alerts'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh dashboard data
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ProtectionStatusCard(),
                    const SizedBox(height: 16),
                    const SafetyScoreCard(),
                    const SizedBox(height: 16),
                    const ScreenTimeSummary(),
                    const SizedBox(height: 16),
                    const QuickActions(),
                    const SizedBox(height: 16),
                    const RecentAlerts(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}