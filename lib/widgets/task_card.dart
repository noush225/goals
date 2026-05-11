import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app/theme.dart';
import '../data/task.dart';
import '../utils/time_format.dart';
import 'press_button.dart';

/// Carte de tâche du dashboard.
/// Reproduit la TaskCard React : kicker (type + temps), titre, play button,
/// + barre de progression conditionnelle pour les tâches « Progression ».
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onPlay,
    required this.onEdit,
    this.showDate = false,
  });

  final Task task;
  final VoidCallback onPlay;
  final VoidCallback onEdit;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final isProg = task.isProgression;

    return PressButton(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Kicker(
                        isProgression: isProg,
                        minutes: task.minutes,
                        date: showDate ? task.date : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                PressButton(
                  semanticLabel: 'Lancer ${task.title}',
                  onTap: onPlay,
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
            if (isProg) ...[
              const SizedBox(height: 14),
              _ProgressRow(task: task),
            ],
          ],
        ),
      ),
    );
  }
}

class _Kicker extends StatelessWidget {
  const _Kicker({
    required this.isProgression,
    required this.minutes,
    this.date,
  });

  final bool isProgression;
  final int minutes;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return Row(
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
          formatMinutes(minutes),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.12,
            color: AppColors.muted,
          ),
        ),
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
