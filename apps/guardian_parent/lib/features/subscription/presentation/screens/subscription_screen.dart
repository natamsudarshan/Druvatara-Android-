import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';
import 'package:guardian_parent/features/subscription/presentation/widgets/subscription_plans.dart';
import 'package:guardian_parent/features/subscription/presentation/widgets/current_subscription.dart';
import 'package:guardian_parent/features/subscription/presentation/widgets/billing_history.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.subscription),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CurrentSubscription(),
            const SizedBox(height: 16),
            const SubscriptionPlans(),
            const SizedBox(height: 16),
            const BillingHistory(),
          ],
        ),
      ),
    );
  }
}