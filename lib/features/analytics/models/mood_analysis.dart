/// 감정 분석 레벨
enum MoodAnalysisLevel {
  veryPositive, // 매우 긍정적 (긍정 70% 이상)
  positive, // 긍정적 (긍정 50~70%)
  balanced, // 균형적 (긍정/부정 40~60%)
  negative, // 부정적 (부정 50~70%)
  veryNegative; // 매우 부정적 (부정 70% 이상)

  /// 아이콘
  String get icon {
    switch (this) {
      case MoodAnalysisLevel.veryPositive:
        return '🌸';
      case MoodAnalysisLevel.positive:
        return '☀️';
      case MoodAnalysisLevel.balanced:
        return '🌗';
      case MoodAnalysisLevel.negative:
        return '🌧️';
      case MoodAnalysisLevel.veryNegative:
        return '🌑';
    }
  }

  /// 제목
  String get title {
    switch (this) {
      case MoodAnalysisLevel.veryPositive:
        return '요즘 당신의 마음은 맑은 봄날처럼 화창해요';
      case MoodAnalysisLevel.positive:
        return '당신의 마음은 따뜻한 햇살이 비치는 오후 같아요';
      case MoodAnalysisLevel.balanced:
        return '당신의 마음은 지금 변화의 시기를 겪고 있어요';
      case MoodAnalysisLevel.negative:
        return '요즘 조금 힘든 시간을 보내고 있는 것 같아요';
      case MoodAnalysisLevel.veryNegative:
        return '지금 당신의 마음이 많이 아프다는 걸 알아요';
    }
  }

  /// 분석 글
  String get message {
    switch (this) {
      case MoodAnalysisLevel.veryPositive:
        return '''지난 기간 동안 기록된 감정의 대부분이 긍정적인 에너지로 가득했어요. 행복하고 설레는 순간들이 당신의 일상을 채우고 있다는 건 정말 멋진 일이에요. 이런 좋은 기운이 계속 이어질 수 있도록, 지금 이 순간을 충분히 누리고 감사함을 느껴보세요.

하지만 모든 날이 완벽할 수는 없다는 것도 기억해 주세요. 가끔 찾아오는 작은 우울함이나 불안도 당연한 감정이에요. 지금의 긍정적인 에너지가 그런 순간들을 잘 이겨낼 수 있는 힘이 되어줄 거예요. 당신은 지금 잘하고 있어요! 💪''';

      case MoodAnalysisLevel.positive:
        return '''전반적으로 긍정적인 감정이 우세하지만, 가끔 구름이 끼는 날도 있었던 것 같아요. 그건 지극히 자연스러운 일이에요. 중요한 건 당신이 어려운 순간에도 다시 일어서서 좋은 감정을 찾아가고 있다는 거예요.

힘든 감정들도 당신을 성장시키는 소중한 경험이에요. 부정적인 감정을 느낄 때 자신을 너무 탓하지 마세요. 대신 그 감정을 인정하고, 왜 그런 감정이 들었는지 조금만 들여다보세요. 그리고 스스로에게 따뜻한 말 한마디 건네주세요. "괜찮아, 넌 충분히 잘하고 있어." 🌻''';

      case MoodAnalysisLevel.balanced:
        return '''긍정적인 감정과 부정적인 감정이 함께 공존하는 요즘, 혹시 혼란스럽진 않나요? 괜찮아요. 삶은 원래 이렇게 다양한 감정들이 뒤섞이며 흘러가는 거니까요. 이런 균형의 시기는 당신이 스스로를 더 깊이 이해할 수 있는 좋은 기회예요.

지금은 특별히 한쪽으로 치우치지 않고, 있는 그대로의 감정을 받아들이는 연습을 해보세요. 행복할 땐 그 기쁨을 만끽하고, 우울할 땐 그 감정도 인정해 주세요. 모든 감정은 당신에게 무언가를 말하려고 하고 있어요. 천천히, 자신의 속도로 나아가면 돼요. 🌿''';

      case MoodAnalysisLevel.negative:
        return '''최근 기록을 보니 마음이 무겁고 불안한 날들이 많았어요. 혼자 이 감정들을 견디느라 많이 지쳤을 거예요. 먼저 이 말을 해주고 싶어요. "당신은 충분히 잘 버티고 있어요."

부정적인 감정이 계속되면 세상이 온통 어둡게만 느껴질 수 있어요. 하지만 기억해 주세요, 이 감정들은 영원하지 않아요. 작은 것부터 시작해보세요. 좋아하는 음악 듣기, 짧은 산책, 따뜻한 차 한 잔. 이런 작은 행동들이 조금씩 마음에 빛을 불러올 거예요.

혼자 감당하기 힘들다면 주변에 도움을 요청하는 것도 용기예요. 당신은 혼자가 아니에요. 💙''';

      case MoodAnalysisLevel.veryNegative:
        return '''최근 기록된 감정들을 보니 정말 힘든 시간을 보내고 있는 것 같아요. 매일 무거운 마음을 안고 살아가는 게 얼마나 힘든지, 그 무게가 얼마나 견디기 어려운지 이해해요. 하지만 이렇게 감정을 기록하며 스스로를 돌아보고 있다는 것 자체가 정말 대단한 일이에요.

지금 이 순간, 가장 중요한 건 당신 자신을 돌보는 거예요. 스스로에게 너무 많은 걸 요구하지 마세요. 오늘 하루를 버텨낸 것만으로도 충분히 잘한 거예요.

이런 감정이 2주 이상 계속된다면, 전문가의 도움을 받는 것을 진지하게 고려해 보세요. 도움을 청하는 것은 약함이 아니라 자신을 사랑하는 용기예요. 당신은 더 나은 날을 맞이할 자격이 있어요. 🕯️

📞 위기상담전화: 1577-0199 (24시간)''';
    }
  }
}

/// 감정 분석 결과
class MoodAnalysis {
  final MoodAnalysisLevel level;
  final double positivePercentage; // 긍정 감정 비율
  final double negativePercentage; // 부정 감정 비율

  const MoodAnalysis({
    required this.level,
    required this.positivePercentage,
    required this.negativePercentage,
  });
}
