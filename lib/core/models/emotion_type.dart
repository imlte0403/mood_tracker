import 'package:flutter/material.dart';

// 감정 타입
enum EmotionType {
  lucky,
  happy,
  excited,
  confused,
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
      case EmotionType.confused:
        return 'confused';
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
      case EmotionType.confused:
        return '혼란';
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
      case EmotionType.confused:
        return 'Confused';
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
      case EmotionType.confused:
        return '🤔';
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
        return const Color(0xFF4CAF50);
      case EmotionType.happy:
        return const Color(0xFF66BB6A);
      case EmotionType.excited:
        return const Color(0xFF81C784);
      case EmotionType.confused:
        return const Color(0xFF9E9E9E);
      case EmotionType.depressed:
        return const Color(0xFF757575);
      case EmotionType.anxious:
        return const Color(0xFFFFB74D);
      case EmotionType.angry:
        return const Color(0xFFFF5722);
      case EmotionType.sad:
        return const Color(0xFFFF9800);
    }
  }
}

EmotionType emotionTypeFromId(
  String id, {
  EmotionType fallback = EmotionType.happy,
}) {
  return EmotionType.values.firstWhere(
    (type) => type.id == id,
    orElse: () => fallback,
  );
}
