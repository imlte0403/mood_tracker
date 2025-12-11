import 'package:mood_tracker/core/models/emotion_type.dart';
import 'package:mood_tracker/features/post/model/mood_shape.dart';

class EmotionScoreMapper {
  const EmotionScoreMapper._();

  // 슬라이더 값(0.0~7.0) → 감정 점수(-100~+100) 변환
  static double sliderToScore(double sliderValue) {
    // 1. 슬라이더 값에서 현재 감정 추출
    final mood = MoodShapeEngine.getMoodFromSlider(sliderValue);
    final emotion = mood.emotion;

    // 2. 각 감정의 기본 점수
    final baseScore = getBaseScore(emotion);

    // 3. 슬라이더 위치에 따른 강도 계산 (0.0 ~ 1.0)
    final intensity = _calculateIntensity(sliderValue);

    // 4. 최종 점수 계산
    return baseScore * intensity;
  }

  // EmotionType + intensity(0-100) → 감정 점수 계산
  static double calculate(EmotionType emotion, int intensity) {
    final baseScore = getBaseScore(emotion);
    final intensityFactor = intensity / 100.0;

    // 점수가 음수면 더 작아지게(더 강한 부정), 양수면 더 커지게(더 강한 긍정)
    // 0점인 경우는 0 유지
    return baseScore * intensityFactor;
  }

  // 감정별 기본 점수 (최대 강도일 때의 점수)
  static double getBaseScore(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.lucky:
        return 90.0; // 행운 (+90)
      case EmotionType.happy:
        return 80.0; // 행복 (+80)
      case EmotionType.excited:
        return 85.0; // 설렘 (+85)
      case EmotionType.normal:
        return 0.0; // 보통 (0)
      case EmotionType.depressed:
        return -70.0; // 우울 (-70)
      case EmotionType.anxious:
        return -60.0; // 불안 (-60)
      case EmotionType.angry:
        return -75.0; // 분노 (-75)
      case EmotionType.sad:
        return -65.0; // 슬픔 (-65)
    }
  }

  static double _calculateIntensity(double sliderValue) {
    // 가장 가까운 정수 값(감정 중심점)까지의 거리로 강도 계산
    // 예: 2.0(감정 중심) -> 거리 0 -> 강도 1.0
    // 예: 2.5(감정 중간) -> 거리 0.5 -> 강도 0.5
    final nearestInt = sliderValue.round();
    final distance = (sliderValue - nearestInt).abs();

    // 중심점에 가까울수록 강도 높음 (1.0), 중간점일수록 강도 낮음 (0.5)
    return 1.0 - distance;
  }
}
