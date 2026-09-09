import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';

class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(text.toUpperCase(), style: AppTypography.label()),
    );
  }
}
