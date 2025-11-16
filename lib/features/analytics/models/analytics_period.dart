/// 통계 기간
enum AnalyticsPeriod {
  week, // 최근 7일
  month, // 최근 30일
  all; // 전체

  String get displayName {
    switch (this) {
      case AnalyticsPeriod.week:
        return '주간';
      case AnalyticsPeriod.month:
        return '월간';
      case AnalyticsPeriod.all:
        return '전체';
    }
  }

  /// 시작 날짜 계산 (오늘 기준)
  DateTime getStartDate() {
    final now = DateTime.now();
    switch (this) {
      case AnalyticsPeriod.week:
        return now.subtract(const Duration(days: 6)); // 오늘 포함 7일
      case AnalyticsPeriod.month:
        return now.subtract(const Duration(days: 29)); // 오늘 포함 30일
      case AnalyticsPeriod.all:
        return DateTime(2000); // 충분히 과거 날짜
    }
  }
}
