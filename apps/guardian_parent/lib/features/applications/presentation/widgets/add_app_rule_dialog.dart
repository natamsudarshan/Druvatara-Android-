import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class AddAppRuleDialog extends StatefulWidget {
  const AddAppRuleDialog({super.key});

  @override
  State<AddAppRuleDialog> createState() => _AddAppRuleDialogState();
}

class _AddAppRuleDialogState extends State<AddAppRuleDialog> {
  final _formKey = GlobalKey<FormState>();
  String _selectedApp = '';
  String _selectedRule = 'LIMIT';
  String _limitHours = '1';
  String _limitMinutes = '0';

  final List<String> _availableApps = [
    'Instagram', 'YouTube', 'TikTok', 'Roblox', 'Snapchat',
    'WhatsApp', 'Chrome', 'Spotify', 'Netflix', 'Discord',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(l10n.addAppRule),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedApp.isEmpty ? null : _selectedApp,
                decoration: InputDecoration(
                  labelText: l10n.selectApp,
                  hintText: l10n.chooseAnApp,
                ),
                items: _availableApps.map((app) {
                  return DropdownMenuItem(value: app, child: Text(app));
                }).toList(),
                onChanged: (value) => setState(() => _selectedApp = value!),
                validator: (value) => value == null ? l10n.selectAnApp : null,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.ruleType,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'BLOCK',
                    label: Text(l10n.block),
                    icon: const Icon(Icons.block),
                  ),
                  ButtonSegment(
                    value: 'LIMIT',
                    label: Text(l10n.limit),
                    icon: const Icon(Icons.timer),
                  ),
                  ButtonSegment(
                    value: 'ALLOW',
                    label: Text(l10n.allow),
                    icon: const Icon(Icons.check_circle),
                  ),
                ],
                selected: {_selectedRule},
                onSelectionChanged: (set) => setState(() => _selectedRule = set.first),
              ),
              if (_selectedRule == 'LIMIT') ...[
                const SizedBox(height: 16),
                Text(
                  l10n.timeLimit,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _limitHours,
                        decoration: InputDecoration(
                          labelText: l10n.hours,
                          hintText: '1',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _limitHours = value,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: _limitMinutes,
                        decoration: InputDecoration(
                          labelText: l10n.minutes,
                          hintText: '0',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _limitMinutes = value,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context);
            }
          },
          child: Text(l10n.addRule),
        ),
      ],
    );
  }
}