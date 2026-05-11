import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../data/task.dart';
import '../data/task_provider.dart';
import '../screens/add_task_sheet.dart';
import '../screens/focus_screen.dart';
import '../utils/time_format.dart';
import 'press_button.dart';

/// Carte de tâche du dashboard.
/// Reproduit la TaskCard React : kicker (type + temps), titre, play button,
/// + barre de progression conditionnelle pour les tâches « Progression ».
class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onPlay,
    required this.onEdit,
    this.onPlayFromChild,
    this.onEditFromChild,
    this.showDate = false,
  });

  final Task task;
  final VoidCallback onPlay;
  final VoidCallback onEdit;
  final Function(Task)? onPlayFromChild;
  final Function(Task)? onEditFromChild;
  final bool showDate;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final children = provider.childrenOf(widget.task.id);
    final isProg = widget.task.isProgression;
    final totalSeconds = provider.aggregateSeconds(widget.task.id);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A2D3A2E),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
              BoxShadow(
                color: Color(0x142D3A2E),
                blurRadius: 24,
                spreadRadius: -12,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: widget.onEdit,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(AppRadius.card),
                  bottom: Radius.circular(children.isNotEmpty ? 0 : AppRadius.card),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Kicker(
                              isProgression: isProg,
                              seconds: totalSeconds,
                              directSeconds: widget.task.seconds,
                              date: widget.showDate ? widget.task.date : null,
                              hasChildren: children.isNotEmpty,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.task.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      PressButton(
                        semanticLabel: 'Lancer ${widget.task.title}',
                        onTap: widget.onPlay,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentShadow,
                                blurRadius: 18,
                                spreadRadius: -6,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 3),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: AppColors.surface,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isProg) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ProgressRow(task: widget.task),
                ),
                const SizedBox(height: 14),
              ],
              if (children.isNotEmpty) ...[
                const Divider(height: 1, color: AppColors.hairline),
                InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _expanded ? 'Masquer les sous-tâches' : 'Voir les ${children.length} sous-tâches',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                          size: 18,
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_expanded && children.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4, bottom: 12),
            child: Column(
              children: [
                for (final child in children)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TaskCard(
                      task: child,
                      onPlay: () => widget.onPlayFromChild?.call(child) ?? _defaultPlayChild(context, child),
                      onEdit: () => widget.onEditFromChild?.call(child) ?? _defaultEditChild(context, child),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  void _defaultPlayChild(BuildContext context, Task child) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (_, __, ___) => FocusScreen(task: child),
        transitionsBuilder: (_, anim, __, childWidget) => FadeTransition(opacity: anim, child: childWidget),
      ),
    );
  }

  void _defaultEditChild(BuildContext context, Task child) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x52141816),
      builder: (_) => AddTaskSheet(task: child),
    );
  }
}

class _Kicker extends StatelessWidget {
  const _Kicker({
    required this.isProgression,
    required this.seconds,
    required this.directSeconds,
    this.date,
    this.hasChildren = false,
  });

  final bool isProgression;
  final int seconds;
  final int directSeconds;
  final DateTime? date;
  final bool hasChildren;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(
          isProgression ? Icons.stacked_bar_chart_rounded : Icons.adjust_rounded,
          size: 14,
          color: AppColors.accent,
        ),
        const SizedBox(width: 8),
        Text(
          isProgression ? 'PROGRESSION' : 'PONCTUELLE',
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.7,
            color: AppColors.muted,
          ),
        ),
        if (date != null) ...[
          const _Dot(),
          Text(
            DateFormat('d MMM', 'fr_FR').format(date!).toUpperCase(),
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.accent,
            ),
          ),
        ],
        const _Dot(),
        Text(
          formatMinutes(seconds ~/ 60),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.12,
            color: AppColors.muted,
          ),
        ),
        if (hasChildren && directSeconds > 0) ...[
          const SizedBox(width: 4),
          Text(
            '(dont ${formatMinutes(directSeconds ~/ 60)} sur cette tâche)',
            style: const TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: AppColors.muted,
            ),
          ),
        ],
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context) {
    final pct = (task.progress / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Stack(
            children: [
              Container(height: 4, color: AppColors.hairline),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${task.progress}% complété',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.muted,
                letterSpacing: -0.12,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            if (task.subtasks != null)
              Text(
                task.subtasks!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                  letterSpacing: -0.12,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: AppColors.muted,
        shape: BoxShape.circle,
      ),
    );
  }
}
