import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Petit logo Momentum : carré sage + point central, à côté du wordmark.
class MomentumLogo extends StatelessWidget {
  const MomentumLogo({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Container(
        width: size * 0.27,
        height: size * 0.27,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
