// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_tracker/core/constants/app_text_styles.dart';
import 'package:mood_tracker/core/constants/app_color.dart';
import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/constants/sizes.dart';

class UpdatesScreen extends StatelessWidget {
  static const routeName = 'updates';
  static const routeURL = '/settings/updates';

  const UpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Updates",
          style: AppTextStyles.authAppBar(
            Theme.of(context).textTheme,
          )?.copyWith(fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.0,
          ),
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Sizes.size20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentVersion(context),
              Gaps.v24,

              _buildUpdateCard(
                context,
                "Version 1.0.0",
                "초기 출시 🎉",
                DateTime.now(),
                [
                  "감정 기록 및 추적 기능",
                  "주간 캘린더로 감정 패턴 확인",
                  "일기 작성 및 편집",
                  "다양한 감정 표현 (원형, 사각형, 삼각형)",
                  "Google 로그인 지원",
                  "다크모드 지원",
                  "개인정보 보호 정책",
                ],
                isLatest: true,
              ),

              Gaps.v24,

              _buildUpcomingFeatures(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentVersion(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(Sizes.size20),
      decoration: BoxDecoration(
        color: AppColors.point.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.point.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.point, size: 24),
          Gaps.h12,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "현재 버전",
                style: AppTextStyles.settings(context).copyWith(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                "Version 1.0.0",
                style: AppTextStyles.authAppBar(
                  Theme.of(context).textTheme,
                )?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.size12,
              vertical: Sizes.size4,
            ),
            decoration: BoxDecoration(
              color: AppColors.point,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "최신",
              style: AppTextStyles.settings(context).copyWith(
                color: colorScheme.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard(
    BuildContext context,
    String version,
    String title,
    DateTime date,
    List<String> features, {
    bool isLatest = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(Sizes.size20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                version,
                style: AppTextStyles.authAppBar(
                  Theme.of(context).textTheme,
                )?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Gaps.h8,
              if (isLatest)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.size8,
                    vertical: Sizes.size2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.point.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "NEW",
                    style: AppTextStyles.settings(context).copyWith(
                      color: AppColors.point,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          Gaps.v4,
          Text(
            title,
            style: AppTextStyles.authAppBar(
              Theme.of(context).textTheme,
            )?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Gaps.v8,
          Text(
            "${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}",
            style: AppTextStyles.settings(context).copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          Gaps.v16,
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: Sizes.size8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.point,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Gaps.h12,
                  Expanded(
                    child: Text(
                      feature,
                      style: AppTextStyles.settings(
                        context,
                      ).copyWith(fontSize: 15, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "예정된 기능",
          style: AppTextStyles.authAppBar(
            Theme.of(context).textTheme,
          )?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Gaps.v16,
        Container(
          padding: const EdgeInsets.all(Sizes.size20),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.upcoming,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  Gaps.h8,
                  Text(
                    "Version 1.1.0 (예정)",
                    style: AppTextStyles.authAppBar(
                      Theme.of(context).textTheme,
                    )?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Gaps.v12,
              ...[
                "감정 통계 및 인사이트",
                "월간/연간 감정 리포트",
                "감정 패턴 알림",
                "더 많은 감정 표현 추가",
              ].map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: Sizes.size8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Gaps.h12,
                      Expanded(
                        child: Text(
                          feature,
                          style: AppTextStyles.settings(context).copyWith(
                            fontSize: 15,
                            height: 1.4,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
