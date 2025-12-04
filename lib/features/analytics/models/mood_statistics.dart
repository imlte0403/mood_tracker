import 'package:mood_tracker/core/models/emotion_type.dart';
import 'package:mood_tracker/features/analytics/models/mood_analysis.dart';

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

  /// 긍정적인 감정 목록
  static const List<EmotionType> _positiveEmotions = [
    EmotionType.lucky,
    EmotionType.happy,
    EmotionType.excited,
  ];

  /// 부정적인 감정 목록
  static const List<EmotionType> _negativeEmotions = [
    EmotionType.depressed,
    EmotionType.anxious,
    EmotionType.angry,
    EmotionType.sad,
  ];

  /// 긍정 감정 비율 계산 (0-100)
  double get positivePercentage {
    if (!hasData) return 0;

    double positiveCount = 0;
    for (final emotion in _positiveEmotions) {
      positiveCount += emotionPercentages[emotion] ?? 0;
    }
    return positiveCount;
  }

  /// 부정 감정 비율 계산 (0-100)
  double get negativePercentage {
    if (!hasData) return 0;

    double negativeCount = 0;
    for (final emotion in _negativeEmotions) {
      negativeCount += emotionPercentages[emotion] ?? 0;
    }
    return negativeCount;
  }

  /// 감정 분석 결과 생성
  MoodAnalysis get analysis {
    if (!hasData) {
      return MoodAnalysis(
        level: MoodAnalysisLevel.balanced,
        positivePercentage: 0,
        negativePercentage: 0,
      );
    }

    final positive = positivePercentage;
    final negative = negativePercentage;

    // 5가지 레벨 분류
    MoodAnalysisLevel level;

    if (positive >= 70) {
      // 매우 긍정적
      level = MoodAnalysisLevel.veryPositive;
    } else if (positive >= 50) {
      // 긍정적
      level = MoodAnalysisLevel.positive;
    } else if (negative >= 70) {
      // 매우 부정적
      level = MoodAnalysisLevel.veryNegative;
    } else if (negative >= 50) {
      // 부정적
      level = MoodAnalysisLevel.negative;
    } else {
      // 균형적 (긍정도 부정도 50% 미만)
      level = MoodAnalysisLevel.balanced;
    }

    return MoodAnalysis(
      level: level,
      positivePercentage: positive,
      negativePercentage: negative,
    );
  }
}
