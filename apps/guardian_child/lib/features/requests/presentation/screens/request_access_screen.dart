import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_child/core/theme/app_theme.dart';
import 'package:guardian_child/core/localization/app_localizations.dart';
import 'package:guardian_child/features/requests/presentation/widgets/child_request_list.dart';
import 'package:guardian_child/features/requests/presentation/widgets/request_bottom_sheet.dart';

class RequestAccessScreen extends ConsumerWidget {
  const RequestAccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.requests),
      ),
      body: const ChildRequestList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRequestSheet(context, l10n),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showRequestSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const RequestBottomSheet(),
    );
  }
}