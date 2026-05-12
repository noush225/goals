import 'package:flutter/material.dart';

import '../app/theme.dart';
import 'press_button.dart';

/// Bottom nav custom au thème Sage.
/// Pill doux sur l'item actif, icônes line, fond surface, hairline en haut.
class MomentumBottomNav extends StatelessWidget {
  const MomentumBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;
  final List<MomentumNavItem> items;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + bottomPad),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: _NavTab(
                item: items[i],
                selected: currentIndex == i,
                onTap: () => onChanged(i),
              ),
            ),
        ],
      ),
    );
  }
}

class MomentumNavItem {
  const MomentumNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final MomentumNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressButton(
      onTap: onTap,
      semanticLabel: item.label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceSunk : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              size: 22,
              color: selected ? AppColors.accent : AppColors.muted,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: -0.05,
                color: selected ? AppColors.ink : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
