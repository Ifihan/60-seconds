import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/models/area_dto.dart';
import '../auth/auth_notifier.dart';
import '../spin/spin_viewmodel.dart';

final homeAreasProvider = FutureProvider<List<AreaDto>>((ref) async {
  final repo = ref.watch(areaRepoProvider);
  ref.watch(authProvider); // re-fetch when auth changes
  return repo.getAreas();
});
