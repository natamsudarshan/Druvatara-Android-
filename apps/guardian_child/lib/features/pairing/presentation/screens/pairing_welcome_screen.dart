import 'package:flutter/material.dart';
import 'package:guardian_child/core/theme/app_theme.dart';
import 'package:guardian_child/core/localization/app_localizations.dart';
import 'package:go_router/go_router.dart';

class PairingWelcomeScreen extends StatelessWidget {
  const PairingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.shield_outlined, size: 80, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 40),
              Text(
                l10n.welcomeToGuardianChild,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.pairingWelcomeDescription,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              FilledButton(
                onPressed: () => context.go('/pairing/scan'),
                child: Text(l10n.scanQRCode),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.go('/pairing/enter-code'),
                child: Text(l10n.enterCodeManually),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.needHelpPairing,
                style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}