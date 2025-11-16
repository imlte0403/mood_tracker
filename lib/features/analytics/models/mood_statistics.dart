import 'package:mood_tracker/core/models/emotion_type.dart';

/// 감정 통계 데이터 모델
class MoodStatistics {
  final Map<EmotionType, int> emotionCounts; // 감정별 횟수
  final Map<EmotionType, double> emotionPercentages; // 감정별 비율 (0-100)
  final EmotionType? mostFrequent; // 가장 많은 감정
  final DateTime startDate; // 시작 날짜
  final DateTime endDate; // 종료 날짜
  final int totalEntries; // 총 기록 수

  MoodStatistics({
    required this.emotionCounts,
    required this.emotionPercentages,
    this.mostFrequent,
    required this.startDate,
    required this.endDate,
    required this.totalEntries,
  });

  /// 빈 통계 (데이터 없음)
  factory MoodStatistics.empty({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return MoodStatistics(
      emotionCounts: {},
      emotionPercentages: {},
      mostFrequent: null,
      startDate: startDate,
      endDate: endDate,
      totalEntries: 0,
    );
  }

  /// 데이터가 있는지 확인
  bool get hasData => totalEntries > 0;

  /// 감정 다양성 점수 (사용한 감정 종류 수)
  int get emotionDiversity => emotionCounts.keys.length;
}
