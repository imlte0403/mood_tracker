import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_tracker/constants/app_color.dart';
import 'package:mood_tracker/constants/app_typography.dart';
import 'package:mood_tracker/constants/gaps.dart';
import 'package:mood_tracker/core/models/emotion_type.dart';

import 'package:mood_tracker/core/models/timeline_entry.dart';

class DailyTimeline extends StatelessWidget {
  const DailyTimeline({
    super.key,
    required this.selectedDate,
    required this.entries,
  });

  final DateTime selectedDate;
  final AsyncValue<List<TimelineEntry>> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.labelMedium?.copyWith(
      fontFamily: AppFonts.playfair,
      fontWeight: FontWeight.w600,
    );
    final timeStyle = theme.textTheme.bodySmall?.copyWith(
      fontFamily: AppFonts.playfair,
      fontWeight: FontWeight.w600,
    );
    final slotLabelStyle = theme.textTheme.bodySmall?.copyWith(
      fontFamily: AppFonts.playfair,
      color: AppColors.placeholder,
    );
    final moodTitleStyle = theme.textTheme.titleSmall?.copyWith(
      fontFamily: AppFonts.playfair,
      fontWeight: FontWeight.w600,
    );
    final messageStyle = theme.textTheme.bodyMedium?.copyWith(
      fontFamily: AppFonts.playfair,
    );

    return Card(
      elevation: 3,
      color: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(flex: 2, child: Text('Time', style: headerStyle)),
                Expanded(flex: 10, child: Text('Mood', style: headerStyle)),
              ],
            ),
            Gaps.v8,
            Expanded(
              child: entries.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const _EmptyTimeline();
                  }
                  final slots = <int>[6, 9, 12, 15, 18, 21, 0];
                  return ListView.builder(
                    itemCount: slots.length,
                    itemBuilder: (context, index) {
                      final hour = slots[index];
                      final slotEntries = items
                          .where((entry) => entry.timestamp.hour == hour)
                          .toList();
                      final slotLabel = _formatHour(hour);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(slotLabel, style: slotLabelStyle),
                                  if (slotEntries.isEmpty)
                                    const SizedBox(height: 12)
                                  else
                                    ...slotEntries.map((entry) {
                                      final timeLabel = TimeOfDay.fromDateTime(
                                        entry.timestamp,
                                      ).format(context);
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Text(
                                          timeLabel,
                                          style: timeStyle,
                                        ),
                                      );
                                    }),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (slotEntries.isEmpty)
                                    const SizedBox(height: 12)
                                  else
                                    ...slotEntries.map(
                                      (entry) => Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: entry.emotion.color
                                                .withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${entry.emotion.emoji} ${entry.emotion.displayNameEn}',
                                                style: moodTitleStyle,
                                              ),
                                              if (entry.message != null &&
                                                  entry.message!.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 8,
                                                      ),
                                                  child: Text(
                                                    entry.message!,
                                                    style: messageStyle,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    Center(child: Text('데이터를 불러오지 못했어요\n${error.toString()}')),
              ),
            ),
          ],
        ),
      ),
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
          fontFamily: AppFonts.playfair,
        ),
      ),
    );
  }
}

String _formatHour(int hour) {
  final normalized = hour % 24;
  return '${normalized.toString().padLeft(2, '0')}:00';
}
