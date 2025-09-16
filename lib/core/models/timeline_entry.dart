import 'package:cloud_firestore/cloud_firestore.dart';

import 'emotion_type.dart';

class TimelineEntry {
  const TimelineEntry({
    required this.id,
    required this.timestamp,
    required this.emotion,
    this.message,
    required this.userId,
  });

  final String id;
  final DateTime timestamp;
  final EmotionType emotion;
  final String? message;
  final String userId;

  // 3시간 단위 타임라인 슬롯
  int get timeSlotIndex => timestamp.hour ~/ 3;

  TimelineEntry copyWith({
    String? id,
    DateTime? timestamp,
    EmotionType? emotion,
    String? message,
    String? userId,
  }) {
    return TimelineEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      emotion: emotion ?? this.emotion,
      message: message ?? this.message,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'timestamp': Timestamp.fromDate(timestamp.toUtc()),
      'emotion': emotion.id,
      'message': message,
      'userId': userId,
    };
  }

  factory TimelineEntry.fromMap(String id, Map<String, dynamic> map) {
    final dynamic rawTimestamp = map['timestamp'];
    final dynamic rawEmotion = map['emotion'];

    return TimelineEntry(
      id: id,
      timestamp: _parseTimestamp(rawTimestamp),
      emotion: rawEmotion is String
          ? emotionTypeFromId(rawEmotion)
          : EmotionType.happy,
      message: map['message'] as String?,
      userId: map['userId'] as String? ?? '',
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is DateTime) {
      return value.toLocal();
    }
    if (value is Timestamp) {
      return value.toDate().toLocal();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true).toLocal();
    }
    if (value is String) {
      return DateTime.parse(value).toLocal();
    }
    throw FormatException('timestamp 필드가 올바르지 않습니다: $value');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TimelineEntry &&
        other.id == id &&
        other.timestamp == timestamp &&
        other.emotion == emotion &&
        other.message == message &&
        other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(id, timestamp, emotion, message, userId);
}
