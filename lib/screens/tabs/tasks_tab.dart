import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../data/settings_provider.dart';
import '../../data/task.dart';
import '../../data/task_provider.dart';
import '../../utils/time_format.dart';
import '../../widgets/momentum_logo.dart';
import '../../widgets/press_button.dart';
import '../../widgets/task_card.dart';
import '../add_task_sheet.dart';
import '../focus_screen.dart';
import '../settings_screen.dart';

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  bool _doneExpanded = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final settings = context.watch<SettingsProvider>();
    final firstName = settings.userName.split(' ').first.trim();
    final dateLabel = _capitalize(
      DateFormat("EEEE d MMMM", 'fr_FR').format(DateTime.now()),
    );

    final visibleActive = _query.isEmpty
        ? provider.activeRoots
        : provider.search(_query, onlyRoots: true)
            .where((t) => t.status == TaskStatus.active)
            .toList();

    final done = provider.doneRoots;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Header (titre + gear) — non-collapsing
              SliverToBoxAdapter(
                child: Padding(
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
                      _CircleIconButton(
                        icon: Icons.settings_outlined,
                        semantic: 'Réglages',
                        onTap: () => _openSettings(context),
                      ),
                    ],
                  ),
                ),
              ),

              // Greeting + stat row
              SliverToBoxAdapter(
                child: Padding(
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
                        firstName.isEmpty
                            ? 'Que cette\njournée compte.'
                            : 'Salut $firstName.\nQue cette journée compte.',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 14),
                      _StatLine(
                        done: provider.doneCount,
                        total: provider.all.length,
                        seconds: provider.totalSeconds,
                      ),
                    ],
                  ),
                ),
              ),

              // Search bar — révélée au pull-down (toujours dans le flow mais cachable)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 16, AppSpacing.lg, 6,
                  ),
                  child: _SearchField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              ),

              // Liste des tâches actives
              if (visibleActive.isEmpty && _query.isEmpty)
                const SliverToBoxAdapter(child: _EmptyState())
              else if (visibleActive.isEmpty)
                const SliverToBoxAdapter(child: _NoSearchResults())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 8, AppSpacing.lg, 12,
                  ),
                  sliver: SliverList.separated(
                    itemCount: visibleActive.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, i) => TaskCard(
                      task: visibleActive[i],
                      onPlay: () => _openFocus(context, visibleActive[i]),
                      onEdit: () => _openEditSheet(context, visibleActive[i]),
                    ),
                  ),
                ),

              // Section "Terminées récemment" repliable
              if (done.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, 12, AppSpacing.lg, 0,
                    ),
                    child: _DoneSection(
                      tasks: done,
                      expanded: _doneExpanded,
                      onToggle: () =>
                          setState(() => _doneExpanded = !_doneExpanded),
                      onPlay: (t) => _openFocus(context, t),
                      onEdit: (t) => _openEditSheet(context, t),
                      onReopen: (t) => context
                          .read<TaskProvider>()
                          .setStatus(t.id, TaskStatus.active),
                    ),
                  ),
                ),

              // Padding bas pour le FAB
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

          // FAB
          Positioned(
            right: 22,
            bottom: 24,
            child: PressButton(
              semanticLabel: 'Ajouter une tâche',
              onTap: () => _openEditSheet(context, null),
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

  Future<void> _openEditSheet(BuildContext context, Task? task) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x52141816),
      builder: (_) => AddTaskSheet(task: task),
    );
  }

  void _openFocus(BuildContext context, Task task) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (_, __, ___) => FocusScreen(task: task),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, __, ___) => const SettingsScreen(),
        transitionsBuilder: (_, anim, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.semantic,
    required this.onTap,
  });

  final IconData icon;
  final String semantic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressButton(
      semanticLabel: semantic,
      onTap: onTap,
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
        child: Icon(icon, size: 19, color: AppColors.inkSoft),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSunk,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(CupertinoIcons.search,
              size: 18, color: AppColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: AppColors.accent,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.ink,
                letterSpacing: -0.15,
              ),
              decoration: InputDecoration(
                hintText: 'Rechercher une tâche…',
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: AppColors.muted.withOpacity(0.9),
                  letterSpacing: -0.15,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            PressButton(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close_rounded,
                    size: 16, color: AppColors.muted),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({
    required this.done,
    required this.total,
    required this.seconds,
  });

  final int done;
  final int total;
  final int seconds;

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
          TextSpan(text: formatMinutes(seconds ~/ 60), style: boldStyle),
          const TextSpan(text: ' de concentration'),
        ],
      ),
    );
  }
}

class _DoneSection extends StatelessWidget {
  const _DoneSection({
    required this.tasks,
    required this.expanded,
    required this.onToggle,
    required this.onPlay,
    required this.onEdit,
    required this.onReopen,
  });

  final List<Task> tasks;
  final bool expanded;
  final VoidCallback onToggle;
  final void Function(Task) onPlay;
  final void Function(Task) onEdit;
  final void Function(Task) onReopen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PressButton(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    size: 18, color: AppColors.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    expanded
                        ? 'Masquer les terminées'
                        : '${tasks.length} terminée${tasks.length > 1 ? 's' : ''} récemment',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                      letterSpacing: -0.14,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.expand_more_rounded,
                      size: 20, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 240),
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(height: 0, width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                for (final t in tasks) ...[
                  _DoneCard(
                    task: t,
                    onPlay: () => onPlay(t),
                    onEdit: () => onEdit(t),
                    onReopen: () => onReopen(t),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DoneCard extends StatelessWidget {
  const _DoneCard({
    required this.task,
    required this.onPlay,
    required this.onEdit,
    required this.onReopen,
  });

  final Task task;
  final VoidCallback onPlay;
  final VoidCallback onEdit;
  final VoidCallback onReopen;

  @override
  Widget build(BuildContext context) {
    return PressButton(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.hairline),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                size: 18, color: AppColors.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  color: AppColors.inkSoft,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.14,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppColors.muted,
                ),
              ),
            ),
            PressButton(
              onTap: onReopen,
              semanticLabel: 'Réactiver',
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.replay_rounded,
                    size: 18, color: AppColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Center(
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
              'Rien dans ton backlog.',
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

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Center(
        child: Text(
          'Aucune tâche ne correspond.',
          style: TextStyle(
            fontSize: 13.5,
            color: AppColors.muted,
            letterSpacing: -0.14,
          ),
        ),
      ),
    );
  }
}
