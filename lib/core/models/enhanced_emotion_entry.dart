import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mood_tracker/core/models/emotion_type.dart';
import 'package:mood_tracker/core/models/physical_symptom.dart';
import 'package:mood_tracker/core/models/trigger_event.dart';
import 'package:mood_tracker/core/models/activity_tag.dart';

enum EntrySource {
  manual, // 직접 입력
  quick, // 간편 입력
  symptomBased, // 증상 기반
  widget, // 위젯
}

extension EntrySourceX on EntrySource {
  String get id => toString().split('.').last;

  static EntrySource fromId(String id) {
    return EntrySource.values.firstWhere(
      (type) => type.id == id,
      orElse: () => EntrySource.manual,
    );
  }
}

class EnhancedEmotionEntry {
  const EnhancedEmotionEntry({
    required this.id,
    required this.timestamp,
    required this.emotion,
    required this.intensity, // 0-100
    required this.emotionScore, // -100 to +100
    this.memo,
    required this.userId,
    this.symptoms = const [],
    this.triggers = const [],
    this.activities = const [],
    this.source = EntrySource.manual,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final DateTime timestamp;
  final EmotionType emotion;
  final int intensity;
  final double emotionScore;
  final String? memo;
  final String userId;
  final List<PhysicalSymptom> symptoms;
  final List<TriggerEvent> triggers;
  final List<ActivityTag> activities;
  final EntrySource source;
  final DateTime createdAt;
  final DateTime? updatedAt;

  EnhancedEmotionEntry copyWith({
    String? id,
    DateTime? timestamp,
    EmotionType? emotion,
    int? intensity,
    double? emotionScore,
    String? memo,
    String? userId,
    List<PhysicalSymptom>? symptoms,
    List<TriggerEvent>? triggers,
    List<ActivityTag>? activities,
    EntrySource? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EnhancedEmotionEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      emotion: emotion ?? this.emotion,
      intensity: intensity ?? this.intensity,
      emotionScore: emotionScore ?? this.emotionScore,
      memo: memo ?? this.memo,
      userId: userId ?? this.userId,
      symptoms: symptoms ?? this.symptoms,
      triggers: triggers ?? this.triggers,
      activities: activities ?? this.activities,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'emotion': emotion.id,
      'intensity': intensity,
      'emotionScore': emotionScore,
      'memo': memo,
      'userId': userId,
      'symptoms': symptoms.map((e) => e.toMap()).toList(),
      'triggers': triggers.map((e) => e.toMap()).toList(),
      'activities': activities.map((e) => e.toMap()).toList(),
      'source': source.id,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory EnhancedEmotionEntry.fromMap(String id, Map<String, dynamic> map) {
    return EnhancedEmotionEntry(
      id: id,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      emotion: emotionTypeFromId(map['emotion'] as String),
      intensity: (map['intensity'] as num?)?.toInt() ?? 70, // 기본값
      emotionScore: (map['emotionScore'] as num?)?.toDouble() ?? 0.0,
      memo: map['memo'] as String?,
      userId: map['userId'] as String? ?? '',
      symptoms:
          (map['symptoms'] as List<dynamic>?)
              ?.map((e) => PhysicalSymptom.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      triggers:
          (map['triggers'] as List<dynamic>?)
              ?.map((e) => TriggerEvent.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      activities:
          (map['activities'] as List<dynamic>?)
              ?.map((e) => ActivityTag.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      source: EntrySourceX.fromId(map['source'] as String? ?? 'manual'),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
