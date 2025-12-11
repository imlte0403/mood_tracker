import 'package:cloud_firestore/cloud_firestore.dart';

enum TriggerCategory {
  work, // 업무
  social, // 사회적 상호작용
  exercise, // 운동
  rest, // 휴식
  meal, // 식사
  sleep, // 수면
  media, // 미디어 소비
  hobby, // 취미
  custom, // 사용자 정의
}

extension TriggerCategoryX on TriggerCategory {
  String get displayName {
    switch (this) {
      case TriggerCategory.work:
        return '업무';
      case TriggerCategory.social:
        return '만남';
      case TriggerCategory.exercise:
        return '운동';
      case TriggerCategory.rest:
        return '휴식';
      case TriggerCategory.meal:
        return '식사';
      case TriggerCategory.sleep:
        return '수면';
      case TriggerCategory.media:
        return '미디어';
      case TriggerCategory.hobby:
        return '취미';
      case TriggerCategory.custom:
        return '기타';
    }
  }

  String get emoji {
    switch (this) {
      case TriggerCategory.work:
        return '💼';
      case TriggerCategory.social:
        return '👥';
      case TriggerCategory.exercise:
        return '💪';
      case TriggerCategory.rest:
        return '🛋️';
      case TriggerCategory.meal:
        return '🍽️';
      case TriggerCategory.sleep:
        return '😴';
      case TriggerCategory.media:
        return '📱';
      case TriggerCategory.hobby:
        return '🎨';
      case TriggerCategory.custom:
        return '✨';
    }
  }

  String get id => toString().split('.').last;

  static TriggerCategory fromId(String id) {
    return TriggerCategory.values.firstWhere(
      (type) => type.id == id,
      orElse: () => TriggerCategory.custom,
    );
  }
}

class TriggerEvent {
  const TriggerEvent({
    required this.id,
    required this.description,
    required this.category,
    required this.occurredAt,
  });

  final String id;
  final String description;
  final TriggerCategory category;
  final DateTime occurredAt;

  TriggerEvent copyWith({
    String? id,
    String? description,
    TriggerCategory? category,
    DateTime? occurredAt,
  }) {
    return TriggerEvent(
      id: id ?? this.id,
      description: description ?? this.description,
      category: category ?? this.category,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'category': category.id,
      'occurredAt': Timestamp.fromDate(occurredAt),
    };
  }

  factory TriggerEvent.fromMap(Map<String, dynamic> map) {
    return TriggerEvent(
      id: map['id'] as String,
      description: map['description'] as String? ?? '',
      category: TriggerCategoryX.fromId(map['category'] as String),
      occurredAt: (map['occurredAt'] as Timestamp).toDate(),
    );
  }
}
