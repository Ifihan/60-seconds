class TopicDto {
  final String id;
  final String name;
  final String areaId;

  const TopicDto({
    required this.id,
    required this.name,
    required this.areaId,
  });

  // The backend's TopicOut response has no area_id field (just id, name,
  // created_at) — the caller already knows which area it asked for, so it's
  // passed in explicitly rather than parsed from JSON.
  factory TopicDto.fromJson(Map<String, dynamic> json, {required String areaId}) =>
      TopicDto(
        id: json['id'] as String,
        name: json['name'] as String,
        areaId: areaId,
      );
}
