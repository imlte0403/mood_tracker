import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mood_tracker/core/models/emotion_type.dart';
import 'package:mood_tracker/features/analytics/models/mood_statistics.dart';

/// 감정 분포 파이 차트
class EmotionPieChart extends StatefulWidget {
  const EmotionPieChart({
    super.key,
    required this.statistics,
  });

  final MoodStatistics statistics;

  @override
  State<EmotionPieChart> createState() => _EmotionPieChartState();
}

class _EmotionPieChartState extends State<EmotionPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!widget.statistics.hasData) {
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
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: _getSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    final entries = widget.statistics.emotionCounts.entries.toList();

    return List.generate(entries.length, (index) {
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 16.0 : 14.0;
      final radius = isTouched ? 65.0 : 55.0;

      final emotion = entries[index].key;
      final count = entries[index].value;
      final percentage = widget.statistics.emotionPercentages[emotion] ?? 0;

      return PieChartSectionData(
        color: emotion.color,
        value: count.toDouble(),
        title: isTouched
            ? '${emotion.displayNameKo}\n${percentage.toStringAsFixed(1)}%'
            : emotion.emoji,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }
}
