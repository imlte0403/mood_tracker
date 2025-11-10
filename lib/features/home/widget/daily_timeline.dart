import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mood_tracker/core/constants/app_text_styles.dart';
import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/models/timeline_entry.dart';
import 'package:mood_tracker/core/utils/firebase_error_handler.dart';

import 'package:mood_tracker/features/post/post_edit.dart';
import 'package:mood_tracker/features/home/mood_post.dart';

class DailyTimeline extends ConsumerWidget {
  const DailyTimeline({
    super.key,
    required this.selectedDate,
    required this.entries,
  });

  final DateTime selectedDate;
  final AsyncValue<List<TimelineEntry>> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final headerStyle = AppTextStyles.timelineHeader(theme.textTheme);
    final timeStyle = AppTextStyles.timelineTime(theme.textTheme);
    final slotLabelStyle = AppTextStyles.timelineSlotLabel(theme.textTheme);
    final moodTitleStyle = AppTextStyles.timelineMoodTitle(theme.textTheme);
    final messageStyle = AppTextStyles.timelineMessage(theme.textTheme);
    final stackLabelStyle = AppTextStyles.timelineStackLabel(theme.textTheme);
    final stackHintStyle = AppTextStyles.timelineStackHint(theme.textTheme);

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.maxHeight.isFinite;

        Widget listSection = entries.when(
          data: (items) {
            if (items.isEmpty) {
              return const _EmptyTimeline();
            }

            final slotWidgets = buildMoodPostSections(
              context: context,
              items: items,
              timeStyle: timeStyle,
              slotLabelStyle: slotLabelStyle,
              moodTitleStyle: moodTitleStyle,
              messageStyle: messageStyle,
              stackLabelStyle: stackLabelStyle,
              stackHintStyle: stackHintStyle,
              onEdit: (timelineEntry) =>
                  context.push(PostEditScreen.routeURL, extra: timelineEntry),
              onDelete: (timelineEntry) {
                confirmDelete(context, ref, timelineEntry);
              },
            );

            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: slotWidgets.length,
              shrinkWrap: !hasBoundedHeight,
              physics: hasBoundedHeight
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => slotWidgets[index],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              FirebaseErrorHandler.getErrorMessage(error),
              textAlign: TextAlign.center,
            ),
          ),
        );

        if (hasBoundedHeight) {
          listSection = Expanded(child: listSection);
        }

        return Card(
          elevation: 3,
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: hasBoundedHeight
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(flex: 2, child: Text('Time', style: headerStyle)),
                    Expanded(flex: 10, child: Text('Note', style: headerStyle)),
                  ],
                ),
                Gaps.v8,
                listSection,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        '아직 기록이 없어요.',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: AppFonts.pretendard,
        ),
      ),
    );
  }
}
