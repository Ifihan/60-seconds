class AreaDto {
  final String id;
  final String name;
  final int topicCount;
  final bool isSubscribed;
  final bool isOwn;
  final String createdAt;

  const AreaDto({
    required this.id,
    required this.name,
    required this.topicCount,
    required this.isSubscribed,
    required this.isOwn,
    required this.createdAt,
  });

  factory AreaDto.fromJson(Map<String, dynamic> json) => AreaDto(
        id: json['id'] as String,
        name: json['name'] as String,
        topicCount: json['topic_count'] as int,
        isSubscribed: json['is_subscribed'] as bool? ?? false,
        isOwn: json['is_own'] as bool? ?? false,
        createdAt: json['created_at'] as String? ?? '',
      );

  String get abbreviation {
    final words = name.split(' ');
    if (words.length == 1) return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
    return words.take(2).map((w) => w[0]).join().toUpperCase();
  }
}
