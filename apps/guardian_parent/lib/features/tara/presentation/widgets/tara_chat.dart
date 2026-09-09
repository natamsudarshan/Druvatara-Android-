import 'package:flutter/material.dart';
import 'package:guardian_parent/core/theme/app_theme.dart';
import 'package:guardian_parent/core/localization/app_localizations.dart';

class TaraChat extends StatelessWidget {
  const TaraChat({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mock messages
    final messages = [
      {
        'sender': 'tara',
        'text': "Hi! I'm TARA, your digital safety assistant. How can I help you today?",
        'time': '10:30 AM',
        'suggestions': ['Screen time summary', 'Recent alerts', 'Safety score explanation'],
      },
      {
        'sender': 'user',
        'text': "How much screen time did Alex have today?",
        'time': '10:31 AM',
      },
      {
        'sender': 'tara',
        'text': "Alex has used 2h 34m today out of a 3h limit. That's 85% used. The most used app was YouTube (1h 20m). Would you like me to explain the usage breakdown?",
        'time': '10:31 AM',
        'suggestions': ['Show app breakdown', 'Set stricter limit', 'Grant extra time'],
      },
      {
        'sender': 'user',
        'text': "Show app breakdown",
        'time': '10:32 AM',
      },
      {
        'sender': 'tara',
        'text': "Here's Alex's app usage today:\n• YouTube: 1h 20m\n• Instagram: 45m\n• Roblox: 30m\n• WhatsApp: 25m\n• Chrome: 20m\n\nYouTube is at 45% of total time. Would you like to set a specific limit for YouTube?",
        'time': '10:32 AM',
        'suggestions': ['Limit YouTube to 1h', 'Block YouTube today', 'View weekly trend'],
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isUser = msg['sender'] == 'user';
        return _MessageBubble(
          isUser: isUser,
          text: msg['text'] as String,
          time: msg['time'] as String,
          suggestions: msg['suggestions'] as List<String>?,
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final bool isUser;
  final String text;
  final String time;
  final List<String>? suggestions;

  const _MessageBubble({
    required this.isUser,
    required this.text,
    required this.time,
    this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Icon(Icons.psychology, color: AppTheme.primaryColor, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primaryColor : theme.cardColor,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isUser ? Radius.circular(4) : Radius.circular(16),
                  bottomLeft: isUser ? Radius.circular(16) : Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isUser ? Colors.white : AppTheme.textPrimaryColor,
                    ),
                  ),
                  if (suggestions != null && suggestions!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: suggestions!.map((s) => _SuggestionChip(
                        label: s,
                        onTap: () {},
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ActionChip(
      label: Text(label, style: Theme.of(context).textTheme.bodySmall),
      onPressed: onTap,
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppTheme.primaryColor,
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
    );
  }
}