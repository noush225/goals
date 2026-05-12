import 'package:flutter/material.dart';

import '../widgets/momentum_bottom_nav.dart';
import 'tabs/activity_tab.dart';
import 'tabs/journal_tab.dart';
import 'tabs/tasks_tab.dart';

/// Écran racine avec le bottom nav.
/// Préserve l'état de chaque tab via [IndexedStack].
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  static const _items = <MomentumNavItem>[
    MomentumNavItem(
      icon: Icons.checklist_rounded,
      activeIcon: Icons.checklist_rtl_rounded,
      label: 'Mes tâches',
    ),
    MomentumNavItem(
      icon: Icons.bar_chart_rounded,
      activeIcon: Icons.show_chart_rounded,
      label: 'Activité',
    ),
    MomentumNavItem(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      label: 'Journal',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: IndexedStack(
        index: _index,
        children: const [
          TasksTab(),
          ActivityTab(),
          JournalTab(),
        ],
      ),
      bottomNavigationBar: MomentumBottomNav(
        currentIndex: _index,
        onChanged: (i) => setState(() => _index = i),
        items: _items,
      ),
    );
  }
}
