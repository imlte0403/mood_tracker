import 'trigger_event.dart';

class ActivityTag {
  const ActivityTag({
    required this.category,
    required this.label,
    this.isPositive = true, // 추후 학습을 통해 업데이트
  });

  final TriggerCategory category;
  final String label;
  final bool isPositive;

  ActivityTag copyWith({
    TriggerCategory? category,
    String? label,
    bool? isPositive,
  }) {
    return ActivityTag(
      category: category ?? this.category,
      label: label ?? this.label,
      isPositive: isPositive ?? this.isPositive,
    );
  }

  Map<String, dynamic> toMap() {
    return {'category': category.id, 'label': label, 'isPositive': isPositive};
  }

  factory ActivityTag.fromMap(Map<String, dynamic> map) {
    return ActivityTag(
      category: TriggerCategoryX.fromId(map['category'] as String),
      label: map['label'] as String,
      isPositive: map['isPositive'] as bool? ?? true,
    );
  }
}
