import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goals/features/settings/presentation/providers/settings_provider.dart';
import 'package:goals/l10n/generated/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text(
            l10n.dailyReminder.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.5,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l10n.dailyReminder),
                  subtitle: Text(l10n.dailyReminderSubtitle),
                  value: settingsProvider.isReminderEnabled,
                  onChanged: (value) => 
                      settingsProvider.toggleReminder(value, l10n),
                ),
                if (settingsProvider.isReminderEnabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    title: Text(l10n.reminderTime),
                    subtitle: Text(
                      settingsProvider.reminderTime.format(context),
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: settingsProvider.reminderTime,
                      );
                      if (picked != null) {
                        settingsProvider.setReminderTime(picked, l10n);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => settingsProvider.sendTestNotification(l10n),
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Tester la notification'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
