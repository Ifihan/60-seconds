import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'logo_mark.dart';

class LoopHeader extends StatelessWidget {
  final int step;
  final String label;
  final VoidCallback? onBack;

  const LoopHeader({
    super.key,
    required this.step,
    required this.label,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack ?? () => context.pop(),
            child: const Icon(Icons.chevron_left,
                color: AppColors.textMuted, size: 20),
          ),
          const SizedBox(width: 12),
          const LogoMark(size: 18),
          const SizedBox(width: 6),
          Text('60·SECONDS',
              style: AppTypography.label(color: AppColors.textPrimary)),
          const Spacer(),
          Row(
            children: List.generate(4, (i) {
              final filled = i < step;
              return Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? AppColors.accent : AppColors.border,
                ),
              );
            }),
          ),
          const SizedBox(width: 8),
          Text(
            '${step.toString().padLeft(2, '0')} / 04 · $label',
            style: AppTypography.label(),
          ),
        ],
      ),
    );
  }
}
