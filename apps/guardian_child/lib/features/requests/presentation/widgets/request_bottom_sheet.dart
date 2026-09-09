import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian_child/core/theme/app_theme.dart';
import 'package:guardian_child/core/localization/app_localizations.dart';

class RequestBottomSheet extends ConsumerStatefulWidget {
  const RequestBottomSheet({super.key});

  @override
  ConsumerState<RequestBottomSheet> createState() => _RequestBottomSheetState();
}

class _RequestBottomSheetState extends ConsumerState<RequestBottomSheet> {
  String _selectedType = 'MORE_TIME';
  final _resourceController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _resourceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.requestAccess,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.requestType,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TypeChip(
                  label: 'More Time',
                  value: 'MORE_TIME',
                  selected: _selectedType == 'MORE_TIME',
                  onSelected: () => setState(() => _selectedType = 'MORE_TIME'),
                  color: AppTheme.primaryColor,
                ),
                _TypeChip(
                  label: 'App Access',
                  value: 'APP_ACCESS',
                  selected: _selectedType == 'APP_ACCESS',
                  onSelected: () => setState(() => _selectedType = 'APP_ACCESS'),
                  color: AppTheme.secondaryColor,
                ),
                _TypeChip(
                  label: 'Website Access',
                  value: 'WEBSITE_ACCESS',
                  selected: _selectedType == 'WEBSITE_ACCESS',
                  onSelected: () => setState(() => _selectedType = 'WEBSITE_ACCESS'),
                  color: AppTheme.errorColor,
                ),
                _TypeChip(
                  label: 'Schedule Exception',
                  value: 'SCHEDULE_EXCEPTION',
                  selected: _selectedType == 'SCHEDULE_EXCEPTION',
                  onSelected: () => setState(() => _selectedType = 'SCHEDULE_EXCEPTION'),
                  color: AppTheme.successColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _resourceController,
              decoration: InputDecoration(
                labelText: _selectedType == 'MORE_TIME' 
                    ? 'Additional time (e.g., 30 minutes)' 
                    : 'App/Website name',
                hintText: _selectedType == 'MORE_TIME' ? '30 minutes' : 'TikTok, youtube.com, etc.',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Message to parent (optional)',
                hintText: 'Why do you need this?',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Submit request
                },
                child: Text(l10n.sendRequest),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onSelected;
  final Color color;

  const _TypeChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: theme.textTheme.bodySmall?.copyWith(
        color: selected ? color : AppTheme.textSecondaryColor,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(
        color: selected ? color : AppTheme.dividerColor,
      ),
      showCheckmark: false,
    );
  }
}