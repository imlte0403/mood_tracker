import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_tracker/core/providers/auth_providers.dart';
import 'package:mood_tracker/features/analytics/data/analytics_repository.dart';
import 'package:mood_tracker/features/analytics/models/analytics_period.dart';
import 'package:mood_tracker/features/analytics/models/daily_mood_distribution.dart';
import 'package:mood_tracker/features/analytics/models/mood_statistics.dart';

/// Analytics 상태
class AnalyticsState {
  final AnalyticsPeriod period;
  final MoodStatistics? statistics;
  final List<DailyMoodDistribution> dailyDistributions;
  final bool isLoading;
  final String? error;

  AnalyticsState({
    required this.period,
    this.statistics,
    this.dailyDistributions = const [],
    this.isLoading = false,
    this.error,
  });

  AnalyticsState copyWith({
    AnalyticsPeriod? period,
    MoodStatistics? statistics,
    List<DailyMoodDistribution>? dailyDistributions,
    bool? isLoading,
    String? error,
  }) {
    return AnalyticsState(
      period: period ?? this.period,
      statistics: statistics ?? this.statistics,
      dailyDistributions: dailyDistributions ?? this.dailyDistributions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Analytics ViewModel
class AnalyticsViewModel extends StateNotifier<AnalyticsState> {
  AnalyticsViewModel(this._repository, this._userId)
      : super(AnalyticsState(period: AnalyticsPeriod.week)) {
    loadData();
  }

  final AnalyticsRepository _repository;
  final String _userId;

  /// 데이터 로드
  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final startDate = state.period.getStartDate();
      final endDate = DateTime.now();

      // 통계와 일별 분포 동시에 가져오기
      final results = await Future.wait([
        _repository.getStatistics(
          userId: _userId,
          startDate: startDate,
          endDate: endDate,
        ),
        _repository.getDailyDistribution(
          userId: _userId,
          startDate: startDate,
          endDate: endDate,
        ),
      ]);

      state = state.copyWith(
        statistics: results[0] as MoodStatistics,
        dailyDistributions: results[1] as List<DailyMoodDistribution>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '통계를 불러오는데 실패했습니다: $e',
      );
    }
  }

  /// 기간 변경
  Future<void> changePeriod(AnalyticsPeriod newPeriod) async {
    if (state.period == newPeriod) return;

    state = state.copyWith(period: newPeriod);
    await loadData();
  }

  /// 새로고침
  Future<void> refresh() => loadData();
}

/// Analytics ViewModel Provider
final analyticsViewModelProvider =
    StateNotifierProvider<AnalyticsViewModel, AnalyticsState>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  final userId = ref.watch(authStateProvider).value?.uid ?? '';

  return AnalyticsViewModel(repository, userId);
});
