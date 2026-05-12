import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../data/sessions_provider.dart';
import '../../data/task_provider.dart';
import '../../utils/time_format.dart';
import '../../widgets/segmented_tabs.dart';
import '../../widgets/sessions_list.dart';

enum ActivityRange { today, week }

class ActivityTab extends StatefulWidget {
  const ActivityTab({super.key});

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  ActivityRange _range = ActivityRange.today;

  @override
  Widget build(BuildContext context) {
    final sessions = context.watch<SessionsProvider>();
    final tasks = context.watch<TaskProvider>();
    final list = _range == ActivityRange.today
        ? sessions.today
        : sessions.thisWeek;

    final totalSec =
        list.fold<int>(0, (acc, s) => acc + s.durationSeconds);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 12, AppSpacing.lg, 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Activité',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSunk,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 14, color: AppColors.accent),
                        const SizedBox(width: 6),
                        Text(
                          formatMinutes(totalSec ~/ 60),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                            letterSpacing: -0.13,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sous-titre
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 4, AppSpacing.lg, 0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${list.length} session${list.length > 1 ? 's' : ''} sur la période',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.13,
                  ),
                ),
              ),
            ),

            // Segmented today/week
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 18, AppSpacing.lg, 6),
              child: SegmentedTabs<ActivityRange>(
                value: _range,
                onChanged: (v) => setState(() => _range = v),
                options: const [
                  SegmentedOption(
                      value: ActivityRange.today, label: "Aujourd'hui"),
                  SegmentedOption(
                      value: ActivityRange.week, label: 'Cette semaine'),
                ],
              ),
            ),

            // Liste
            Expanded(
              child: SessionsList(
                sessions: list,
                taskProvider: tasks,
                emptyTitle: _range == ActivityRange.today
                    ? 'Pas encore de session aujourd\'hui.'
                    : 'Pas encore de session cette semaine.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
