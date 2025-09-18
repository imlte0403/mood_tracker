import 'package:flutter/material.dart';
import 'package:mood_tracker/constants/app_color.dart';
import 'package:mood_tracker/constants/app_typography.dart';
import 'package:mood_tracker/constants/gaps.dart';

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

    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontFamily: AppFonts.playfair,
      fontWeight: FontWeight.w700,
    );
    final labelStyle = theme.textTheme.labelLarge?.copyWith(
      fontFamily: AppFonts.playfair,
      fontWeight: FontWeight.w400,
    );
    final dayNumberStyle = theme.textTheme.labelLarge?.copyWith(
      //fontFamily: AppFonts.playfair,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    return Card(
      elevation: 2,
      color: AppColors.bgWhite,
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
                final color = emotion?.color ?? theme.dividerColor;
                final weekday = weekdayLabels[date.weekday % 7];
                return GestureDetector(
                  onTap: () => onSelectDate(normalized),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 40,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.18)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(weekday, style: labelStyle),
                        const SizedBox(height: 8),
                        CircleAvatar(
                          radius: 13,
                          backgroundColor: color,
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
