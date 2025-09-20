import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_tracker/core/constants/app_color.dart';
import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/models/emotion_type.dart';
import 'package:mood_tracker/core/models/timeline_entry.dart';
import 'package:mood_tracker/core/utils/firebase_error_handler.dart';
import 'package:mood_tracker/features/home/home_viewmodel.dart';

List<Widget> buildMoodPostSections({
  required BuildContext context,
  required List<TimelineEntry> items,
  required TextStyle? timeStyle,
  required TextStyle? slotLabelStyle,
  required TextStyle? moodTitleStyle,
  required TextStyle? messageStyle,
  required TextStyle? stackLabelStyle,
  required TextStyle? stackHintStyle,
  required void Function(TimelineEntry) onEdit,
  required void Function(TimelineEntry) onDelete,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final slots = _mapEntriesToSlots(items);
  return slots.asMap().entries.map((entry) {
    final index = entry.key;
    final slot = entry.value;
    return Column(
      children: [
        _SlotSection(
          slot: slot,
          timeStyle: timeStyle,
          slotLabelStyle: slotLabelStyle,
          moodTitleStyle: moodTitleStyle,
          messageStyle: messageStyle,
          stackLabelStyle: stackLabelStyle,
          stackHintStyle: stackHintStyle,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
        if (index < slots.length - 1)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.outlineVariant.withOpacity(0.08),
                          colorScheme.outlineVariant.withOpacity(0.24),
                          colorScheme.outlineVariant.withOpacity(0.08),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }).toList();
}

class _SlotRange {
  const _SlotRange({required this.startHour, required this.endHour});

  final int startHour;
  final int endHour;
}

// 3시간 단위 슬롯
const List<_SlotRange> _slotRanges = <_SlotRange>[
  _SlotRange(startHour: 0, endHour: 6),
  _SlotRange(startHour: 6, endHour: 9),
  _SlotRange(startHour: 9, endHour: 12),
  _SlotRange(startHour: 12, endHour: 15),
  _SlotRange(startHour: 15, endHour: 18),
  _SlotRange(startHour: 18, endHour: 21),
  _SlotRange(startHour: 21, endHour: 24),
];

class TimelineSlotViewModel {
  TimelineSlotViewModel({
    required this.range,
    required List<TimelineEntry> entries,
  }) : entries = entries..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  final _SlotRange range;
  final List<TimelineEntry> entries;

  String get label => _formatHour(range.startHour);

  String? firstEntryTime(BuildContext context) {
    if (entries.isEmpty) return null;
    return TimeOfDay.fromDateTime(entries.first.timestamp).format(context);
  }

  bool get hasMultipleEntries => entries.length > 1;
}

List<TimelineSlotViewModel> _mapEntriesToSlots(List<TimelineEntry> source) {
  return _slotRanges
      .map(
        (range) => TimelineSlotViewModel(
          range: range,
          entries: source.where((item) => _isWithinRange(item, range)).toList(),
        ),
      )
      .toList();
}

bool _isWithinRange(TimelineEntry entry, _SlotRange range) {
  final hour = entry.timestamp.hour;
  final bool isStartIncluded = hour >= range.startHour;
  final bool isEndExcluded = hour < range.endHour;

  if (range.endHour <= range.startHour) {
    return isStartIncluded || hour < range.endHour;
  }

  return isStartIncluded && isEndExcluded;
}

class _SlotSection extends StatelessWidget {
  const _SlotSection({
    required this.slot,
    required this.timeStyle,
    required this.slotLabelStyle,
    required this.moodTitleStyle,
    required this.messageStyle,
    required this.stackLabelStyle,
    required this.stackHintStyle,
    required this.onEdit,
    required this.onDelete,
  });

  final TimelineSlotViewModel slot;
  final TextStyle? timeStyle;
  final TextStyle? slotLabelStyle;
  final TextStyle? moodTitleStyle;
  final TextStyle? messageStyle;
  final TextStyle? stackLabelStyle;
  final TextStyle? stackHintStyle;
  final void Function(TimelineEntry) onEdit;
  final void Function(TimelineEntry) onDelete;

  final String _swipeHintText = 'Swipe to see more';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = slot.label;
    final entries = slot.entries;
    final firstEntryTime = slot.firstEntryTime(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    label,
                    style: slotLabelStyle?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: entries.isNotEmpty
                          ? AppColors.point
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (firstEntryTime != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.point,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Gaps.h6,
                        Text(
                          firstEntryTime,
                          style: timeStyle?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            color: AppColors.point,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Gaps.h16,
          Expanded(
            flex: 10,
            child: entries.isEmpty
                ? Gaps.v60
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!slot.hasMultipleEntries)
                        _TimelineEntryTile(
                          entry: entries.first,
                          moodTitleStyle: moodTitleStyle,
                          messageStyle: messageStyle,
                          onEdit: () => onEdit(entries.first),
                          onDelete: () => onDelete(entries.first),
                        )
                      else ...[
                        if (stackLabelStyle != null || stackHintStyle != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.point.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.point.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.layers_outlined,
                                    size: 12,
                                    color: AppColors.point,
                                  ),
                                ),
                                Gaps.h8,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (stackLabelStyle != null)
                                        Text(
                                          '${entries.length}개의 기록이 있어요',
                                          style: stackLabelStyle?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                            color: AppColors.point,
                                          ),
                                        ),
                                      if (stackHintStyle != null)
                                        Text(
                                          _swipeHintText,
                                          style: stackHintStyle?.copyWith(
                                            fontSize: 10,
                                            color: AppColors.point.withOpacity(
                                              0.7,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Gaps.v16,
                        _TimelineEntryCarousel(
                          entries: entries,
                          moodTitleStyle: moodTitleStyle,
                          messageStyle: messageStyle,
                          onEdit: onEdit,
                          onDelete: onDelete,
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _TimelineEntryCarousel extends StatelessWidget {
  const _TimelineEntryCarousel({
    required this.entries,
    required this.moodTitleStyle,
    required this.messageStyle,
    required this.onEdit,
    required this.onDelete,
  });

  final List<TimelineEntry> entries;
  final TextStyle? moodTitleStyle;
  final TextStyle? messageStyle;
  final void Function(TimelineEntry) onEdit;
  final void Function(TimelineEntry) onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(right: 16),
        itemCount: entries.length,
        separatorBuilder: (context, _) => Gaps.h16,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return SizedBox(
            width: 260,
            child: _TimelineEntryTile(
              entry: entry,
              moodTitleStyle: moodTitleStyle,
              messageStyle: messageStyle,
              onEdit: () => onEdit(entry),
              onDelete: () => onDelete(entry),
            ),
          );
        },
      ),
    );
  }
}

class _TimelineEntryTile extends StatelessWidget {
  const _TimelineEntryTile({
    required this.entry,
    required this.moodTitleStyle,
    required this.messageStyle,
    required this.onEdit,
    required this.onDelete,
  });

  final TimelineEntry entry;
  final TextStyle? moodTitleStyle;
  final TextStyle? messageStyle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onEdit,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 감정 헤더 부분
              Row(
                children: [
                  // 이모지 컨테이너
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: Center(
                      child: Text(
                        entry.emotion.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  Gaps.h16,
                  // 감정 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 감정 이름
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: entry.emotion.color,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            entry.emotion.displayNameEn,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              fontFamily: 'PlayfairDisplay',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 메뉴 버튼
                  PopupMenuButton<_EntryAction>(
                    padding: EdgeInsets.zero,
                    icon: SizedBox(
                      width: 16,
                      height: 16,
                      child: Icon(
                        Icons.more_horiz,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),

                    onSelected: (action) {
                      switch (action) {
                        case _EntryAction.edit:
                          onEdit();
                          break;
                        case _EntryAction.delete:
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _EntryAction.edit,
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: colorScheme.onSurface,
                            ),
                            Gaps.h12,
                            Text(
                              'Edit',
                              style: TextStyle(
                                fontFamily: 'PlayfairDisplay',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: _EntryAction.delete,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              size: 14,
                              color: Colors.redAccent,
                            ),
                            Gaps.h12,
                            const Text(
                              'Delete',
                              style: TextStyle(
                                fontFamily: 'PlayfairDisplay',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // 메시지 부분
              if (entry.message != null && entry.message!.isNotEmpty) ...[
                Gaps.v2,
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.message!,
                    style: messageStyle?.copyWith(
                      fontSize: 12,
                      height: 1.4,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum _EntryAction { edit, delete }

String _formatHour(int hour) {
  final normalized = hour % 24;
  return '${normalized.toString().padLeft(2, '0')}:00';
}

//삭제 기능
Future<void> confirmDelete(
  BuildContext context,
  WidgetRef ref,
  TimelineEntry entry,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (result != true) return;

  try {
    await ref.read(homeViewModelProvider.notifier).deleteEntry(entry.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Entry deleted')));
  } catch (error, _) {
    final message = FirebaseErrorHandler.getErrorMessage(error);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
