import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/remote/models/area_dto.dart';
import '../../shared/widgets/accent_button.dart';
import '../../shared/widgets/logo_mark.dart';
import '../../shared/widgets/section_label.dart';
import '../auth/auth_notifier.dart';
import '../session/session_notifier.dart';
import 'home_viewmodel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final areasAsync = ref.watch(homeAreasProvider);
    final session = ref.read(sessionProvider.notifier);

    final loadedAreas = areasAsync.valueOrNull;
    final isEmptyState = auth.isAuthenticated &&
        loadedAreas != null &&
        loadedAreas.where((a) => a.isOwn || a.isSubscribed).isEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Row(
                    children: [
                      const LogoMark(size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '60·SECONDS',
                        style: AppTypography.label(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (auth.isAuthenticated)
                    GestureDetector(
                      onTap: () => context.push('/history'),
                      child: Text('HISTORY', style: AppTypography.label()),
                    ),
                ],
              ),
            ),

            Expanded(
              child: areasAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                    strokeWidth: 2,
                  ),
                ),
                error: (_, __) => _ErrorState(
                  onRetry: () => ref.invalidate(homeAreasProvider),
                ),
                data: (areas) {
                  // Areas has no "type" concept anymore (dropped from the
                  // backend) — one flat list per the current web app, not a
                  // Known/Learning split.
                  final displayAreas = auth.isAuthenticated
                      ? areas.where((a) => a.isOwn || a.isSubscribed).toList()
                      : areas.where((a) => !a.isOwn).toList();

                  final totalTopics =
                      displayAreas.fold(0, (s, a) => s + a.topicCount);
                  final areaCount = displayAreas.length;

                  if (auth.isAuthenticated && displayAreas.isEmpty) {
                    return _EmptyState();
                  }

                  return ListView(
                    children: [
                      // Stats + hero
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: Text(
                          '$areaCount AREAS · $totalTopics TOPICS',
                          style: AppTypography.label(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                        child: Text(
                          'Spin a\ntopic.',
                          style: AppTypography.display(fontSize: 42),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: AccentButton(
                          label: 'SPIN →',
                          onTap: () {
                            session.resetSession();
                            context.push('/spin/all');
                          },
                        ),
                      ),
                      if (displayAreas.isNotEmpty) ...[
                        SectionLabel(
                          text: auth.isAuthenticated
                              ? 'YOUR AREAS'
                              : 'AVAILABLE AREAS',
                        ),
                        ...displayAreas.map(
                          (a) => _AreaRow(
                            area: a,
                            onTap: () {
                              session.resetSession();
                              session.setSelectedArea(a);
                              context.push('/spin/${a.id}');
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  );
                },
              ),
            ),

            // Bottom bar — hidden in the empty state, which already carries
            // its own "browse" and "create" actions (mirrors the web app).
            if (!isEmptyState)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: auth.isAuthenticated
                    ? AccentButton(
                        label: '+ ADD AREA',
                        onTap: () => context.push('/add-area'),
                      )
                    : Column(
                        children: [
                          AccentButton(
                            label: '+ ADD AREA',
                            onTap: () => context.push('/signup'),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => context.push('/login'),
                            child: Text(
                              'Already have an account? Sign in',
                              style: AppTypography.body(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AreaRow extends StatelessWidget {
  final AreaDto area;
  final VoidCallback onTap;

  const _AreaRow({required this.area, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                area.name,
                style: AppTypography.headline(fontSize: 16),
              ),
            ),
            Text(
              '${area.topicCount} topics',
              style: AppTypography.body(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '↺ SPIN',
              style: AppTypography.label(color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No areas yet.', style: AppTypography.display(fontSize: 32)),
          const SizedBox(height: 12),
          Text(
            'Subscribe to a global area or create your own with custom topics.',
            style: AppTypography.body(color: AppColors.textMuted),
          ),
          const Spacer(),
          AccentButton(
            label: 'BROWSE & SUBSCRIBE →',
            onTap: () => context.push('/areas'),
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () => context.push('/add-area'),
              child: Text(
                'Create your own',
                style: AppTypography.label(color: AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Couldn't load areas.",
            style: AppTypography.body(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              'Retry →',
              style: AppTypography.body(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}
