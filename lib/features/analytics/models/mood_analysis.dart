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
        return '긍정적인 감정이 주를 이루고 있어요';
      case MoodAnalysisLevel.positive:
        return '전반적으로 안정적인 감정 상태를 유지하고 있어요';
      case MoodAnalysisLevel.balanced:
        return '다양한 감정을 고르게 경험하고 있어요';
      case MoodAnalysisLevel.negative:
        return '최근 부정적인 감정이 많이 나타나고 있어요';
      case MoodAnalysisLevel.veryNegative:
        return '힘든 시기를 겪고 있는 것으로 보여요';
    }
  }

  /// 분석 글
  String get message {
    switch (this) {
      case MoodAnalysisLevel.veryPositive:
        return '''전체 감정 기록의 70% 이상이 행복, 설렘, 행운과 같은 긍정 감정으로 나타났습니다. 이는 현재 일상에서 만족감을 주는 활동이나 관계가 안정적으로 유지되고 있다는 신호입니다. 다만 간헐적으로 나타나는 부정 감정도 자연스러운 현상이므로, 이를 억압하기보다는 감정의 원인을 파악하는 것이 중요합니다. 긍정심리학에서는 현재의 긍정 패턴을 강화하기 위해 감사 일지나 강점 기록을 권장합니다. 긍정 감정을 만든 활동이나 사람을 확인하고 이를 주 1회 이상 의도적으로 계획해보세요. 부정 감정이 생길 때 즉시 활용할 수 있는 기분 전환 방법 3가지를 미리 준비해두면 감정 조절에 도움이 됩니다.''';

      case MoodAnalysisLevel.positive:
        return '''긍정 감정이 50~70%로 나타나며 전반적으로 안정적인 감정 상태를 보이고 있습니다. 간헐적으로 나타나는 부정 감정은 일상의 스트레스에 대한 정상적인 반응이며, 다시 긍정 상태로 회복되는 패턴이 관찰됩니다. 이는 스스로 감정을 조절하는 회복탄력성이 작동하고 있다는 증거입니다. 인지행동치료에서는 부정 감정의 원인을 파악하고 대처 전략을 구체화하는 것을 강조합니다. 부정 감정이 나타나는 요일, 시간대, 장소를 기록하여 패턴을 찾아보세요. 반복되는 스트레스 요인에 대해서는 회피 가능 여부를 검토하고, 불가피한 상황에는 심호흡이나 짧은 산책 같은 대처 루틴을 만들어보세요.''';

      case MoodAnalysisLevel.balanced:
        return '''긍정과 부정 감정이 비슷한 비율로 나타나 감정 변화가 큰 상태입니다. 이는 외부 환경이나 생활 패턴의 불규칙성이 감정에 영향을 미치고 있을 가능성을 시사합니다. 감정 기복이 클수록 심리적 안정감이 떨어지고 스트레스 대처가 어려워질 수 있습니다. 정서조절이론에서는 규칙적인 생활 리듬이 감정 안정화의 기초라고 봅니다. 1주일 동안 수면과 식사 시간을 일정하게 유지하며 감정 변화를 관찰해보세요. 에너지를 소모시키는 관계나 상황을 파악하여 만남 빈도를 조정하고, 하루 30분 정도 스마트폰 없이 혼자만의 시간을 확보하는 것이 도움이 됩니다.''';

      case MoodAnalysisLevel.negative:
        return '''부정 감정이 50~70% 정도 나타났네요. 누구나 겪는 일시적인 슬럼프일 수 있어요! 스트레스가 쌓이거나 피곤할 때 이런 패턴이 나타나곤 합니다. 언제, 어떤 상황에서 부정 감정이 생겼는지 체크해보면 원인을 찾기 쉬워요. 행동활성화 이론에 따르면, 기분이 별로일 때일수록 작은 긍정 활동을 시작하는 게 효과적이라고 해요. 좋아하는 음악 들으며 산책하기, 맛있는 거 먹기, 친구랑 수다 떨기 등 가벼운 것부터 시작해보세요. 생각보다 금방 기분이 나아질 거예요. 괜찮아요, 이런 날도 있는 거죠!''';

      case MoodAnalysisLevel.veryNegative:
        return '''부정 감정이 70% 이상 나타났어요. 요즘 많이 힘들었나봐요. 하지만 괜찮아요, 슬럼프는 지나가기 마련이니까요! 지금은 무리하지 말고 자신에게 좀 더 친절해질 시간이에요. 작은 것부터 시작해보세요. 맛있는 음식 먹기, 충분히 자기, 햇빛 쬐며 짧게 산책하기. 이런 작은 변화들이 모여 기분을 끌어올려줄 거예요. 혼자 있기 답답하면 친한 사람에게 연락해서 수다 떨어보세요. 생각보다 많은 사람들이 비슷한 경험을 하고 있고, 대화만으로도 마음이 훨씬 가벼워질 수 있어요. 지금은 조금 힘들어도 분명 나아질 거예요. 화이팅!''';
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
