import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/remote/models/area_dto.dart';
import '../auth/auth_notifier.dart';
import 'areas_viewmodel.dart';

class AreasScreen extends ConsumerStatefulWidget {
  const AreasScreen({super.key});

  @override
  ConsumerState<AreasScreen> createState() => _AreasScreenState();
}

class _AreasScreenState extends ConsumerState<AreasScreen> {
  String _filter = 'all'; // all | subscribed | mine

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final areasAsync = ref.watch(allAreasProvider);

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
                    'AREAS',
                    style: AppTypography.label(color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  if (auth.isAuthenticated)
                    GestureDetector(
                      onTap: () => context.push('/add-area'),
                      child: Text(
                        '+ NEW',
                        style: AppTypography.label(color: AppColors.accent),
                      ),
                    ),
                ],
              ),
            ),
            if (auth.isAuthenticated) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _FilterChip(
                      label: 'ALL',
                      active: _filter == 'all',
                      onTap: () => setState(() => _filter = 'all'),
                    ),
                    _FilterChip(
                      label: 'SUBSCRIBED',
                      active: _filter == 'subscribed',
                      onTap: () => setState(() => _filter = 'subscribed'),
                    ),
                    _FilterChip(
                      label: 'MINE',
                      active: _filter == 'mine',
                      onTap: () => setState(() => _filter = 'mine'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: areasAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                    strokeWidth: 2,
                  ),
                ),
                error: (_, __) => Center(
                  child: Text(
                    'Failed to load areas.',
                    style: AppTypography.body(color: AppColors.textMuted),
                  ),
                ),
                data: (areas) {
                  final filtered = _applyFilter(
                    areas,
                    _filter,
                    auth.isAuthenticated,
                  );
                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: AppColors.border, height: 1),
                    itemBuilder: (_, i) => _AreaCard(
                      area: filtered[i],
                      isAuth: auth.isAuthenticated,
                      onSpin: () => context.push('/spin/${filtered[i].id}'),
                      onToggle: () => ref
                          .read(areasNotifierProvider.notifier)
                          .toggleSubscription(filtered[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<AreaDto> _applyFilter(List<AreaDto> areas, String filter, bool isAuth) {
    if (!isAuth) return areas;
    switch (filter) {
      case 'subscribed':
        return areas.where((a) => a.isSubscribed && !a.isOwn).toList();
      case 'mine':
        return areas.where((a) => a.isOwn).toList();
      default:
        return areas;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

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

class _AreaCard extends StatelessWidget {
  final AreaDto area;
  final bool isAuth;
  final VoidCallback onSpin;
  final VoidCallback onToggle;
  const _AreaCard({
    required this.area,
    required this.isAuth,
    required this.onSpin,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(area.name, style: AppTypography.headline(fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  '${area.topicCount} topics',
                  style: AppTypography.body(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (area.isOwn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              color: AppColors.surfaceAlt,
              child: Text(
                'MINE',
                style: AppTypography.label(color: AppColors.accent),
              ),
            )
          else if (isAuth)
            GestureDetector(
              onTap: onToggle,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                color: area.isSubscribed
                    ? AppColors.surfaceAlt
                    : AppColors.accent,
                child: Text(
                  area.isSubscribed ? 'SUBSCRIBED' : '+ ADD',
                  style: AppTypography.label(
                    color: area.isSubscribed
                        ? AppColors.textMuted
                        : AppColors.background,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSpin,
            child: Text(
              '↺ SPIN',
              style: AppTypography.label(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}
