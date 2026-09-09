import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/remote/models/topic_dto.dart';
import '../../shared/widgets/accent_button.dart';
import '../../shared/widgets/loop_header.dart';
import '../session/session_notifier.dart';
import 'spin_viewmodel.dart';

class SpinScreen extends ConsumerStatefulWidget {
  final String areaId;
  const SpinScreen({super.key, required this.areaId});

  @override
  ConsumerState<SpinScreen> createState() => _SpinScreenState();
}

class _SpinScreenState extends ConsumerState<SpinScreen> {
  late FixedExtentScrollController _scrollCtrl;
  bool _animating = false;
  bool _hasSpun = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = FixedExtentScrollController();
    // Covers the case where topics are already cached and resolve
    // synchronously — the ref.listen below (in build) covers the normal
    // case where the fetch is still in flight on this first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoSpin());
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _autoSpin([List<TopicDto>? loadedTopics]) {
    if (_hasSpun) return;
    final topics =
        loadedTopics ?? ref.read(spinTopicsProvider(widget.areaId)).valueOrNull;
    if (topics != null && topics.isNotEmpty) {
      _hasSpun = true;
      ref.read(spinNotifierProvider.notifier).spin(topics);
      _animate();
    }
  }

  void _animate() {
    if (_animating) return;
    _animating = true;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      _scrollCtrl
          .animateToItem(
            19,
            duration: const Duration(milliseconds: 2200),
            curve: Curves.decelerate,
          )
          .then((_) => _animating = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final topicsAsync = ref.watch(spinTopicsProvider(widget.areaId));
    final areaAsync = ref.watch(spinAreaProvider(widget.areaId));
    final spinState = ref.watch(spinNotifierProvider);

    // Topics load asynchronously — the very first frame (where initState's
    // post-frame callback fires) almost never has them ready yet. This is
    // what actually triggers the spin once the fetch completes.
    ref.listen<AsyncValue<List<TopicDto>>>(
      spinTopicsProvider(widget.areaId),
      (previous, next) => next.whenData(_autoSpin),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LoopHeader(step: 1, label: 'SPIN', onBack: () => context.go('/')),

            if (spinState.spinning)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  'SELECTING…',
                  style: AppTypography.label(color: AppColors.accent),
                ),
              ),

            if (!spinState.spinning && spinState.winner != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  'YOUR TOPIC',
                  style: AppTypography.label(color: AppColors.accent),
                ),
              ),

            Expanded(
              child: topicsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                    strokeWidth: 2,
                  ),
                ),
                error: (_, __) => Center(
                  child: Text(
                    'Failed to load topics.',
                    style: AppTypography.body(color: AppColors.textMuted),
                  ),
                ),
                data: (topics) {
                  final reel = spinState.reelItems.isEmpty
                      ? topics
                      : spinState.reelItems;
                  if (reel.isEmpty) {
                    return Center(
                      child: Text(
                        'No topics in this area.',
                        style: AppTypography.body(color: AppColors.textMuted),
                      ),
                    );
                  }
                  return ListWheelScrollView.useDelegate(
                    controller: _scrollCtrl,
                    physics: const NeverScrollableScrollPhysics(),
                    itemExtent: 64,
                    perspective: 0.003,
                    diameterRatio: 2.5,
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        if (index < 0 || index >= reel.length) return null;
                        final distance = (index - spinState.landIndex).abs();
                        final opacity = distance == 0
                            ? 1.0
                            : distance == 1
                                ? 0.5
                                : 0.25;
                        final fontSize = distance == 0
                            ? 28.0
                            : distance == 1
                                ? 18.0
                                : 14.0;
                        return Center(
                          child: Opacity(
                            opacity: opacity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                reel[index].name,
                                style: AppTypography.headline(
                                  fontSize: fontSize,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: reel.length,
                    ),
                  );
                },
              ),
            ),

            // Area badge + actions
            if (!spinState.spinning && spinState.winner != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: areaAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (area) => Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: AppColors.surfaceAlt,
                        child: Text(
                          area?.abbreviation ?? '??',
                          style: AppTypography.mono(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        area?.name ?? 'All Areas',
                        style: AppTypography.body(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: AccentButton(
                  label: 'START PREP →',
                  onTap: () {
                    final winner = spinState.winner!;
                    // Look up the area the *winning topic* actually belongs to,
                    // not widget.areaId — that's literally "all" when spinning
                    // across every area, which never matches a real area.
                    final area =
                        ref.read(spinAreaProvider(winner.areaId)).valueOrNull;
                    ref
                        .read(sessionProvider.notifier)
                        .setCurrentTopic(winner.name);
                    if (area != null) {
                      ref.read(sessionProvider.notifier).setSelectedArea(area);
                    }
                    context.go('/prep');
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: GestureDetector(
                  onTap: () {
                    final topics = ref
                            .read(spinTopicsProvider(widget.areaId))
                            .valueOrNull ??
                        [];
                    _scrollCtrl.jumpToItem(0);
                    ref.read(spinNotifierProvider.notifier).respin(topics);
                    _animate();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.refresh,
                        color: AppColors.textMuted,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text('RE-SPIN', style: AppTypography.label()),
                    ],
                  ),
                ),
              ),
            ] else if (spinState.spinning) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: topicsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (topics) => Text(
                    '${widget.areaId == "all" ? "All areas" : ""} · ${topics.length} topics',
                    style: AppTypography.label(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
