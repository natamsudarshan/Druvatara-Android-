import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
import 'package:guardian_child/core/theme/app_theme.dart';
import 'package:guardian_child/core/localization/app_localizations.dart';
import 'package:go_router/go_router.dart';

class PermissionWizardScreen extends ConsumerStatefulWidget {
  const PermissionWizardScreen({super.key});

  @override
  ConsumerState<PermissionWizardScreen> createState() => _PermissionWizardScreenState();
}

class _PermissionWizardScreenState extends ConsumerState<PermissionWizardScreen> {
  int _currentStep = 0;
  final List<bool> _permissionsGranted = [false, false, false, false, false, false];

  final List<_PermissionStep> _steps = [
    _PermissionStep(
      title: 'Notifications',
      description: 'Receive alerts and updates from your parents',
      icon: Icons.notifications_active,
      color: AppTheme.primaryColor,
      permission: 'NOTIFICATIONS',
    ),
    _PermissionStep(
      title: 'Usage Access',
      description: 'Allow monitoring of app usage and screen time',
      icon: Icons.apps,
      color: AppTheme.secondaryColor,
      permission: 'USAGE_ACCESS',
    ),
    _PermissionStep(
      title: 'Location',
      description: 'Share your location for safety and safe zones',
      icon: Icons.location_on,
      color: AppTheme.successColor,
      permission: 'LOCATION',
    ),
    _PermissionStep(
      title: 'Background Location',
      description: 'Enable safe zone alerts even when app is closed',
      icon: Icons.location_history,
      color: AppTheme.warningColor,
      permission: 'BACKGROUND_LOCATION',
    ),
    _PermissionStep(
      title: 'VPN Permission',
      description: 'Enable web safety filtering and threat blocking',
      icon: Icons.vpn_key,
      color: AppTheme.errorColor,
      permission: 'VPN',
    ),
    _PermissionStep(
      title: 'Battery Optimization',
      description: 'Disable battery optimization for continuous protection',
      icon: Icons.battery_saver,
      color: AppTheme.accentColor,
      permission: 'BATTERY',
    ),
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      context.go('/home');
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _grantPermission(_PermissionStep step) {
    // Request actual permission
    setState(() {
      _permissionsGranted[_currentStep] = true;
    });
    Future.delayed(const Duration(milliseconds: 500), _nextStep);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final step = _steps[_currentStep];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.permissionSetup),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentStep + 1) / _steps.length,
                backgroundColor: AppTheme.dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(step.color),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 8),
              Text(
                'Step ${_currentStep + 1} of ${_steps.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 32),
              // Permission card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: step.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: step.color.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: step.color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step.icon,
                        size: 48,
                        color: step.color,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      step.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: step.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      step.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Action button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _grantPermission(step),
                  style: FilledButton.styleFrom(
                    backgroundColor: step.color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _permissionsGranted[_currentStep]
                        ? l10n.granted
                        : l10n.grantPermission,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (!_permissionsGranted[_currentStep]) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _nextStep,
                  child: Text(l10n.skipForNow),
                ),
              ],
              const Spacer(),
              // Step indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentStep ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index <= _currentStep ? step.color : AppTheme.dividerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String permission;

  _PermissionStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.permission,
  });
}