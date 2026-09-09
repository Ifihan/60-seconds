import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/loop_header.dart';
import '../../shared/widgets/timer_display.dart';
import '../session/session_notifier.dart';

class PrepScreen extends ConsumerStatefulWidget {
  const PrepScreen({super.key});

  @override
  ConsumerState<PrepScreen> createState() => _PrepScreenState();
}

class _PrepScreenState extends ConsumerState<PrepScreen> {
  Timer? _timer;
  final _notesCtrl = TextEditingController();
  bool _flashing = false;

  @override
  void initState() {
    super.initState();
    _notesCtrl.text = ref.read(sessionProvider).prepNotes;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = ref.read(sessionProvider).prepTimeRemaining;
      if (s <= 0) {
        _timer?.cancel();
        _goToRecord();
      } else {
        ref.read(sessionProvider.notifier).setPrepTimeRemaining(s - 1);
      }
    });
  }

  Future<void> _goToRecord() async {
    setState(() => _flashing = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() => _flashing = false);
    context.go('/record');
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final topic = session.currentTopic ?? '';
    final area = session.selectedArea;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      color: _flashing ? AppColors.accent : AppColors.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LoopHeader(step: 2, label: 'PREP'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (area != null)
                        Text(
                          '${area.abbreviation} · ${area.name.toUpperCase()}',
                          style: AppTypography.label(),
                        ),
                      const SizedBox(height: 8),
                      Text(topic, style: AppTypography.headline(fontSize: 22)),
                      const SizedBox(height: 24),
                      TimerDisplay(seconds: session.prepTimeRemaining),
                      const SizedBox(height: 4),
                      Text('PREP · 5 MINUTES', style: AppTypography.label()),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                          ),
                          padding: const EdgeInsets.all(14),
                          child: TextField(
                            controller: _notesCtrl,
                            onChanged: (v) =>
                                ref.read(sessionProvider.notifier).setPrepNotes(v),
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: AppTypography.mono(fontSize: 14),
                            decoration: InputDecoration.collapsed(
                              hintText: 'Your notes...',
                              hintStyle: AppTypography.mono(
                                  fontSize: 14, color: AppColors.textMuted),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: GestureDetector(
                  onTap: () {
                    _timer?.cancel();
                    context.go('/record');
                  },
                  child: Text('SKIP TO RECORD →', style: AppTypography.label(color: AppColors.textMuted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
