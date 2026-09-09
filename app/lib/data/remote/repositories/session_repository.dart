import 'package:dio/dio.dart';
import '../models/session_dto.dart';

class SessionsResult {
  final List<SessionDto> sessions;
  final int total;
  const SessionsResult({required this.sessions, required this.total});
}

class SessionRepository {
  final Dio _dio;
  const SessionRepository(this._dio);

  Future<SessionDto> logSession({
    required String areaId,
    required String topic,
    required String mode,
    required DateTime completedAt,
  }) async {
    final res = await _dio.post('/sessions', data: {
      'area_id': areaId,
      'topic': topic,
      'mode': mode,
      'completed_at': completedAt.toIso8601String(),
    });
    return SessionDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<SessionDto> analyzeSession({
    required String sessionId,
    required String audioFilePath,
  }) async {
    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(audioFilePath, filename: 'clip.m4a'),
    });
    final res = await _dio.post('/sessions/$sessionId/analyze', data: formData);
    return SessionDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<SessionsResult> getSessions({String? areaId, int page = 1, int limit = 20}) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (areaId != null) params['area_id'] = areaId;
    final res = await _dio.get('/sessions', queryParameters: params);
    final body = res.data as Map<String, dynamic>;
    final list = body['data'] as List<dynamic>;
    final pagination = body['pagination'] as Map<String, dynamic>;
    return SessionsResult(
      sessions: list.map((e) => SessionDto.fromJson(e as Map<String, dynamic>)).toList(),
      total: pagination['total'] as int,
    );
  }
}
