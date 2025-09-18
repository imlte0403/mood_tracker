import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:mood_tracker/core/models/emotion_type.dart';

const double kMoodSliderMin = 0.0;
const double kMoodSliderMax = 7.0;

enum MoodType {
  angry,
  sad,
  anxious,
  confused,
  depressed,
  lucky,
  excited,
  happy,
}

extension MoodTypeX on MoodType {
  EmotionType get emotion {
    switch (this) {
      case MoodType.angry:
        return EmotionType.angry;
      case MoodType.sad:
        return EmotionType.sad;
      case MoodType.anxious:
        return EmotionType.anxious;
      case MoodType.confused:
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

  static MoodType fromEmotion(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.angry:
        return MoodType.angry;
      case EmotionType.sad:
        return MoodType.sad;
      case EmotionType.anxious:
        return MoodType.anxious;
      case EmotionType.normal:
        return MoodType.confused;
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
    required this.t,
    required this.lowerMood,
    required this.upperMood,
  });

  final double sliderValue;
  final MoodType currentMood;
  final EmotionType displayEmotion;
  final Color color;
  final ShapeBorder shape;
  final double t;
  final MoodType lowerMood;
  final MoodType upperMood;
}

class MoodShapeEngine {
  const MoodShapeEngine._();

  static MoodType getMoodFromSlider(double value) {
    return resolve(value).currentMood;
  }

  static Color colorForMood(MoodType mood) {
    return _definitionsByType[mood]?.color ?? EmotionType.happy.color;
  }

  static Color colorForEmotion(EmotionType emotion) {
    return colorForMood(MoodTypeX.fromEmotion(emotion));
  }

  static double sliderAnchorForMood(MoodType mood) {
    final definition = _definitionsByType[mood];
    if (definition == null) return kMoodSliderMin;
    final index = _definitions.indexOf(definition);
    final bool isLast = index == _definitions.length - 1;
    final double anchor = definition.sliderStart + (isLast ? 0.0 : 0.5);
    return anchor.clamp(kMoodSliderMin, kMoodSliderMax);
  }

  static double sliderAnchorForEmotion(EmotionType emotion) {
    return sliderAnchorForMood(MoodTypeX.fromEmotion(emotion));
  }

  static MoodShapeSnapshot resolve(double sliderValue) {
    final double clamped = sliderValue.clamp(kMoodSliderMin, kMoodSliderMax);
    final int lowerIndex = math.min(_definitions.length - 1, clamped.floor());
    final MoodShapeDefinition lower = _definitions[lowerIndex];
    final bool isLast = lowerIndex == _definitions.length - 1;
    final MoodShapeDefinition upper = isLast
        ? lower
        : _definitions[lowerIndex + 1];

    final double span = isLast
        ? 1
        : (upper.sliderStart - lower.sliderStart).clamp(0.001, 1.0);
    final double rawT = isLast
        ? 0
        : ((clamped - lower.sliderStart) / span).clamp(0.0, 1.0);
    final double easedT = isLast ? 0 : Curves.easeInOutCubic.transform(rawT);

    final Color blended =
        Color.lerp(lower.color, upper.color, easedT) ?? lower.color;

    final ShapeBorder morphedShape = isLast || easedT == 0.0
        ? lower.shape
        : ShapeBorder.lerp(lower.shape, upper.shape, easedT) ?? lower.shape;

    final MoodType currentMood = (isLast || rawT <= 0.5)
        ? lower.type
        : upper.type;

    return MoodShapeSnapshot(
      sliderValue: clamped,
      currentMood: currentMood,
      displayEmotion: currentMood.emotion,
      color: blended,
      shape: morphedShape,
      t: rawT,
      lowerMood: lower.type,
      upperMood: upper.type,
    );
  }
}

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
    type: MoodType.confused,
    sliderStart: 3,
    color: MoodType.confused.emotion.color,
    shape: StarBorder(points: 5, innerRadiusRatio: 0.7, pointRounding: 0.3),
  ),
  MoodShapeDefinition(
    type: MoodType.depressed,
    sliderStart: 4,
    color: MoodType.depressed.emotion.color,
    shape: StarBorder(points: 3, innerRadiusRatio: 0.6, pointRounding: 0.4),
  ),
  MoodShapeDefinition(
    type: MoodType.lucky,
    sliderStart: 5,
    color: MoodType.lucky.emotion.color,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
  ),
  MoodShapeDefinition(
    type: MoodType.excited,
    sliderStart: 6,
    color: MoodType.excited.emotion.color,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(70.0)),
  ),
  MoodShapeDefinition(
    type: MoodType.happy,
    sliderStart: 7,
    color: MoodType.happy.emotion.color,
    shape: const CircleBorder(),
  ),
];

final Map<MoodType, MoodShapeDefinition> _definitionsByType =
    <MoodType, MoodShapeDefinition>{
      for (final definition in _definitions) definition.type: definition,
    };
