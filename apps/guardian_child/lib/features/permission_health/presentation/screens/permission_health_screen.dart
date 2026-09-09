import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
import 'package:guardian_child/core/theme/app_theme.dart';
import 'package:guardian_child/core/localization/app_localizations.dart';
import 'package:guardian_child/features/permission_health/presentation/widgets/permission_health_card.dart';
import 'package:guardian_child/features/permission_health/presentation/widgets/permission_details.dart';

class PermissionHealthScreen extends ConsumerWidget {
  const PermissionHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.permissions),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PermissionHealthCard(),
            const SizedBox(height: 16),
            const PermissionDetails(),
          ],
        ),
      ),
    );
  }
}