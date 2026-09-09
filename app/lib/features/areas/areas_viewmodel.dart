import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/models/area_dto.dart';
import '../../data/remote/repositories/area_repository.dart';
import '../spin/spin_viewmodel.dart';

final allAreasProvider = FutureProvider<List<AreaDto>>((ref) {
  final repo = ref.watch(areaRepoProvider);
  return repo.getAreas();
});

class AreasNotifier extends StateNotifier<Set<String>> {
  final AreaRepository _repo;
  final Ref _ref;

  AreasNotifier(this._repo, this._ref) : super({});

  Future<void> toggleSubscription(AreaDto area) async {
    if (_busy(area.id)) return;
    state = {...state, area.id};
    try {
      if (area.isSubscribed) {
        await _repo.unsubscribeArea(area.id);
      } else {
        await _repo.subscribeArea(area.id);
      }
      _ref.invalidate(allAreasProvider);
    } finally {
      state = state.difference({area.id});
    }
  }

  bool _busy(String id) => state.contains(id);
}

final areasNotifierProvider =
    StateNotifierProvider<AreasNotifier, Set<String>>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
