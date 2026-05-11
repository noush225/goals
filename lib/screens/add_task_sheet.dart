import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../data/task.dart';
import '../data/task_provider.dart';
import '../widgets/press_button.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final TextEditingController _title = TextEditingController();
  final FocusNode _titleFocus = FocusNode();

  TaskType _type = TaskType.oneshot;
  double _progress = 20;
  late DateTime _date;
  Task? _parent;
  bool _parentOpen = false;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
    Future.delayed(const Duration(milliseconds: 320), () {
      if (mounted) _titleFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  bool get _canSave => _title.text.trim().isNotEmpty;

  void _save() {
    if (!_canSave) return;
    context.read<TaskProvider>().add(
          title: _title.text,
          type: _type,
          progress: _progress.round(),
          date: _date,
          parentId: _parent?.id,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
          boxShadow: [
            BoxShadow(
              color: Color(0x2E2D3A2E),
              blurRadius: 32,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PressButton(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ),
                  const Text(
                    'Nouvelle tâche',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                      letterSpacing: -0.15,
                    ),
                  ),
                  const SizedBox(width: 56),
                ],
              ),
            ),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title input
                    TextField(
                      controller: _title,
                      focusNode: _titleFocus,
                      onChanged: (_) => setState(() {}),
                      cursorColor: AppColors.accent,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                        letterSpacing: -0.65,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Que veux-tu créer ?',
                        hintStyle: TextStyle(
                          color: AppColors.muted.withOpacity(0.8),
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.65,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        isDense: true,
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.hairline),

                    const SizedBox(height: 22),

                    _FieldGroup(
                      label: 'Date',
                      child: _MiniCalendar(
                        selected: _date,
                        onSelect: (d) => setState(() => _date = d),
                      ),
                    ),

                    const SizedBox(height: 22),

                    _FieldGroup(
                      label: 'Type de tâche',
                      child: Row(
                        children: [
                          Expanded(
                            child: _TypeChip(
                              icon: Icons.adjust_rounded,
                              label: 'Ponctuelle',
                              sub: 'Une session unique',
                              selected: _type == TaskType.oneshot,
                              onTap: () => setState(() => _type = TaskType.oneshot),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _TypeChip(
                              icon: Icons.stacked_bar_chart_rounded,
                              label: 'Progression',
                              sub: 'Suivi dans le temps',
                              selected: _type == TaskType.progression,
                              onTap: () => setState(() => _type = TaskType.progression),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_type == TaskType.progression) ...[
                      const SizedBox(height: 22),
                      _FieldGroup(
                        label: 'Progression de départ',
                        value: '${_progress.round()}%',
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            activeTrackColor: AppColors.accent,
                            inactiveTrackColor: AppColors.hairline,
                            thumbColor: AppColors.accent,
                            overlayColor: AppColors.accent.withOpacity(0.12),
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 9,
                            ),
                          ),
                          child: Slider(
                            value: _progress,
                            min: 0,
                            max: 100,
                            onChanged: (v) => setState(() => _progress = v),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 22),

                    _FieldGroup(
                      label: 'Tâche parente',
                      optional: true,
                      child: _ParentDropdown(
                        selected: _parent,
                        open: _parentOpen,
                        onToggle: () => setState(() => _parentOpen = !_parentOpen),
                        onPick: (t) => setState(() {
                          _parent = t;
                          _parentOpen = false;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: EdgeInsets.fromLTRB(
                24,
                14,
                24,
                MediaQuery.of(context).padding.bottom + 14,
              ),
              decoration: const BoxDecoration(
                color: AppColors.bg,
                border: Border(top: BorderSide(color: AppColors.hairline)),
              ),
              child: PressButton(
                onTap: _canSave ? _save : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _canSave ? AppColors.ink : AppColors.hairline,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Text(
                    'Enregistrer la tâche',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _canSave ? AppColors.surface : AppColors.muted,
                      letterSpacing: -0.16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sous-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _FieldGroup extends StatelessWidget {
  const _FieldGroup({
    required this.label,
    required this.child,
    this.optional = false,
    this.value,
  });

  final String label;
  final Widget child;
  final bool optional;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.7,
                  color: AppColors.muted,
                ),
                children: [
                  TextSpan(text: label.toUpperCase()),
                  if (optional)
                    const TextSpan(
                      text: ' · OPTIONNEL',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                ],
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                  letterSpacing: -0.13,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.icon,
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressButton(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: selected ? null : Border.all(color: AppColors.hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppColors.accentLight : AppColors.accent,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.surface : AppColors.ink,
                letterSpacing: -0.14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: TextStyle(
                fontSize: 11.5,
                color: (selected ? AppColors.surface : AppColors.ink).withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniCalendar extends StatefulWidget {
  const _MiniCalendar({required this.selected, required this.onSelect});

  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  State<_MiniCalendar> createState() => _MiniCalendarState();
}

class _MiniCalendarState extends State<_MiniCalendar> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = DateTime(widget.selected.year, widget.selected.month, 1);
  }

  void _shift(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy', 'fr_FR').format(_month);
    final startDow = (_month.weekday + 6) % 7; // lundi = 0
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final today = DateTime.now();
    final selected = widget.selected;

    final cells = <Widget>[];
    for (var i = 0; i < startDow; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var d = 1; d <= daysInMonth; d++) {
      final day = DateTime(_month.year, _month.month, d);
      final isSel = _sameDay(day, selected);
      final isToday = _sameDay(day, today);

      cells.add(GestureDetector(
        onTap: () => widget.onSelect(day),
        behavior: HitTestBehavior.opaque,
        child: AspectRatio(
          aspectRatio: 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSel ? AppColors.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$d',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSel || isToday ? FontWeight.w600 : FontWeight.w500,
                color: isSel
                    ? AppColors.surface
                    : (isToday ? AppColors.accent : AppColors.ink),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ));
    }
    while (cells.length % 7 != 0) {
      cells.add(const SizedBox.shrink());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthLabel.isNotEmpty
                    ? monthLabel[0].toUpperCase() + monthLabel.substring(1)
                    : monthLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                  letterSpacing: -0.14,
                ),
              ),
              Row(
                children: [
                  _NavButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => _shift(-1),
                  ),
                  const SizedBox(width: 4),
                  _NavButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: () => _shift(1),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final d in const ['L', 'M', 'M', 'J', 'V', 'S', 'D'])
              Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 7,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          children: cells,
        ),
      ],
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressButton(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppColors.inkSoft),
      ),
    );
  }
}

class _ParentDropdown extends StatelessWidget {
  const _ParentDropdown({
    required this.selected,
    required this.open,
    required this.onToggle,
    required this.onPick,
  });

  final Task? selected;
  final bool open;
  final VoidCallback onToggle;
  final ValueChanged<Task?> onPick;

  @override
  Widget build(BuildContext context) {
    final candidates = context.read<TaskProvider>().candidatesAsParent();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PressButton(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selected?.title ?? 'Aucune',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: selected == null ? AppColors.muted : AppColors.ink,
                      letterSpacing: -0.15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AnimatedRotation(
                  turns: open ? 0.5 : 0,
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
        if (open)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.hairline),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Column(
                children: [
                  _row('Aucune', () => onPick(null), isLast: candidates.isEmpty),
                  for (var i = 0; i < candidates.length; i++)
                    _row(
                      candidates[i].title,
                      () => onPick(candidates[i]),
                      isLast: i == candidates.length - 1,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _row(String label, VoidCallback onTap, {required bool isLast}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : AppColors.hairline,
            ),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14.5,
            color: AppColors.ink,
            letterSpacing: -0.15,
          ),
        ),
      ),
    );
  }
}
