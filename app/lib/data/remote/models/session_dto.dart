class SessionDto {
  final String id;
  final String areaId;
  final String areaName;
  final String topic;
  final String mode;
  final String completedAt;
  final String? transcript;
  final int? fillerWordCount;
  final int? wordsPerMinute;
  final int? coherenceScore;
  final int? grammarScore;
  final int? contentAccuracyScore;
  final String? feedbackSummary;
  final String? analyzedAt;

  const SessionDto({
    required this.id,
    required this.areaId,
    required this.areaName,
    required this.topic,
    required this.mode,
    required this.completedAt,
    this.transcript,
    this.fillerWordCount,
    this.wordsPerMinute,
    this.coherenceScore,
    this.grammarScore,
    this.contentAccuracyScore,
    this.feedbackSummary,
    this.analyzedAt,
  });

  factory SessionDto.fromJson(Map<String, dynamic> json) => SessionDto(
        id: json['id'] as String,
        areaId: json['area_id'] as String,
        areaName: json['area_name'] as String? ?? '',
        topic: json['topic'] as String,
        mode: json['mode'] as String,
        completedAt: json['completed_at'] as String,
        transcript: json['transcript'] as String?,
        fillerWordCount: json['filler_word_count'] as int?,
        wordsPerMinute: json['words_per_minute'] as int?,
        coherenceScore: json['coherence_score'] as int?,
        grammarScore: json['grammar_score'] as int?,
        contentAccuracyScore: json['content_accuracy_score'] as int?,
        feedbackSummary: json['feedback_summary'] as String?,
        analyzedAt: json['analyzed_at'] as String?,
      );

  DateTime get completedAtDate => DateTime.tryParse(completedAt) ?? DateTime.now();
}
