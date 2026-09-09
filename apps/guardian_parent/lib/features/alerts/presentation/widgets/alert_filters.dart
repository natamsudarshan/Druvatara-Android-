import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class AlertFilters extends StatelessWidget {
  const AlertFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock filter state
    String selectedSeverity = 'ALL';
    String selectedStatus = 'ALL';
    String selectedChild = 'ALL';

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
                _FilterChip(
                  label: l10n.allSeverity,
                  selected: selectedSeverity == 'ALL',
                  onSelected: () {},
                ),
                _FilterChip(
                  label: 'Critical',
                  selected: selectedSeverity == 'CRITICAL',
                  onSelected: () {},
                  color: AppTheme.errorColor,
                ),
                _FilterChip(
                  label: 'High',
                  selected: selectedSeverity == 'HIGH',
                  onSelected: () {},
                  color: AppTheme.errorColor,
                ),
                _FilterChip(
                  label: 'Medium',
                  selected: selectedSeverity == 'MEDIUM',
                  onSelected: () {},
                  color: AppTheme.warningColor,
                ),
                _FilterChip(
                  label: 'Low',
                  selected: selectedSeverity == 'LOW',
                  onSelected: () {},
                  color: AppTheme.successColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: l10n.allStatus,
                  selected: selectedStatus == 'ALL',
                  onSelected: () {},
                ),
                _FilterChip(
                  label: 'New',
                  selected: selectedStatus == 'NEW',
                  onSelected: () {},
                  color: AppTheme.errorColor,
                ),
                _FilterChip(
                  label: 'Acknowledged',
                  selected: selectedStatus == 'ACKNOWLEDGED',
                  onSelected: () {},
                  color: AppTheme.warningColor,
                ),
                _FilterChip(
                  label: 'Resolved',
                  selected: selectedStatus == 'RESOLVED',
                  onSelected: () {},
                  color: AppTheme.successColor,
                ),
                _FilterChip(
                  label: 'Dismissed',
                  selected: selectedStatus == 'DISMISSED',
                  onSelected: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: l10n.allChildren,
                  selected: selectedChild == 'ALL',
                  onSelected: () {},
                ),
                _FilterChip(
                  label: 'Alex',
                  selected: selectedChild == 'Alex',
                  onSelected: () {},
                ),
                _FilterChip(
                  label: 'Sam',
                  selected: selectedChild == 'Sam',
                  onSelected: () {},
                ),
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