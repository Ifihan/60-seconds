import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum RecordButtonState { idle, recording, done }

class RecordButton extends StatefulWidget {
  final RecordButtonState state;
  final VoidCallback? onTap;

  const RecordButton({super.key, required this.state, this.onTap});

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.state) {
      case RecordButtonState.idle:
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.textMuted, width: 2),
            ),
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
        );

      case RecordButtonState.recording:
        return GestureDetector(
          onTap: widget.onTap,
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 2),
              ),
              child: Center(
                child: Container(
                  width: 32,
                  height: 32,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
        );

      case RecordButtonState.done:
        return Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              color: AppColors.border,
            ),
          ),
        );
    }
  }
}
