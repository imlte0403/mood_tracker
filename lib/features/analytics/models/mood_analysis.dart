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
        return '''부정 감정이 50~70%를 차지하며 요즘 힘든 시간을 보내고 있는 것 같습니다. 스트레스가 쌓이거나 컨디션이 좋지 않을 때 이런 패턴이 나타날 수 있어요. 부정 감정이 반복되는 상황이나 시간대를 확인해보면 원인을 파악하는 데 도움이 됩니다. 행동활성화 이론에서는 기분이 좋지 않을 때일수록 작은 긍정 활동을 시작하는 것이 중요하다고 합니다. 충분한 수면을 취하고, 짧게라도 산책하거나 좋아하는 활동을 해보세요. 가까운 사람과 대화를 나누는 것만으로도 기분 전환에 도움이 됩니다. 무리하지 말고 자신의 속도대로 천천히 회복해나가면 됩니다.''';

      case MoodAnalysisLevel.veryNegative:
        return '''부정 감정이 70% 이상으로 나타나 많이 힘든 시기를 겪고 있는 것 같습니다. 이럴 때일수록 자신을 너무 몰아붙이지 말고, 충분히 쉬는 시간을 가지는 것이 중요합니다. 기분이 안 좋은 상태가 계속되면 일상의 작은 것들도 버겁게 느껴질 수 있어요. 우선 기본적인 것부터 챙겨보세요. 규칙적으로 식사하고, 가능한 범위에서 수면 패턴을 유지하며, 잠깐이라도 밖에 나가 햇빛을 쬐는 것이 도움이 됩니다. 혼자 있기 힘들다면 가족이나 친구에게 연락해보세요. 대화만으로도 마음이 한결 가벼워질 수 있습니다. 힘든 감정이 오래 지속되어 일상생활이 어렵다면, 주변에 도움을 요청하는 것도 좋은 방법입니다.''';
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
