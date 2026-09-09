import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
import 'package:guardian_child/core/theme/app_theme.dart';
import 'package:guardian_child/core/localization/app_localizations.dart';
import 'package:guardian_child/features/protection_status/presentation/widgets/protection_status_card.dart';
import 'package:guardian_child/features/protection_status/presentation/widgets/screen_time_widget.dart';
import 'package:guardian_child/features/protection_status/presentation/widgets/quick_status.dart';
import 'package:guardian_child/features/protection_status/presentation/widgets/active_schedules.dart';

class ProtectionHomeScreen extends ConsumerWidget {
  const ProtectionHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.home),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProtectionStatusCard(),
              const SizedBox(height: 16),
              const ScreenTimeWidget(),
              const SizedBox(height: 16),
              const QuickStatus(),
              const SizedBox(height: 16),
              const ActiveSchedules(),
            ],
          ),
        ),
      ),
    );
  }
}