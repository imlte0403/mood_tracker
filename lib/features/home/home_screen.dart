import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mood_tracker/core/constants/app_color.dart';
import 'package:mood_tracker/core/constants/app_text_styles.dart';
import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/features/home/home_viewmodel.dart';
import 'package:mood_tracker/features/home/widget/daily_timeline.dart';
import 'package:mood_tracker/features/home/widget/home_appbar.dart';
import 'package:mood_tracker/features/home/widget/post_btn.dart';
import 'package:mood_tracker/features/home/widget/weekly_calendar.dart';
import 'package:mood_tracker/features/post/post_screen.dart';

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
      backgroundColor: AppColors.bgWhite,
      appBar: const HomeAppBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GreetingSection(name: greetingName),
                  ),
                  Gaps.v8,
                  WeeklyCalendar(
                    weekDates: state.weekDates,
                    selectedDate: state.selectedDate,
                    moodByDate: state.weeklyMoods,
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
                  Gaps.v16,
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
        onPressed: () => context.push(PostScreen.routeURL),
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
    final textTheme = theme.textTheme;
    final helloStyle = AppTextStyles.greetingHello(textTheme);
    final nameStyle = AppTextStyles.greetingName(textTheme);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello,', style: helloStyle),
              Gaps.v4,
              Transform.translate(
                offset: const Offset(0, -8),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: name, style: nameStyle),
                      TextSpan(text: '!', style: helloStyle),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Gaps.h4,
      ],
    );
  }
}
