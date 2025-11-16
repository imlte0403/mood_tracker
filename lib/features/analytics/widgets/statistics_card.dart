import 'package:flutter/material.dart';
import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/constants/sizes.dart';
import 'package:mood_tracker/features/analytics/models/mood_statistics.dart';

/// 주요 통계 카드 위젯
class StatisticsCard extends StatelessWidget {
  const StatisticsCard({
    super.key,
    required this.statistics,
  });

  final MoodStatistics statistics;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (!statistics.hasData) {
      return _EmptyCard(colorScheme: colorScheme);
    }

    return Container(
      padding: const EdgeInsets.all(Sizes.size20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(Sizes.size16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '통계 요약',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Gaps.v16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: '총 기록',
                value: '${statistics.totalEntries}회',
                colorScheme: colorScheme,
              ),
              _StatItem(
                label: '가장 많은 감정',
                value: statistics.mostFrequent != null
                    ? '${statistics.mostFrequent!.emoji} ${statistics.mostFrequent!.displayNameKo}'
                    : '-',
                colorScheme: colorScheme,
              ),
              _StatItem(
                label: '감정 다양성',
                value: '${statistics.emotionDiversity}/8',
                colorScheme: colorScheme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  final String label;
  final String value;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Gaps.v4,
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sizes.size32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(Sizes.size16),
      ),
      child: Center(
        child: Text(
          '아직 충분한 기록이 없어요',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
