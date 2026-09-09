import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/timer_utils.dart';

class TimerDisplay extends StatelessWidget {
  final int seconds;
  final double fontSize;

  const TimerDisplay({super.key, required this.seconds, this.fontSize = 96});

  @override
  Widget build(BuildContext context) {
    return Text(
      formatTime(seconds),
      style: AppTypography.timer(fontSize: fontSize),
    );
  }
}
