import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../data/sessions_provider.dart';
import '../data/settings_provider.dart';
import '../data/task_provider.dart';
import '../widgets/press_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pickerOpen = false;
  bool _langOpen = false;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  PressButton(
                    semanticLabel: 'Retour',
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x0A2D3A2E),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 20, AppSpacing.lg, 8,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Réglages',
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(fontSize: 32),
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 14, AppSpacing.lg, 40,
                ),
                children: [
                  // Notifications
                  _Section(
                    title: 'Notifications',
                    children: [
                      _SettingsRow(
                        icon: Icons.notifications_none_rounded,
                        label: 'Rappel quotidien',
                        sub: 'Un doux rappel pour démarrer ta journée',
                        trailing: _Toggle(
                          on: s.dailyReminder,
                          onChanged: s.setDailyReminder,
                        ),
                      ),
                      _SettingsRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Heure du rappel',
                        sub: s.dailyReminder
                            ? 'Quand nous t\'enverrons un rappel'
                            : 'Active les rappels pour configurer',
                        disabled: !s.dailyReminder,
                        trailing: PressButton(
                          onTap: s.dailyReminder
                              ? () => setState(() => _pickerOpen = !_pickerOpen)
                              : null,
                          child: Text(
                            _formatTime(s.reminderTime),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: s.dailyReminder
                                  ? AppColors.accent
                                  : AppColors.muted,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                              letterSpacing: -0.17,
                            ),
                          ),
                        ),
                      ),
                      if (_pickerOpen && s.dailyReminder)
                        _InlineTimePicker(
                          value: s.reminderTime,
                          onChange: s.setReminderTime,
                        ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Langue
                  _Section(
                    title: 'Langue',
                    children: [
                      _SettingsRow(
                        icon: Icons.language_rounded,
                        label: "Langue de l'app",
                        sub: 'Les changements s\'appliquent immédiatement',
                        trailing: PressButton(
                          onTap: () => setState(() => _langOpen = !_langOpen),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                s.language,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.ink,
                                  letterSpacing: -0.15,
                                ),
                              ),
                              const SizedBox(width: 4),
                              AnimatedRotation(
                                turns: _langOpen ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(
                                  Icons.expand_more_rounded,
                                  size: 18,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_langOpen)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.hairline),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Column(
                            children: [
                              for (var i = 0;
                                  i < SettingsProvider.supportedLanguages.length;
                                  i++)
                                _LangRow(
                                  label: SettingsProvider.supportedLanguages[i],
                                  selected: SettingsProvider
                                          .supportedLanguages[i] ==
                                      s.language,
                                  isLast: i ==
                                      SettingsProvider.supportedLanguages.length -
                                          1,
                                  onTap: () {
                                    s.setLanguage(
                                        SettingsProvider.supportedLanguages[i]);
                                    setState(() => _langOpen = false);
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 28),

                  // Données
                  _Section(
                    title: 'Données',
                    children: [
                      _SettingsRow(
                        icon: Icons.delete_sweep_outlined,
                        label: 'Réinitialiser les sessions',
                        sub:
                            'Efface tout le temps loggé. Les tâches sont conservées.',
                        trailing: PressButton(
                          semanticLabel: 'Réinitialiser',
                          onTap: () => _confirmReset(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSunk,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Effacer',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                                letterSpacing: -0.13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      'Momentum · v1.0',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final sessions = context.read<SessionsProvider>();
    final tasks = context.read<TaskProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Tout effacer ?'),
        content: const Text(
          "Toutes tes sessions et le temps cumulé sur chaque tâche seront supprimés. "
          "Les tâches elles-mêmes restent. Cette action est irréversible.",
          style: TextStyle(color: AppColors.inkSoft, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppColors.inkSoft),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Tout effacer',
              style: TextStyle(
                color: Color(0xFFB8755C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      await sessions.clearAll();
      // sessions.clearAll a aussi modifié tasks.seconds en base — on recharge.
      await tasks.reload();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.ink,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Sessions et temps réinitialisés.',
            style: TextStyle(color: AppColors.surface),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatTime(TimeOfDay t) {
    final isPm = t.hour >= 12;
    final h12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final hh = h12.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm ${isPm ? 'PM' : 'AM'}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sous-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.92,
              color: AppColors.muted,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.sub,
    required this.trailing,
    this.disabled = false,
  });

  final IconData icon;
  final String label;
  final String sub;
  final Widget trailing;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: disabled ? 0.5 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        constraints: const BoxConstraints(minHeight: 60),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceSunk,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                      letterSpacing: -0.15,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.muted,
                      letterSpacing: -0.05,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.on, required this.onChanged});
  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!on),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        width: 50,
        height: 30,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: on ? AppColors.accent : AppColors.hairline,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LangRow extends StatelessWidget {
  const _LangRow({
    required this.label,
    required this.selected,
    required this.isLast,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : AppColors.hairline,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.ink,
                letterSpacing: -0.15,
              ),
            ),
            if (selected)
              const Icon(Icons.check_rounded, size: 18, color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}

class _InlineTimePicker extends StatelessWidget {
  const _InlineTimePicker({required this.value, required this.onChange});

  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onChange;

  bool get _isPm => value.hour >= 12;
  int get _h12 => value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;

  TimeOfDay _withH12(int h12) {
    final newHour = _isPm ? (h12 % 12) + 12 : h12 % 12;
    return TimeOfDay(hour: newHour, minute: value.minute);
  }

  TimeOfDay _withPeriod(bool pm) {
    final h12 = _h12;
    final newHour = pm ? (h12 % 12) + 12 : h12 % 12;
    return TimeOfDay(hour: newHour, minute: value.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunk,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Stepper(
            value: _h12.toString().padLeft(2, '0'),
            onUp: () => onChange(_withH12(_h12 == 12 ? 1 : _h12 + 1)),
            onDown: () => onChange(_withH12(_h12 == 1 ? 12 : _h12 - 1)),
          ),
          const SizedBox(width: 6),
          const Text(
            ':',
            style: TextStyle(
              fontSize: 26,
              color: AppColors.ink,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          _Stepper(
            value: value.minute.toString().padLeft(2, '0'),
            onUp: () => onChange(TimeOfDay(
              hour: value.hour,
              minute: (value.minute + 5) % 60,
            )),
            onDown: () => onChange(TimeOfDay(
              hour: value.hour,
              minute: (value.minute + 55) % 60,
            )),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                for (final p in ['AM', 'PM'])
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChange(_withPeriod(p == 'PM')),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (p == 'AM' && !_isPm) || (p == 'PM' && _isPm)
                            ? AppColors.ink
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        p,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: (p == 'AM' && !_isPm) || (p == 'PM' && _isPm)
                              ? AppColors.surface
                              : AppColors.muted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.onUp, required this.onDown});

  final String value;
  final VoidCallback onUp;
  final VoidCallback onDown;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PressButton(
          onTap: onUp,
          child: const SizedBox(
            width: 32,
            height: 22,
            child: Icon(Icons.keyboard_arrow_up_rounded,
                size: 18, color: AppColors.muted),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.5,
              color: AppColors.ink,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        PressButton(
          onTap: onDown,
          child: const SizedBox(
            width: 32,
            height: 22,
            child: Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: AppColors.muted),
          ),
        ),
      ],
    );
  }
}
