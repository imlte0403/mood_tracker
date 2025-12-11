import 'package:cloud_firestore/cloud_firestore.dart';

enum SymptomType {
  headache, // 두통
  nausea, // 속쓰림
  dizziness, // 어지러움
  numbness, // 멍함
  chestTightness, // 가슴 답답함
  breathingDifficulty, // 호흡곤란
  fatigue, // 피로
  tension, // 긴장
  stomachache, // 복통
  heartPalpitation, // 심계항진
  custom, // 사용자 정의
}

extension SymptomTypeX on SymptomType {
  String get displayName {
    switch (this) {
      case SymptomType.headache:
        return '두통';
      case SymptomType.nausea:
        return '속쓰림';
      case SymptomType.dizziness:
        return '어지러움';
      case SymptomType.numbness:
        return '멍함';
      case SymptomType.chestTightness:
        return '가슴 답답함';
      case SymptomType.breathingDifficulty:
        return '호흡곤란';
      case SymptomType.fatigue:
        return '피로';
      case SymptomType.tension:
        return '긴장';
      case SymptomType.stomachache:
        return '복통';
      case SymptomType.heartPalpitation:
        return '심계항진';
      case SymptomType.custom:
        return '기타';
    }
  }

  String get id {
    return toString().split('.').last;
  }

  static SymptomType fromId(String id) {
    return SymptomType.values.firstWhere(
      (type) => type.id == id,
      orElse: () => SymptomType.custom,
    );
  }
}

class PhysicalSymptom {
  const PhysicalSymptom({
    required this.type,
    this.customName,
    required this.severity, // 1-5
    required this.recordedAt,
  });

  final SymptomType type;
  final String? customName;
  final int severity;
  final DateTime recordedAt;

  String get displayLabel =>
      type == SymptomType.custom ? (customName ?? '기타 증상') : type.displayName;

  PhysicalSymptom copyWith({
    SymptomType? type,
    String? customName,
    int? severity,
    DateTime? recordedAt,
  }) {
    return PhysicalSymptom(
      type: type ?? this.type,
      customName: customName ?? this.customName,
      severity: severity ?? this.severity,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.id,
      'customName': customName,
      'severity': severity,
      'recordedAt': Timestamp.fromDate(recordedAt),
    };
  }

  factory PhysicalSymptom.fromMap(Map<String, dynamic> map) {
    return PhysicalSymptom(
      type: SymptomTypeX.fromId(map['type'] as String),
      customName: map['customName'] as String?,
      severity: (map['severity'] as num?)?.toInt() ?? 1,
      recordedAt: (map['recordedAt'] as Timestamp).toDate(),
    );
  }
}
