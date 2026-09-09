import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/repositories/session_repository.dart';
import '../record/record_screen.dart';

final historyProvider =
    FutureProvider.family<SessionsResult, String?>((ref, areaId) async {
  final repo = ref.watch(sessionRepoProvider);
  return repo.getSessions(areaId: areaId);
});
