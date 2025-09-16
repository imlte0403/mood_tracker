import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mood_tracker/constants/app_color.dart';
import 'package:mood_tracker/constants/app_typography.dart';
import 'package:mood_tracker/constants/gaps.dart';
import 'package:mood_tracker/constants/sizes.dart';
import 'package:mood_tracker/features/home/home_viewmodel.dart';
import 'package:mood_tracker/features/home/widget/daily_timeline.dart';
import 'package:mood_tracker/features/home/widget/home_appbar.dart';
import 'package:mood_tracker/features/home/widget/post_btn.dart';
import 'package:mood_tracker/features/home/widget/weekly_calendar.dart';

class HomeScreen extends ConsumerWidget {
  static const String routeName = 'home';
  static const String routeURL = '/';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final notifier = ref.read(homeViewModelProvider.notifier);

    final greetingName = state.displayName ?? 'Username';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HomeAppBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GreetingSection(name: greetingName),
                  Gaps.v16,
                  WeeklyCalendar(
                    weekDates: state.weekDates,
                    selectedDate: state.selectedDate,
                    moodByDate: state.weeklyDemoMoods,
                    onPrevWeek: () {
                      notifier.selectDate(
                        state.selectedDate.subtract(
                          const Duration(days: DateTime.daysPerWeek),
                        ),
                      );
                    },
                    onNextWeek: () {
                      notifier.selectDate(
                        state.selectedDate.add(
                          const Duration(days: DateTime.daysPerWeek),
                        ),
                      );
                    },
                    onSelectDate: notifier.selectDate,
                  ),
                  Gaps.v24,
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverFillRemaining(
              hasScrollBody: true,
              child: DailyTimeline(
                selectedDate: state.selectedDate,
                entries: state.entries,
              ),
            ),
          ),
          SliverToBoxAdapter(child: Gaps.v80),
        ],
      ),
      floatingActionButton: PostBtn(
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text(
                '새 감정 기록 기능은 준비 중입니다.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: AppFonts.playfair,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final helloStyle = theme.textTheme.headlineMedium?.copyWith(
      fontFamily: AppFonts.playfair,
      fontWeight: FontWeight.w600,
      color: AppColors.text,
    );
    final nameStyle = theme.textTheme.headlineMedium?.copyWith(
      fontFamily: AppFonts.playfair,
      fontWeight: FontWeight.w700,
      color: AppColors.point,
    );
    final punctuationStyle = theme.textTheme.headlineMedium?.copyWith(
      fontFamily: AppFonts.playfair,
      fontWeight: FontWeight.w600,
      color: AppColors.text,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hello,', style: helloStyle),
        Gaps.v4,
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: name, style: nameStyle),
              TextSpan(text: '!', style: punctuationStyle),
            ],
          ),
          style: punctuationStyle?.copyWith(fontSize: Sizes.size36),
        ),
      ],
    );
  }
}
