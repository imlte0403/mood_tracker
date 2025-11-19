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
        return '''전체 기록의 70% 이상이 긍정 감정입니다. 이 패턴을 유지하려면 원인을 파악해야 합니다.

원인 분석: 긍정 감정이 많았던 날의 공통점을 찾아보세요.
• 누구와 함께 있었나요? (특정 사람, 혼자)
• 어떤 활동을 했나요? (운동, 취미, 업무)
• 시간대가 영향을 주나요? (아침, 저녁)

실천 방법:
1. 긍정 감정을 만든 활동/사람을 주 1회 이상 의도적으로 계획하기
2. 부정 감정이 생길 때를 대비해 즉시 기분 전환할 수 있는 활동 3가지 리스트업
3. 현재의 루틴 중 유지할 것과 버릴 것 구분하기''';

      case MoodAnalysisLevel.positive:
        return '''긍정 감정 50~70%, 부정 감정 30~50%로 전반적으로 양호합니다. 부정 감정의 원인을 찾으면 긍정 비율을 더 높일 수 있습니다.

원인 분석: 부정 감정이 나타나는 패턴을 확인하세요.
• 특정 요일이나 시간대에 집중되나요? (월요일, 저녁)
• 특정 장소나 상황과 연관되나요? (직장, 집, 특정 모임)
• 수면, 식사, 신체 컨디션과 관련 있나요?

실천 방법:
1. 부정 감정 기록 시 "왜"를 한 줄 더 적기 (예: "불안 - 내일 발표 때문")
2. 반복되는 스트레스 요인은 회피 가능한지 검토 (예: 특정 시간대 업무 조정)
3. 회피 불가능한 요인은 대처 루틴 만들기 (예: 발표 전 10분 심호흡)''';

      case MoodAnalysisLevel.balanced:
        return '''긍정과 부정이 비슷한 비율입니다. 감정 기복이 큰 상태로, 안정화가 필요합니다.

원인 분석: 기복을 만드는 변수를 찾으세요.
• 일정이 불규칙한가요? (수면 시간, 식사 시간)
• 대인 관계에서 에너지 소모가 큰가요?
• 예상치 못한 일이 자주 생기나요?

실천 방법:
1. 1주일간 수면/식사 시간 고정하고 감정 변화 관찰
2. 에너지를 빼앗는 관계는 만남 빈도 줄이기
3. 하루 중 30분 "나만의 시간" 확보 (스마트폰 X, 조용한 활동)
4. 변수를 하나씩 조절하며 무엇이 안정에 도움 되는지 테스트''';

      case MoodAnalysisLevel.negative:
        return '''부정 감정이 50~70%입니다. 주요 스트레스 요인을 찾아 즉시 대응해야 합니다.

원인 분석: 3가지 질문에 답해보세요.
1. 가장 자주 느끼는 부정 감정은? (우울/불안/분노/슬픔)
2. 언제부터 이렇게 힘들었나요? (1개월 전? 특정 사건 후?)
3. 스트레스 요인 톱3은? (업무, 관계, 건강, 금전 등)

즉시 실행:
• 오늘부터 7일간: 7시간 이상 수면 + 하루 15분 걷기 실천
• 스트레스 요인 중 1개는 이번 주 안에 해결 시도 (미룬 일 처리, 거절 연습 등)
• 신뢰하는 사람 1명에게 힘든 상황 공유
• 2주 후에도 개선 없으면 전문가 상담 예약''';

      case MoodAnalysisLevel.veryNegative:
        return '''부정 감정이 70% 이상입니다. 자가 관리로는 한계가 있으므로 전문가 도움이 필요합니다.

원인 분석: 지금 답하기 어려워도 메모해두세요.
• 이 상태가 언제부터였나요? (2주? 1개월? 그 이상?)
• 특정 사건이 계기였나요, 아니면 서서히 악화됐나요?
• 일상생활에 지장이 있나요? (식사, 수면, 출근, 관계)

오늘 당장 할 것:
1. 전문 상담 예약 (정신건강의학과, 심리상담센터)
2. 가족이나 가까운 친구에게 현재 상태 알리기
3. 자해/자살 생각이 들면 즉시 위기상담전화 연결

위급하지 않더라도 혼자 버티지 마세요. 전문가는 당신이 보지 못하는 해결책을 제시할 수 있습니다.

📞 24시간 위기상담전화: 1577-0199
📞 정신건강위기상담: 1577-0199
📞 자살예방상담: 1393''';
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
