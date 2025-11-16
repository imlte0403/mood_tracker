import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mood_tracker/features/analytics/models/daily_mood_distribution.dart';

/// 일별 감정 분포 막대 차트
class DailyBarChart extends StatelessWidget {
  const DailyBarChart({
    super.key,
    required this.distributions,
  });

  final List<DailyMoodDistribution> distributions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (distributions.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            '데이터가 없습니다',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => colorScheme.surfaceContainerHighest,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final distribution = distributions[group.x.toInt()];
                return BarTooltipItem(
                  '${distribution.formattedDate}\n${distribution.totalCount}회',
                  TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < distributions.length) {
                    final distribution = distributions[value.toInt()];
                    // 짧은 날짜 형식 (예: 11/16 -> 16)
                    final day = distribution.date.day.toString();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        day,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max || value == meta.min) {
                    return const SizedBox();
                  }
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                strokeWidth: 1,
              );
            },
          ),
          barGroups: _getBarGroups(),
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    return List.generate(distributions.length, (index) {
      final distribution = distributions[index];
      final color = distribution.dominantEmotion?.color ?? Colors.grey;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: distribution.totalCount.toDouble(),
            color: color,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  double _getMaxY() {
    if (distributions.isEmpty) return 10;

    final maxCount = distributions
        .map((d) => d.totalCount)
        .reduce((a, b) => a > b ? a : b);

    // 최대값보다 약간 큰 값으로 설정
    return (maxCount + 2).toDouble();
  }
}
