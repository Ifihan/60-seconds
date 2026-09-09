import 'package:dio/dio.dart';
import '../models/area_dto.dart';
import '../models/topic_dto.dart';

class AreaRepository {
  final Dio _dio;
  const AreaRepository(this._dio);

  Future<List<AreaDto>> getAreas() async {
    final res = await _dio.get('/areas');
    final list = res.data as List<dynamic>;
    return list.map((e) => AreaDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<TopicDto>> getTopics(String areaId) async {
    final res = await _dio.get('/areas/$areaId/topics');
    final list = res.data as List<dynamic>;
    return list
        .map((e) => TopicDto.fromJson(e as Map<String, dynamic>, areaId: areaId))
        .toList();
  }

  Future<void> subscribeArea(String areaId) async {
    await _dio.post('/areas/$areaId/subscribe');
  }

  Future<void> unsubscribeArea(String areaId) async {
    await _dio.delete('/areas/$areaId/subscribe');
  }

  // The backend's AreaCreate only accepts `name` — there's no area "type"
  // concept anymore, and topics can't be set inline. Topics are added with a
  // separate bulk call once the area exists.
  Future<AreaDto> createArea(String name, List<String> topics) async {
    final res = await _dio.post('/areas', data: {'name': name});
    final area = AreaDto.fromJson(res.data as Map<String, dynamic>);

    if (topics.isNotEmpty) {
      await _dio.post('/areas/${area.id}/topics', data: {'names': topics});
    }

    return area;
  }

  Future<void> deleteArea(String areaId) async {
    await _dio.delete('/areas/$areaId');
  }
}
