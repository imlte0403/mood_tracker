import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/constants/sizes.dart';
import 'package:mood_tracker/features/post/post_screen.dart';

/// 통계 데이터가 없을 때 표시하는 위젯
class EmptyAnalytics extends StatelessWidget {
  const EmptyAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 80,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          Gaps.v24,
          Text(
            '아직 충분한 기록이 없어요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Gaps.v8,
          Text(
            '감정을 기록하고 통계를 확인해보세요',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          Gaps.v32,
          FilledButton.icon(
            onPressed: () => context.push(PostScreen.routeURL),
            icon: const Icon(Icons.add),
            label: const Text('감정 기록하기'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.size24,
                vertical: Sizes.size12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
