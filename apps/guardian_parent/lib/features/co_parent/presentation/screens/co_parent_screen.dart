import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';
import 'package:guardian_parent/features/co_parent/presentation/widgets/co_parent_list.dart';
import 'package:guardian_parent/features/co_parent/presentation/widgets/invite_co_parent_dialog.dart';

class CoParentScreen extends ConsumerWidget {
  const CoParentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.coParent),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const InviteCoParentDialog(),
            ),
          ),
        ],
      ),
      body: const CoParentList(),
    );
  }
}