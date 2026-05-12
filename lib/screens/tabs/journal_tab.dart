import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../data/sessions_provider.dart';
import '../../data/task_provider.dart';
import '../../utils/time_format.dart';
import '../../widgets/sessions_list.dart';

class JournalTab extends StatelessWidget {
  const JournalTab({super.key});

  @override
  Widget build(BuildContext context) {
    final sessions = context.watch<SessionsProvider>();
    final tasks = context.watch<TaskProvider>();
    final all = sessions.all;
    final totalSec = all.fold<int>(0, (acc, s) => acc + s.durationSeconds);
    final daysCovered = sessions
        .groupedByDay(source: all)
        .length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 12, AppSpacing.lg, 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Journal',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  if (totalSec > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSunk,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        formatMinutes(totalSec ~/ 60),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                          letterSpacing: -0.13,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 4, AppSpacing.lg, 18,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  all.isEmpty
                      ? "Tout ce que tu as bossé apparaîtra ici."
                      : '${all.length} session${all.length > 1 ? 's' : ''} sur $daysCovered jour${daysCovered > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.13,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SessionsList(
                sessions: all,
                taskProvider: tasks,
                emptyTitle: 'Ton journal est vide.',
                emptyHint: 'Lance une tâche en Focus pour commencer ton historique.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
