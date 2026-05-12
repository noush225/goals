import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/theme.dart';
import '../data/session.dart';
import '../data/task.dart';
import '../data/task_provider.dart';
import '../utils/time_format.dart';

/// Liste de sessions groupées par jour avec header de date.
///
/// Utilisée par Tab Activité (filtrée) et Tab Journal (complète).
class SessionsList extends StatelessWidget {
  const SessionsList({
    super.key,
    required this.sessions,
    required this.taskProvider,
    this.padding,
    this.emptyTitle = 'Aucune session pour le moment.',
    this.emptyHint = 'Lance une tâche en Focus pour commencer.',
  });

  final List<Session> sessions;
  final TaskProvider taskProvider;
  final EdgeInsets? padding;
  final String emptyTitle;
  final String emptyHint;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return _Empty(title: emptyTitle, hint: emptyHint);
    }

    // Groupage par jour, du plus récent au plus ancien
    final sorted = [...sessions]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final groups = <DateTime, List<Session>>{};
    for (final s in sorted) {
      final key =
          DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day);
      groups.putIfAbsent(key, () => []).add(s);
    }

    final items = <Widget>[];
    groups.forEach((day, list) {
      items.add(_DayHeader(date: day, totalSeconds: _sum(list)));
      for (var i = 0; i < list.length; i++) {
        items.add(
          _SessionRow(
            session: list[i],
            task: taskProvider.byId(list[i].taskId),
            isFirstOfDay: i == 0,
            isLastOfDay: i == list.length - 1,
          ),
        );
      }
      items.add(const SizedBox(height: 18));
    });

    return ListView(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: items,
    );
  }

  static int _sum(List<Session> ss) =>
      ss.fold(0, (acc, s) => acc + s.durationSeconds);
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date, required this.totalSeconds});
  final DateTime date;
  final int totalSeconds;

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(date).inDays;
    if (diff == 0) return "Aujourd'hui";
    if (diff == 1) return 'Hier';
    final fmt = DateFormat("EEEE d MMMM", 'fr_FR').format(date);
    return fmt[0].toUpperCase() + fmt.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              _label(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.ink,
              ),
            ),
          ),
          Text(
            formatMinutes(totalSeconds ~/ 60),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
              letterSpacing: -0.12,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.session,
    required this.task,
    required this.isFirstOfDay,
    required this.isLastOfDay,
  });

  final Session session;
  final Task? task;
  final bool isFirstOfDay;
  final bool isLastOfDay;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(session.startedAt);
    final radius = AppRadius.lg;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isFirstOfDay ? radius : 0),
          bottom: Radius.circular(isLastOfDay ? radius : 0),
        ),
        border: !isLastOfDay
            ? const Border(bottom: BorderSide(color: AppColors.hairline))
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
                fontFeatures: [FontFeature.tabularFigures()],
                letterSpacing: -0.13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              task?.title ?? 'Tâche supprimée',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.15,
                color: task == null ? AppColors.muted : AppColors.ink,
                fontStyle: task == null ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatMMSS(session.durationSeconds),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
              fontFeatures: [FontFeature.tabularFigures()],
              letterSpacing: -0.13,
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.title, required this.hint});
  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.surfaceSunk,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.menu_book_outlined,
                  color: AppColors.accent, size: 26),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              hint,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
