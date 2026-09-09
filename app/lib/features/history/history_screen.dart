import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/remote/models/session_dto.dart';
import '../../shared/widgets/accent_button.dart';
import 'history_viewmodel.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String? _filterAreaId;

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(historyProvider(_filterAreaId));

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Icons.chevron_left,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'HISTORY',
                    style: AppTypography.label(color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  sessionsAsync.when(
                    data: (r) => Text(
                      '${r.total} sessions',
                      style: AppTypography.label(),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            sessionsAsync.when(
              data: (result) {
                if (result.sessions.isEmpty && _filterAreaId == null) {
                  return const SizedBox.shrink();
                }
                final areas = result.sessions
                    .map((s) => (id: s.areaId, name: s.areaName))
                    .toSet()
                    .toList();
                return SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _Chip(
                        label: 'ALL',
                        active: _filterAreaId == null,
                        onTap: () => setState(() => _filterAreaId = null),
                      ),
                      ...areas.map(
                        (a) => _Chip(
                          label: a.name.toUpperCase(),
                          active: _filterAreaId == a.id,
                          onTap: () => setState(() => _filterAreaId = a.id),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: sessionsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                    strokeWidth: 2,
                  ),
                ),
                error: (_, __) => Center(
                  child: Text(
                    'Failed to load sessions.',
                    style: AppTypography.body(color: AppColors.textMuted),
                  ),
                ),
                data: (result) {
                  if (result.sessions.isEmpty) return _EmptyState();
                  return ListView.separated(
                    itemCount: result.sessions.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: AppColors.border, height: 1),
                    itemBuilder: (_, i) => _SessionRow(result.sessions[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        color: active ? AppColors.accent : AppColors.surface,
        child: Text(
          label,
          style: AppTypography.label(
            color: active ? AppColors.background : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final SessionDto session;
  const _SessionRow(this.session);

  @override
  Widget build(BuildContext context) {
    final dt = session.completedAtDate;
    final date = '${_mon(dt.month)} ${dt.day} · 1:00';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.topic,
                  style: AppTypography.headline(fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  '${session.areaName} · $date',
                  style: AppTypography.body(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            color: AppColors.surfaceAlt,
            child: Text(
              session.mode,
              style: AppTypography.label(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  String _mon(int m) => const [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m];
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
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Icon(Icons.history, color: AppColors.textMuted, size: 22),
            ),
          ),
          const SizedBox(height: 20),
          Text('No sessions yet.', style: AppTypography.display(fontSize: 28)),
          const SizedBox(height: 12),
          Text(
            'Finish a sixty-second drill and it lands here — topic, area, date, and format.',
            style: AppTypography.body(color: AppColors.textMuted),
          ),
          const SizedBox(height: 32),
          AccentButton(
            label: 'SPIN A TOPIC →',
            onTap: () => context.go('/spin/all'),
          ),
        ],
      ),
    );
  }
}
