import 'package:mood_tracker/core/models/emotion_type.dart';

/// 일별 감정 분포 모델
class DailyMoodDistribution {
  final DateTime date; // 날짜
  final Map<EmotionType, int> emotionCounts; // 해당 날짜의 감정별 횟수
  final EmotionType? dominantEmotion; // 가장 많았던 감정

  DailyMoodDistribution({
    required this.date,
    required this.emotionCounts,
    this.dominantEmotion,
  });

  /// 해당 날짜의 총 기록 수
  int get totalCount => emotionCounts.values.fold(0, (sum, count) => sum + count);

  /// 데이터가 있는지 확인
  bool get hasData => totalCount > 0;

  /// 날짜를 'MM/dd' 형식으로 반환
  String get formattedDate {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}
