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
        return '''분석 결과, 전체 감정 기록의 70% 이상이 긍정적인 감정으로 나타났습니다. 행복, 설렘, 행운과 같은 긍정 감정이 일상에서 지속적으로 경험되고 있다는 의미예요.

이러한 긍정적 패턴을 유지하기 위해서는 현재 하고 있는 활동이나 관계를 파악하고 지속하는 것이 중요합니다. 감정 기록을 통해 어떤 상황에서 긍정 감정을 더 많이 느끼는지 확인해보세요.

다만 가끔 나타나는 부정 감정도 자연스러운 현상입니다. 이를 부정하기보다는 건강한 감정 조절의 일부로 받아들이고, 긍정적 대처 전략을 준비해두면 더욱 안정적인 감정 상태를 유지할 수 있습니다.''';

      case MoodAnalysisLevel.positive:
        return '''긍정 감정이 50~70% 정도로 나타나 전반적으로 안정적인 감정 상태를 보이고 있습니다. 간헐적으로 나타나는 부정 감정은 일상 스트레스에 대한 정상적인 반응으로 볼 수 있어요.

주목할 점은 부정 감정 후 다시 긍정 감정으로 회복되는 패턴입니다. 이는 스스로 감정을 조절하는 능력이 있다는 신호예요. 부정 감정이 나타날 때 어떤 대처 방법을 사용했는지 기록해두면, 향후 비슷한 상황에서 효과적으로 활용할 수 있습니다.

감정의 기복이 나타나는 시간대나 상황을 파악하면, 스트레스 요인을 미리 관리하고 긍정 감정의 비율을 더 높일 수 있습니다.''';

      case MoodAnalysisLevel.balanced:
        return '''긍정과 부정 감정이 비슷한 비율로 나타나고 있습니다. 이는 다양한 감정을 경험하며 변화하는 시기를 겪고 있다는 뜻이에요.

이러한 균형 상태는 감정 패턴을 이해할 수 있는 좋은 기회입니다. 어떤 상황이나 시간대에 특정 감정이 더 자주 나타나는지 분석해보세요. 패턴을 발견하면 부정 감정을 유발하는 요인을 줄이고, 긍정 감정을 증진시킬 수 있는 활동을 늘릴 수 있습니다.

감정의 다양성 자체는 문제가 아닙니다. 중요한 것은 각 감정을 인식하고 적절히 대응하는 것입니다. 부정 감정이 지속되거나 심화되는 경향이 보인다면, 생활 패턴이나 스트레스 관리 방법을 점검해볼 필요가 있습니다.''';

      case MoodAnalysisLevel.negative:
        return '''최근 기록에서 부정 감정이 50~70%로 나타나 우울, 불안, 분노, 슬픔과 같은 감정을 자주 경험하고 있는 것으로 보입니다.

부정 감정의 지속은 일상 기능에 영향을 줄 수 있으므로 적극적인 대처가 필요합니다. 먼저 부정 감정이 반복되는 패턴이 있는지 확인해보세요. 특정 시간, 장소, 사람과 관련이 있다면 해당 요인을 조절하거나 피하는 것을 고려할 수 있습니다.

규칙적인 수면, 운동, 사회적 교류는 감정 개선에 도움이 됩니다. 또한 신뢰할 수 있는 사람과 감정을 나누는 것도 효과적입니다. 2주 이상 부정 감정이 지속되거나 일상생활에 지장이 있다면, 전문가 상담을 고려해보세요.''';

      case MoodAnalysisLevel.veryNegative:
        return '''분석 결과, 부정 감정이 70% 이상을 차지하고 있어 심리적으로 어려운 시기를 겪고 있는 것으로 판단됩니다.

이 정도 수준의 부정 감정 지속은 우울증이나 불안 장애와 같은 정신건강 문제의 신호일 수 있습니다. 자가 관리만으로는 개선이 어려울 수 있으므로 전문가의 도움을 받는 것을 강력히 권장합니다.

당장 할 수 있는 것: 1) 기본적인 생활 리듬 유지 (식사, 수면), 2) 신뢰할 수 있는 사람에게 현재 상태 알리기, 3) 위급한 경우 즉시 전문 상담 받기.

도움 요청은 약점이 아니라 회복을 위한 중요한 첫걸음입니다. 지금 경험하는 감정은 적절한 도움을 통해 충분히 개선될 수 있습니다.

📞 24시간 위기상담전화: 1577-0199''';
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
