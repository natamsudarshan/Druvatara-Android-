import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';
import 'package:guardian_parent/features/devices/presentation/widgets/device_health_card.dart';
import 'package:guardian_parent/features/devices/presentation/widgets/device_permissions.dart';
import 'package:guardian_parent/features/devices/presentation/widgets/device_info.dart';

class DeviceDetailScreen extends ConsumerWidget {
  final String deviceId;

  const DeviceDetailScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // Mock data
    final device = {
      'id': deviceId,
      'name': 'Alex Phone',
      'childName': 'Alex',
      'platform': 'ANDROID',
      'status': 'ACTIVE',
      'lastSeen': '2 min ago',
      'battery': 85,
      'appVersion': '1.0.0',
      'osVersion': 'Android 14',
      'manufacturer': 'Samsung',
      'model': 'SM-G991B',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(device['name'] as String),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force sync
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptions(context, l10n),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: DeviceInfo(device: device),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DeviceHealthCard(device: device),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DevicePermissions(deviceId: deviceId),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.refresh),
            title: Text(l10n.forceSync),
            onTap: () {
              Navigator.pop(context);
              // Force sync
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.deviceSettings),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
            title: Text(l10n.removeDevice, style: TextStyle(color: AppTheme.errorColor)),
            onTap: () {
              Navigator.pop(context);
              _confirmRemove(context, l10n);
            },
          ),
        ],
      ),
    );
  }

  void _confirmRemove(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeDevice),
        content: Text(l10n.confirmRemoveDevice),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
  }
}