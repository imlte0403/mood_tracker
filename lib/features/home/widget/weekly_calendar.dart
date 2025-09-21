// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mood_tracker/core/constants/app_text_styles.dart';
import 'package:mood_tracker/core/constants/gaps.dart';

import 'package:mood_tracker/core/models/emotion_type.dart';

class WeeklyCalendar extends StatelessWidget {
  const WeeklyCalendar({
    super.key,
    required this.weekDates,
    required this.selectedDate,
    required this.moodByDate,
    required this.onPrevWeek,
    required this.onNextWeek,
    required this.onSelectDate,
  });

  final List<DateTime> weekDates;
  final DateTime selectedDate;
  final Map<DateTime, EmotionType> moodByDate;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    const weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final titleStyle = AppTextStyles.weeklyCalendarTitle(textTheme);
    final labelStyle = AppTextStyles.weeklyCalendarLabel(textTheme);
    final dayNumberStyle = AppTextStyles.weeklyCalendarDayNumber(textTheme);

    return Card(
      elevation: 2,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 34,
              child: Row(
                children: [
                  IconButton(
                    onPressed: onPrevWeek,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      'Weekly calendar',
                      textAlign: TextAlign.center,
                      style: titleStyle,
                    ),
                  ),
                  IconButton(
                    onPressed: onNextWeek,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            Gaps.v2,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weekDates.map((date) {
                final normalized = DateTime(date.year, date.month, date.day);
                final isSelected =
                    normalized ==
                    DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                    );
                final emotion = moodByDate[normalized];
                final hasMood = emotion != null;
                final baseColor = hasMood
                    ? emotion.color
                    : colorScheme.onSurfaceVariant.withOpacity(0.3);
                final highlightColor = hasMood
                    ? baseColor.withOpacity(0.18)
                    : colorScheme.outlineVariant.withOpacity(0.24);
                final weekday = weekdayLabels[date.weekday % 7];
                return GestureDetector(
                  onTap: () => onSelectDate(normalized),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 40,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? highlightColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(weekday, style: labelStyle),
                        Gaps.v8,
                        CircleAvatar(
                          radius: 13,
                          backgroundColor: baseColor,
                          child: Text('${date.day}', style: dayNumberStyle),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            Gaps.v4,
          ],
        ),
      ),
    );
  }
}
