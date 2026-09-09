import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/models/area_dto.dart';
import '../../data/remote/models/topic_dto.dart';
import '../../data/remote/repositories/area_repository.dart';

final areaRepoProvider = Provider<AreaRepository>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

final spinTopicsProvider =
    FutureProvider.family<List<TopicDto>, String>((ref, areaId) async {
  final repo = ref.watch(areaRepoProvider);
  if (areaId == 'all') {
    final areas = await repo.getAreas();
    final futures = areas.map((a) => repo.getTopics(a.id));
    final results = await Future.wait(futures);
    return results.expand((t) => t).toList();
  }
  return repo.getTopics(areaId);
});

final spinAreaProvider =
    FutureProvider.family<AreaDto?, String>((ref, areaId) async {
  if (areaId == 'all') return null;
  final repo = ref.watch(areaRepoProvider);
  final areas = await repo.getAreas();
  return areas.firstWhere((a) => a.id == areaId,
      orElse: () => AreaDto(
          id: areaId,
          name: 'Unknown',
          topicCount: 0,
          isSubscribed: false,
          isOwn: false,
          createdAt: ''));
});

class SpinState {
  final bool spinning;
  final TopicDto? winner;
  final List<TopicDto> reelItems;
  final int landIndex;

  const SpinState({
    this.spinning = false,
    this.winner,
    this.reelItems = const [],
    this.landIndex = 0,
  });

  bool get hasResult => !spinning && winner != null;
}

class SpinNotifier extends StateNotifier<SpinState> {
  SpinNotifier() : super(const SpinState());

  void spin(List<TopicDto> topics) {
    if (topics.isEmpty) return;
    final rng = Random();
    final selected = topics[rng.nextInt(topics.length)];

    // Build a reel: 20 random topics ending on the selected one
    final reel = List.generate(19, (_) => topics[rng.nextInt(topics.length)])
      ..add(selected);

    state = SpinState(spinning: true, reelItems: reel, landIndex: 19);

    Future.delayed(const Duration(milliseconds: 2400), () {
      state = SpinState(
          spinning: false, winner: selected, reelItems: reel, landIndex: 19);
    });
  }

  void respin(List<TopicDto> topics) => spin(topics);
}

final spinNotifierProvider =
    StateNotifierProvider.autoDispose<SpinNotifier, SpinState>(
        (_) => SpinNotifier());
