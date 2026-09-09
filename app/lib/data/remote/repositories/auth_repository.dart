import 'package:dio/dio.dart';
import '../models/user_dto.dart';

class AuthResult {
  final String token;
  final UserDto user;
  const AuthResult({required this.token, required this.user});
}

class AuthRepository {
  final Dio _dio;
  const AuthRepository(this._dio);

  Future<AuthResult> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    return AuthResult(
      token: res.data['token'] as String,
      user: UserDto.fromJson(res.data['user'] as Map<String, dynamic>),
    );
  }

  Future<AuthResult> signup(String email, String password) async {
    final res = await _dio.post('/auth/signup', data: {'email': email, 'password': password});
    return AuthResult(
      token: res.data['token'] as String,
      user: UserDto.fromJson(res.data['user'] as Map<String, dynamic>),
    );
  }
}
