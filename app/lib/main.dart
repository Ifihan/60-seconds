import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'data/remote/api_client.dart';
import 'data/remote/repositories/auth_repository.dart';
import 'data/remote/repositories/area_repository.dart';
import 'data/remote/repositories/session_repository.dart';
import 'features/auth/auth_notifier.dart';
import 'features/areas/areas_viewmodel.dart';
import 'features/record/record_screen.dart';
import 'features/spin/spin_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final dio = createDio(prefs);

  final authRepo = AuthRepository(dio);
  final areaRepo = AreaRepository(dio);
  final sessionRepo = SessionRepository(dio);

  runApp(
    ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) => AuthNotifier(authRepo, prefs)),
        areaRepoProvider.overrideWithValue(areaRepo),
        sessionRepoProvider.overrideWithValue(sessionRepo),
        areasNotifierProvider.overrideWith(
          (ref) => AreasNotifier(areaRepo, ref),
        ),
      ],
      child: const SixtySecondsApp(),
    ),
  );
}
