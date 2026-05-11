import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Segmented control style iOS sur fond enfoncé.
/// Anime le pill blanc entre les deux options.
class SegmentedTabs<T> extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final T value;
  final List<SegmentedOption<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    assert(options.length == 2, 'SegmentedTabs supporte 2 options pour le MVP.');
    final selectedIndex = options.indexWhere((o) => o.value == value);

    return LayoutBuilder(
      builder: (context, c) {
        const padding = 4.0;
        final pillWidth = (c.maxWidth - padding * 2) / options.length;

        return Container(
          height: 44,
          padding: const EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: AppColors.surfaceSunk,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                left: selectedIndex * pillWidth,
                top: 0,
                bottom: 0,
                width: pillWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F2D3A2E),
                        blurRadius: 6,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (final opt in options)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(opt.value),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.14,
                              color: opt.value == value ? AppColors.ink : AppColors.muted,
                              fontFamily: DefaultTextStyle.of(context).style.fontFamily,
                            ),
                            child: Text(opt.label),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class SegmentedOption<T> {
  const SegmentedOption({required this.value, required this.label});
  final T value;
  final String label;
}
