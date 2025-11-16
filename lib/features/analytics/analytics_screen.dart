import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/constants/sizes.dart';
import 'package:mood_tracker/features/analytics/analytics_viewmodel.dart';
import 'package:mood_tracker/features/analytics/models/analytics_period.dart';
import 'package:mood_tracker/features/analytics/widgets/daily_bar_chart.dart';
import 'package:mood_tracker/features/analytics/widgets/emotion_pie_chart.dart';
import 'package:mood_tracker/features/analytics/widgets/empty_analytics.dart';
import 'package:mood_tracker/features/analytics/widgets/statistics_card.dart';

/// 감정 통계 화면
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  static const String routeName = 'analytics';
  static const String routeURL = '/analytics';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsViewModelProvider);
    final notifier = ref.read(analyticsViewModelProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          '감정 분석',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.refresh(),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.error!,
                        style: TextStyle(color: colorScheme.error),
                      ),
                      Gaps.v16,
                      FilledButton(
                        onPressed: () => notifier.refresh(),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : state.statistics == null || !state.statistics!.hasData
                  ? const EmptyAnalytics()
                  : RefreshIndicator(
                      onRefresh: () => notifier.refresh(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(Sizes.size24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 기간 선택 탭
                            _PeriodSelector(
                              currentPeriod: state.period,
                              onPeriodChanged: notifier.changePeriod,
                            ),
                            Gaps.v24,

                            // 통계 요약 카드
                            StatisticsCard(statistics: state.statistics!),
                            Gaps.v32,

                            // 감정 분포 파이 차트
                            Text(
                              '감정 분포',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Gaps.v16,
                            EmotionPieChart(statistics: state.statistics!),
                            Gaps.v32,

                            // 일별 추세 차트
                            Text(
                              '일별 추세',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Gaps.v16,
                            DailyBarChart(
                                distributions: state.dailyDistributions),
                            Gaps.v32,
                          ],
                        ),
                      ),
                    ),
    );
  }
}

/// 기간 선택 탭
class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.currentPeriod,
    required this.onPeriodChanged,
  });

  final AnalyticsPeriod currentPeriod;
  final Function(AnalyticsPeriod) onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: AnalyticsPeriod.values.map((period) {
        final isSelected = currentPeriod == period;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilledButton(
              onPressed: () => onPeriodChanged(period),
              style: FilledButton.styleFrom(
                backgroundColor: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                foregroundColor: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                period.displayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
