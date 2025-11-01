import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:mood_tracker/core/models/emotion_type.dart';

// 슬라이더 최소값, 최대값 정의
const double kMoodSliderMin = 0.0;
const double kMoodSliderMax = 7.0;

//감정 종류
enum MoodType { angry, sad, anxious, normal, depressed, lucky, excited, happy }

// 메서드
extension MoodTypeX on MoodType {
  // MoodType을 EmotionType으로 변환
  EmotionType get emotion {
    switch (this) {
      case MoodType.angry:
        return EmotionType.angry;
      case MoodType.sad:
        return EmotionType.sad;
      case MoodType.anxious:
        return EmotionType.anxious;
      case MoodType.normal:
        return EmotionType.normal;
      case MoodType.depressed:
        return EmotionType.depressed;
      case MoodType.lucky:
        return EmotionType.lucky;
      case MoodType.excited:
        return EmotionType.excited;
      case MoodType.happy:
        return EmotionType.happy;
    }
  }

  // EmotionType을 MoodType으로 변환
  static MoodType fromEmotion(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.angry:
        return MoodType.angry;
      case EmotionType.sad:
        return MoodType.sad;
      case EmotionType.anxious:
        return MoodType.anxious;
      case EmotionType.normal:
        return MoodType.normal;
      case EmotionType.depressed:
        return MoodType.depressed;
      case EmotionType.lucky:
        return MoodType.lucky;
      case EmotionType.excited:
        return MoodType.excited;
      case EmotionType.happy:
        return MoodType.happy;
    }
  }
}

// 각 감정의 시각적 정의
class MoodShapeDefinition {
  const MoodShapeDefinition({
    required this.type,
    required this.sliderStart,
    required this.shape,
    required this.color,
  });

  final MoodType type;
  final double sliderStart;
  final ShapeBorder shape;
  final Color color;
}

class MoodShapeSnapshot {
  const MoodShapeSnapshot({
    required this.sliderValue,
    required this.currentMood,
    required this.displayEmotion,
    required this.color,
    required this.shape,
  });

  final double sliderValue;
  final MoodType currentMood;
  final EmotionType displayEmotion;
  final Color color;
  final ShapeBorder shape;
}

// 슬라이더의 값에 따른 변화 처리
class MoodShapeEngine {
  const MoodShapeEngine._();

  // 슬라이더 값에서 감정 타입 추출
  static MoodType getMoodFromSlider(double value) {
    return resolve(value).currentMood;
  }

  // 감정에 따른 색상 반환
  static Color colorForMood(MoodType mood) {
    // _definitionsByType 대신 직접 검색
    for (final definition in _definitions) {
      if (definition.type == mood) {
        return definition.color;
      }
    }
    return EmotionType.happy.color;
  }

  // EmotionType에 따른 색상 반환
  static Color colorForEmotion(EmotionType emotion) {
    return colorForMood(MoodTypeX.fromEmotion(emotion));
  }

  // 슬라이더 기준점 반환
  static double sliderAnchorForMood(MoodType mood) {
    for (int i = 0; i < _definitions.length; i++) {
      final definition = _definitions[i];
      if (definition.type == mood) {
        final bool isLast = i == _definitions.length - 1;
        final double anchor = definition.sliderStart + (isLast ? 0.0 : 0.5);
        return anchor.clamp(kMoodSliderMin, kMoodSliderMax);
      }
    }
    return kMoodSliderMin;
  }

  // EmotionType에 따른 슬라이더 기준점 반환
  static double sliderAnchorForEmotion(EmotionType emotion) {
    return sliderAnchorForMood(MoodTypeX.fromEmotion(emotion));
  }

  // MoodShapeSnapshot을 생성하는 메인 메서드
  // 색상과 모양 morphing
  static MoodShapeSnapshot resolve(double sliderValue) {
    // 값 제한 및 기본 설정
    final double clamped = sliderValue.clamp(kMoodSliderMin, kMoodSliderMax);
    final int lowerIndex = math.min(_definitions.length - 1, clamped.floor());
    final MoodShapeDefinition lower = _definitions[lowerIndex];
    final bool isLast = lowerIndex == _definitions.length - 1;
    final MoodShapeDefinition upper = isLast
        ? lower
        : _definitions[lowerIndex + 1];

    // morphing 비율 계산
    final double span = isLast
        ? 1
        : (upper.sliderStart - lower.sliderStart).clamp(0.001, 1.0);
    final double rawT = isLast
        ? 0
        : ((clamped - lower.sliderStart) / span).clamp(0.0, 1.0);
    final double easedT = isLast ? 0 : Curves.easeInOutCubic.transform(rawT);

    // 색상
    final Color blended =
        Color.lerp(lower.color, upper.color, easedT) ?? lower.color;

    // 모양
    final ShapeBorder morphedShape = _interpolateShape(
      lower.shape,
      upper.shape,
      easedT,
    );

    // 현재 감정 결정 (중간점 기준)
    final MoodType currentMood = (isLast || rawT <= 0.5)
        ? lower.type
        : upper.type;

    return MoodShapeSnapshot(
      sliderValue: clamped,
      currentMood: currentMood,
      displayEmotion: currentMood.emotion,
      color: blended,
      shape: morphedShape,
    );
  }
}

// 슬라이더 위치에 따른 감정별 색상, 모양 정의
final List<MoodShapeDefinition> _definitions = <MoodShapeDefinition>[
  MoodShapeDefinition(
    type: MoodType.angry,
    sliderStart: 0,
    color: MoodType.angry.emotion.color,
    shape: StarBorder(points: 12, innerRadiusRatio: 0.4, pointRounding: 0.05),
  ),
  MoodShapeDefinition(
    type: MoodType.sad,
    sliderStart: 1,
    color: MoodType.sad.emotion.color,
    shape: StarBorder(points: 9, innerRadiusRatio: 0.5, pointRounding: 0.1),
  ),
  MoodShapeDefinition(
    type: MoodType.anxious,
    sliderStart: 2,
    color: MoodType.anxious.emotion.color,
    shape: StarBorder(points: 7, innerRadiusRatio: 0.6, pointRounding: 0.2),
  ),
  MoodShapeDefinition(
    type: MoodType.normal,
    sliderStart: 3,
    color: MoodType.normal.emotion.color,
    shape: StarBorder(points: 5, innerRadiusRatio: 0.6, pointRounding: 0.5),
  ),
  MoodShapeDefinition(
    type: MoodType.depressed,
    sliderStart: 4,
    color: MoodType.depressed.emotion.color,
    shape: StarBorder(points: 3, innerRadiusRatio: 0.3, pointRounding: 0.9),
  ),
  MoodShapeDefinition(
    type: MoodType.lucky,
    sliderStart: 5,
    color: MoodType.lucky.emotion.color,
    shape: StarBorder(points: 4, innerRadiusRatio: 0.3, pointRounding: 0.9),
  ),
  MoodShapeDefinition(
    type: MoodType.excited,
    sliderStart: 6,
    color: MoodType.excited.emotion.color,
    shape: StarBorder(points: 6, innerRadiusRatio: 0.3, pointRounding: 0.9),
  ),
  MoodShapeDefinition(
    type: MoodType.happy,
    sliderStart: 7,
    color: MoodType.happy.emotion.color,
    shape: StarBorder(points: 10, innerRadiusRatio: 0.3, pointRounding: 0.9),
  ),
];

// 간단한 모양 보간 (기본 Flutter 기능만 사용)
ShapeBorder _interpolateShape(ShapeBorder from, ShapeBorder to, double t) {
  return ShapeBorder.lerp(from, to, t) ?? from;
}
