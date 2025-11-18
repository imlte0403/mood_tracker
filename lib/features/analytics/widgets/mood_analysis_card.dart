import 'package:flutter/material.dart';
import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/constants/sizes.dart';
import 'package:mood_tracker/features/analytics/models/mood_analysis.dart';

/// 감정 분석 카드 위젯
class MoodAnalysisCard extends StatelessWidget {
  const MoodAnalysisCard({
    super.key,
    required this.analysis,
  });

  final MoodAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final level = analysis.level;

    return Container(
      padding: const EdgeInsets.all(Sizes.size20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(level, colorScheme),
        ),
        borderRadius: BorderRadius.circular(Sizes.size20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘과 제목
          Row(
            children: [
              Text(
                level.icon,
                style: const TextStyle(fontSize: 32),
              ),
              Gaps.h12,
              Expanded(
                child: Text(
                  level.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          Gaps.v16,

          // 분석 글
          Text(
            level.message,
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: colorScheme.onSurface.withValues(alpha: 0.85),
              letterSpacing: -0.2,
            ),
          ),
          Gaps.v16,

          // 감정 비율 표시
          Row(
            children: [
              _PercentageChip(
                label: '긍정',
                percentage: analysis.positivePercentage,
                color: Colors.green.shade400,
                colorScheme: colorScheme,
              ),
              Gaps.h8,
              _PercentageChip(
                label: '부정',
                percentage: analysis.negativePercentage,
                color: Colors.red.shade400,
                colorScheme: colorScheme,
              ),
              Gaps.h8,
              _PercentageChip(
                label: '보통',
                percentage: 100 -
                    analysis.positivePercentage -
                    analysis.negativePercentage,
                color: Colors.grey.shade400,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 레벨에 따른 그라데이션 색상
  List<Color> _getGradientColors(
      MoodAnalysisLevel level, ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

    switch (level) {
      case MoodAnalysisLevel.veryPositive:
        return isDark
            ? [
                Colors.pink.shade900.withValues(alpha: 0.3),
                Colors.orange.shade900.withValues(alpha: 0.3)
              ]
            : [
                Colors.pink.shade50,
                Colors.orange.shade50,
              ];

      case MoodAnalysisLevel.positive:
        return isDark
            ? [
                Colors.yellow.shade900.withValues(alpha: 0.3),
                Colors.amber.shade900.withValues(alpha: 0.3)
              ]
            : [
                Colors.yellow.shade50,
                Colors.amber.shade50,
              ];

      case MoodAnalysisLevel.balanced:
        return isDark
            ? [
                Colors.blue.shade900.withValues(alpha: 0.3),
                Colors.teal.shade900.withValues(alpha: 0.3)
              ]
            : [
                Colors.blue.shade50,
                Colors.teal.shade50,
              ];

      case MoodAnalysisLevel.negative:
        return isDark
            ? [
                Colors.indigo.shade900.withValues(alpha: 0.3),
                Colors.blue.shade900.withValues(alpha: 0.3)
              ]
            : [
                Colors.indigo.shade50,
                Colors.blue.shade50,
              ];

      case MoodAnalysisLevel.veryNegative:
        return isDark
            ? [
                Colors.deepPurple.shade900.withValues(alpha: 0.3),
                Colors.purple.shade900.withValues(alpha: 0.3)
              ]
            : [
                Colors.deepPurple.shade50,
                Colors.purple.shade50,
              ];
    }
  }
}

/// 비율 칩
class _PercentageChip extends StatelessWidget {
  const _PercentageChip({
    required this.label,
    required this.percentage,
    required this.color,
    required this.colorScheme,
  });

  final String label;
  final double percentage;
  final Color color;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Gaps.h6,
          Text(
            '$label ${percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
