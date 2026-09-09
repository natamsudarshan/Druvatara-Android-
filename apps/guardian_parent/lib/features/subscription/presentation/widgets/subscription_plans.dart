import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class SubscriptionPlans extends StatelessWidget {
  const SubscriptionPlans({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final plans = [
      {
        'id': 'FREE',
        'name': l10n.free,
        'price': '₹0',
        'period': '/month',
        'features': {
          l10n.maxChildren: '1',
          l10n.maxDevices: '1',
          l10n.screenTime: true,
          l10n.webFiltering: false,
          l10n.location: false,
          l10n.geofencing: false,
          l10n.tara: false,
          l10n.reports: 'Basic',
        },
        'color': AppTheme.textSecondaryColor,
        'popular': false,
      },
      {
        'id': 'BASIC',
        'name': l10n.basic,
        'price': '₹129',
        'period': '/month',
        'features': {
          l10n.maxChildren: '2',
          l10n.maxDevices: '3',
          l10n.screenTime: true,
          l10n.webFiltering: true,
          l10n.location: true,
          l10n.geofencing: true,
          l10n.tara: true,
          l10n.reports: 'Standard',
        },
        'color': AppTheme.primaryColor,
        'popular': true,
      },
      {
        'id': 'PREMIUM',
        'name': l10n.premium,
        'price': '₹299',
        'period': '/month',
        'features': {
          l10n.maxChildren: '4',
          l10n.maxDevices: '6',
          l10n.screenTime: true,
          l10n.webFiltering: true,
          l10n.location: true,
          l10n.geofencing: true,
          l10n.tara: true,
          l10n.reports: 'Detailed',
        },
        'color': AppTheme.successColor,
        'popular': false,
      },
      {
        'id': 'FAMILY',
        'name': l10n.family,
        'price': '₹499',
        'period': '/month',
        'features': {
          l10n.maxChildren: '6',
          l10n.maxDevices: '10',
          l10n.screenTime: true,
          l10n.webFiltering: true,
          l10n.location: true,
          l10n.geofencing: true,
          l10n.tara: true,
          l10n.reports: 'Full',
        },
        'color': AppTheme.accentColor,
        'popular': false,
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.availablePlans,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: plans.map((plan) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _PlanCard(plan: plan),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;

  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = plan['color'] as Color;
    final popular = plan['popular'] as bool;
    final features = plan['features'] as Map<String, dynamic>;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: popular ? color : AppTheme.dividerColor,
          width: popular ? 2 : 1,
        ),
        boxShadow: popular ? [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(popular ? 0.1 : 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan['name'],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    if (plan['popular'])
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Popular',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      plan['price'],
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      plan['period'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: features.entries.map((entry) {
                final value = entry.value;
                final enabled = value is bool ? value : true;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        enabled ? Icons.check_circle : Icons.cancel,
                        size: 18,
                        color: enabled ? AppTheme.successColor : AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: enabled ? AppTheme.textPrimaryColor : AppTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                      if (value is String && !['true', 'false'].contains(value))
                        Text(
                          value,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
              child: Text(plan['id'] == 'FREE' ? 'Get Started' : 'Upgrade'),
            ),
          ),
        ],
      ),
    );
  }
}