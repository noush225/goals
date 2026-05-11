import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../data/task.dart';
import '../data/task_provider.dart';
import '../utils/time_format.dart';
import '../widgets/momentum_logo.dart';
import '../widgets/press_button.dart';
import '../widgets/segmented_tabs.dart';
import '../widgets/task_card.dart';
import 'add_task_sheet.dart';
import 'focus_screen.dart';
import 'settings_screen.dart';

enum HomeTab { today, week }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeTab _tab = HomeTab.today;

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>();
    final visible = _tab == HomeTab.today ? tasks.today : tasks.week;
    final dateLabel = _capitalize(
      DateFormat("EEEE d MMMM", 'fr_FR').format(DateTime.now()),
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Column(
            children: [
              // Header (titre + gear)
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const MomentumLogo(),
                        const SizedBox(width: 8),
                        Text(
                          'Momentum',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    PressButton(
                      semanticLabel: 'Réglages',
                      onTap: () => Navigator.of(context).push(
                        PageRouteBuilder(
                          opaque: false,
                          transitionDuration: const Duration(milliseconds: 320),
                          pageBuilder: (_, __, ___) => const SettingsScreen(),
                          transitionsBuilder: (_, anim, __, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: anim,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            );
                          },
                        ),
                      ),
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
                          Icons.settings_outlined,
                          size: 19,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Greeting + stat row
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 24, AppSpacing.lg, 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Que cette\njournée compte.',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 14),
                    _StatLine(
                      done: tasks.doneCount,
                      total: tasks.all.length,
                      minutes: tasks.totalMinutes,
                    ),
                  ],
                ),
              ),

              // Tabs
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 18, AppSpacing.lg, 14,
                ),
                child: SegmentedTabs<HomeTab>(
                  value: _tab,
                  onChanged: (v) => setState(() => _tab = v),
                  options: const [
                    SegmentedOption(value: HomeTab.today, label: "Aujourd'hui"),
                    SegmentedOption(value: HomeTab.week, label: 'Cette semaine'),
                  ],
                ),
              ),

              // Liste
              Expanded(
                child: visible.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg, 6, AppSpacing.lg, 140,
                        ),
                        itemCount: visible.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (_, i) => TaskCard(
                          task: visible[i],
                          onPlay: () => _openFocus(context, visible[i]),
                        ),
                      ),
              ),
            ],
          ),

          // FAB
          Positioned(
            right: 22,
            bottom: MediaQuery.of(context).padding.bottom + 24,
            child: PressButton(
              semanticLabel: 'Ajouter une tâche',
              onTap: () => _openAddSheet(context),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.inkShadow,
                      blurRadius: 28,
                      spreadRadius: -8,
                      offset: const Offset(0, 12),
                    ),
                    const BoxShadow(
                      color: Color(0x1F2D3A2E),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.add_rounded,
                    color: AppColors.surface, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x52141816),
      builder: (_) => const AddTaskSheet(),
    );
  }

  void _openFocus(BuildContext context, Task task) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (_, __, ___) => FocusScreen(task: task),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({
    required this.done,
    required this.total,
    required this.minutes,
  });

  final int done;
  final int total;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontSize: 13,
      color: AppColors.inkSoft,
      letterSpacing: -0.13,
    );
    final boldStyle = labelStyle.copyWith(
      color: AppColors.ink,
      fontWeight: FontWeight.w600,
    );

    return RichText(
      text: TextSpan(
        style: labelStyle,
        children: [
          TextSpan(text: '$done sur $total', style: boldStyle),
          const TextSpan(text: ' fait(e)s'),
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: 3,
                height: 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.muted,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          TextSpan(text: formatMinutes(minutes), style: boldStyle),
          const TextSpan(text: ' de concentration'),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
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
              child: const Icon(Icons.eco_outlined,
                  color: AppColors.accent, size: 26),
            ),
            const SizedBox(height: 16),
            Text(
              'Rien de prévu pour le moment.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              "Appuie sur + pour planter ta première tâche.",
              style: TextStyle(color: AppColors.muted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
