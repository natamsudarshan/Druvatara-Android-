import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class RequestFilters extends StatelessWidget {
  const RequestFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.filters,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(l10n.clearAll),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(label: 'All Types', selected: true, onSelected: () {}),
                _FilterChip(label: 'More Time', selected: false, onSelected: () {}, color: AppTheme.primaryColor),
                _FilterChip(label: 'App Access', selected: false, onSelected: () {}, color: AppTheme.secondaryColor),
                _FilterChip(label: 'Website Access', selected: false, onSelected: () {}, color: AppTheme.errorColor),
                _FilterChip(label: 'Schedule', selected: false, onSelected: () {}, color: AppTheme.successColor),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(label: 'All Status', selected: true, onSelected: () {}),
                _FilterChip(label: 'Pending', selected: false, onSelected: () {}, color: AppTheme.warningColor),
                _FilterChip(label: 'Approved', selected: false, onSelected: () {}, color: AppTheme.successColor),
                _FilterChip(label: 'Rejected', selected: false, onSelected: () {}, color: AppTheme.errorColor),
                _FilterChip(label: 'Expired', selected: false, onSelected: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? AppTheme.primaryColor;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: chipColor.withOpacity(0.2),
      checkmarkColor: chipColor,
      labelStyle: theme.textTheme.bodySmall?.copyWith(
        color: selected ? chipColor : AppTheme.textSecondaryColor,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(
        color: selected ? chipColor : AppTheme.dividerColor,
      ),
      showCheckmark: false,
    );
  }
}