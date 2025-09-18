import 'package:flutter/material.dart';
import 'package:mood_tracker/core/constants/app_color.dart';

// 감정 타입
enum EmotionType {
  lucky,
  happy,
  excited,
  normal,
  depressed,
  anxious,
  angry,
  sad,
}

extension EmotionTypeX on EmotionType {
  // Firestore 저장용
  String get id {
    switch (this) {
      case EmotionType.lucky:
        return 'lucky';
      case EmotionType.happy:
        return 'happy';
      case EmotionType.excited:
        return 'excited';
      case EmotionType.normal:
        return 'normal';
      case EmotionType.depressed:
        return 'depressed';
      case EmotionType.anxious:
        return 'anxious';
      case EmotionType.angry:
        return 'angry';
      case EmotionType.sad:
        return 'sad';
    }
  }

  String get displayNameKo {
    switch (this) {
      case EmotionType.lucky:
        return '행운';
      case EmotionType.happy:
        return '행복';
      case EmotionType.excited:
        return '설렘';
      case EmotionType.normal:
        return '보통';
      case EmotionType.depressed:
        return '우울';
      case EmotionType.anxious:
        return '불안';
      case EmotionType.angry:
        return '분노';
      case EmotionType.sad:
        return '슬픔';
    }
  }

  String get displayNameEn {
    switch (this) {
      case EmotionType.lucky:
        return 'Lucky';
      case EmotionType.happy:
        return 'Happy';
      case EmotionType.excited:
        return 'Excited';
      case EmotionType.normal:
        return 'Normal';
      case EmotionType.depressed:
        return 'Depressed';
      case EmotionType.anxious:
        return 'Anxious';
      case EmotionType.angry:
        return 'Angry';
      case EmotionType.sad:
        return 'Sad';
    }
  }

  String get emoji {
    switch (this) {
      case EmotionType.lucky:
        return '🍀';
      case EmotionType.happy:
        return '😊';
      case EmotionType.excited:
        return '🥰';
      case EmotionType.normal:
        return '🙂';
      case EmotionType.depressed:
        return '😞';
      case EmotionType.anxious:
        return '😰';
      case EmotionType.angry:
        return '😡';
      case EmotionType.sad:
        return '😢';
    }
  }

  // 감정별 색상코드
  Color get color {
    switch (this) {
      case EmotionType.lucky:
        return AppColors.moodLucky;
      case EmotionType.happy:
        return AppColors.moodHappy;
      case EmotionType.excited:
        return AppColors.moodExcited;
      case EmotionType.normal:
        return AppColors.moodNormal;
      case EmotionType.depressed:
        return AppColors.moodDepressed;
      case EmotionType.anxious:
        return AppColors.moodAnxious;
      case EmotionType.angry:
        return AppColors.moodAngry;
      case EmotionType.sad:
        return AppColors.moodSad;
    }
  }
}

EmotionType emotionTypeFromId(
  String id, {
  EmotionType fallback = EmotionType.normal,
}) {
  return EmotionType.values.firstWhere(
    (type) => type.id == id,
    orElse: () => fallback,
  );
}
