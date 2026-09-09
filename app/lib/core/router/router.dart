import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_notifier.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/spin/spin_screen.dart';
import '../../features/prep/prep_screen.dart';
import '../../features/record/record_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/areas/areas_screen.dart';
import '../../features/add_area/add_area_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final gatedRoutes = ['/history', '/add-area'];
      final isGated = gatedRoutes.any(
        (r) => state.matchedLocation.startsWith(r),
      );
      if (!isAuth && isGated) {
        return '/login?returnTo=${state.matchedLocation}';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/spin/:areaId',
        builder: (_, state) =>
            SpinScreen(areaId: state.pathParameters['areaId']!),
      ),
      GoRoute(path: '/prep', builder: (_, __) => const PrepScreen()),
      GoRoute(path: '/record', builder: (_, __) => const RecordScreen()),
      GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
      GoRoute(path: '/areas', builder: (_, __) => const AreasScreen()),
      GoRoute(path: '/add-area', builder: (_, __) => const AddAreaScreen()),
      GoRoute(
        path: '/login',
        builder: (_, state) {
          final returnTo = state.uri.queryParameters['returnTo'];
          return LoginScreen(returnTo: returnTo);
        },
      ),
      GoRoute(
        path: '/signup',
        builder: (_, state) {
          final returnTo = state.uri.queryParameters['returnTo'];
          return SignupScreen(returnTo: returnTo);
        },
      ),
    ],
    errorBuilder: (_, __) =>
        const Scaffold(body: Center(child: Text('Page not found'))),
  );
});
