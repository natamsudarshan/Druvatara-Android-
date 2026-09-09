import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';
import 'package:guardian_parent/features/devices/presentation/screens/device_detail_screen.dart';
import 'package:guardian_parent/features/devices/presentation/widgets/device_card.dart';

class DeviceListScreen extends ConsumerWidget {
  const DeviceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // Mock data
    final devices = [
      {
        'id': 'dev_1',
        'name': 'Alex Phone',
        'childName': 'Alex',
        'platform': 'ANDROID',
        'status': 'ACTIVE',
        'lastSeen': '2 min ago',
        'battery': 85,
      },
      {
        'id': 'dev_2',
        'name': 'Sam Tablet',
        'childName': 'Sam',
        'platform': 'ANDROID',
        'status': 'PARTIALLY_PROTECTED',
        'lastSeen': '1 hour ago',
        'battery': 45,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.devices),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showPairChildDialog(context, l10n),
          ),
        ],
      ),
      body: devices.isEmpty
          ? _buildEmptyState(context, l10n)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return DeviceCard(
                  device: device,
                  onTap: () => context.go('/devices/${device['id']}'),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.devices_outlined, size: 60, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noDevicesYet,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.pairFirstDevice,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showPairChildDialog(context, l10n),
              icon: const Icon(Icons.add),
              label: Text(l10n.pairDevice),
            ),
          ],
        ),
      ),
    );
  }

  void _showPairChildDialog(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.selectChildToPair,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text('A', style: TextStyle(color: AppTheme.primaryColor)),
              ),
              title: const Text('Alex'),
              subtitle: Text(l10n.preTeen),
              onTap: () {
                Navigator.pop(context);
                context.go('/pairing/child_1');
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                child: Text('S', style: TextStyle(color: AppTheme.secondaryColor)),
              ),
              title: const Text('Sam'),
              subtitle: Text(l10n.youngChild),
              onTap: () {
                Navigator.pop(context);
                context.go('/pairing/child_2');
              },
            ),
          ],
        ),
      ),
    );
  }
}