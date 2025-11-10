// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mood_tracker/core/constants/app_color.dart';
import 'package:mood_tracker/core/constants/gaps.dart';

import 'package:mood_tracker/core/models/emotion_type.dart';
import 'package:mood_tracker/core/models/timeline_entry.dart';
import 'package:mood_tracker/core/utils/firebase_error_handler.dart';
import 'package:mood_tracker/features/home/home_viewmodel.dart';

// 무드 포스트 섹션들을 빌드하는 메인 함수
// TimelineEntry 목록을 시간대별 슬롯으로 나누어 UI 구성
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
                    //시간 블록 구분선
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

// 시간 범위를 정의하는 데이터 클래스
class SlotRange {
  const SlotRange({required this.startHour, required this.endHour});

  final int startHour;
  final int endHour;
}

// 하루를 시간대별로 나눈 슬롯 범위 정의 (3시간 단위)
const List<SlotRange> slotRanges = <SlotRange>[
  SlotRange(startHour: 0, endHour: 6),
  SlotRange(startHour: 6, endHour: 9),
  SlotRange(startHour: 9, endHour: 12),
  SlotRange(startHour: 12, endHour: 15),
  SlotRange(startHour: 15, endHour: 18),
  SlotRange(startHour: 18, endHour: 21),
  SlotRange(startHour: 21, endHour: 24),
];

/// 타임라인 슬롯의 뷰모델 클래스
/// 특정 시간 범위의 엔트리들과 표시 정보를 관리
class TimelineSlotViewModel {
  TimelineSlotViewModel({
    required this.range,
    required List<TimelineEntry> entries,
  }) : entries = entries..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  final SlotRange range;
  final List<TimelineEntry> entries;

  String get label => _formatHour(range.startHour);

  String? firstEntryTime(BuildContext context) {
    if (entries.isEmpty) return null;
    return TimeOfDay.fromDateTime(entries.first.timestamp).format(context);
  }

  // 해당 슬롯에 여러 개의 엔트리가 있는지 확인
  bool get hasMultipleEntries => entries.length > 1;
}

// TimelineEntry 목록을 시간대별 슬롯으로 매핑
List<TimelineSlotViewModel> _mapEntriesToSlots(List<TimelineEntry> source) {
  return slotRanges
      .map(
        (range) => TimelineSlotViewModel(
          range: range,
          entries: source.where((item) => _isWithinRange(item, range)).toList(),
        ),
      )
      .toList();
}

// 엔트리가 특정 시간 범위 내에 있는지 확인
bool _isWithinRange(TimelineEntry entry, SlotRange range) {
  final hour = entry.timestamp.hour;
  final bool isStartIncluded = hour >= range.startHour;
  final bool isEndExcluded = hour < range.endHour;

  if (range.endHour <= range.startHour) {
    return isStartIncluded || hour < range.endHour;
  }

  return isStartIncluded && isEndExcluded;
}

// 시간대별 슬롯을 표시하는 섹션 위젯
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

  final String _swipeHintText = '옆으로 넘기면 더 많은 기록을 볼 수 있어요';

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

// 여러 엔트리를 가로 스크롤로 표시하는 캐러셀 위젯
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

// 개별 타임라인 엔트리를 표시하는 타일 위젯
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
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: entry.emotion.color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: entry.emotion.color.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: entry.emotion.color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: entry.emotion.color.withOpacity(0.4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            Gaps.h10,
                            Text(
                              entry.emotion.displayNameKo,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 메뉴{edit, delete} 버튼
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
                                fontFamily: 'Pretendard',
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
                                fontFamily: 'Pretendard',
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

// 시간 표시 형식
String _formatHour(int hour) {
  final normalized = hour % 24;
  return '${normalized.toString().padLeft(2, '0')}:00';
}

// 엔트리 삭제 확인 alert + 삭제 처리
Future<void> confirmDelete(
  BuildContext context,
  WidgetRef ref,
  TimelineEntry entry,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('기록을 삭제할까요?'),
        content: const Text('삭제한 기록은 다시 되돌릴 수 없어요.'),
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
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('기록을 지웠어요.')),
      );
    }
  } catch (error, _) {
    final message = FirebaseErrorHandler.getErrorMessage(error);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
