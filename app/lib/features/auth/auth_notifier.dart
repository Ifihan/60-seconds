import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/remote/repositories/auth_repository.dart';
import '../../data/remote/models/user_dto.dart';

class AuthState {
  final UserDto? user;
  final String? token;
  final bool loading;
  final String? error;

  const AuthState({
    this.user,
    this.token,
    this.loading = false,
    this.error,
  });

  bool get isAuthenticated => token != null;

  AuthState copyWith({
    UserDto? user,
    String? token,
    bool? loading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        token: clearUser ? null : (token ?? this.token),
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final SharedPreferences _prefs;

  AuthNotifier(this._repo, this._prefs) : super(const AuthState()) {
    _restore();
  }

  void _restore() {
    final token = _prefs.getString('token');
    if (token != null) {
      state = state.copyWith(token: token);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final result = await _repo.login(email, password);
      await _prefs.setString('token', result.token);
      state = AuthState(user: result.user, token: result.token);
    } on Exception catch (e) {
      state = state.copyWith(loading: false, error: _message(e));
    }
  }

  Future<void> signup(String email, String password) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final result = await _repo.signup(email, password);
      await _prefs.setString('token', result.token);
      state = AuthState(user: result.user, token: result.token);
    } on Exception catch (e) {
      state = state.copyWith(loading: false, error: _message(e));
    }
  }

  Future<void> logout() async {
    await _prefs.remove('token');
    state = const AuthState();
  }

  String _message(Exception e) {
    final str = e.toString();
    if (str.contains('401') || str.contains('Unauthorized')) return 'Incorrect email or password.';
    if (str.contains('409') || str.contains('Conflict')) return 'An account with this email already exists.';
    if (str.contains('SocketException') || str.contains('network')) return 'No internet connection.';
    return 'Something went wrong. Please try again.';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
