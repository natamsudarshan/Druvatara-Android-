import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class SafetyScoreCard extends StatelessWidget {
  const SafetyScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock data
    const score = 87;
    const factors = {
      'protectionStatus': 0.95,
      'screenTimeBalance': 0.8,
      'alertResolution': 1.0,
      'screenTimeCompliance': 0.85,
      'vpnEnabled': 1.0,
      'locationEnabled': 1.0,
      'accountSecurity': 1.0,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.safetyScore,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getScoreColor(score).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$score',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _getScoreColor(score),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            ...factors.entries.map((entry) => _buildFactorRow(
              context,
              _getFactorLabel(entry.key, l10n),
              entry.value,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorRow(BuildContext context, String label, double value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: AppTheme.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor((value * 100).round())),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(value * 100).round()}%',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppTheme.successColor;
    if (score >= 60) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  String _getFactorLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'protectionStatus': return l10n.protectionStatus;
      case 'screenTimeBalance': return l10n.screenTimeBalance;
      case 'alertResolution': return l10n.alertResolution;
      case 'screenTimeCompliance': return l10n.screenTimeCompliance;
      case 'vpnEnabled': return l10n.vpnEnabled;
      case 'locationEnabled': return l10n.locationEnabled;
      case 'accountSecurity': return l10n.accountSecurity;
      default: return key;
    }
  }
}