import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_tracker/core/constants/app_color.dart';
import 'package:mood_tracker/core/constants/app_text_styles.dart';
import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/models/emotion_type.dart';

import 'package:mood_tracker/core/models/timeline_entry.dart';
import 'package:mood_tracker/core/utils/firebase_error_handler.dart';
import 'package:mood_tracker/features/home/home_viewmodel.dart';
import 'package:mood_tracker/features/post/post_screen.dart';

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

            final slotWidgets = _buildSlotSections(
              items: items,
              timeStyle: timeStyle,
              slotLabelStyle: slotLabelStyle,
              moodTitleStyle: moodTitleStyle,
              messageStyle: messageStyle,
              stackLabelStyle: stackLabelStyle,
              stackHintStyle: stackHintStyle,
              onEdit: (timelineEntry) =>
                  context.push(PostScreen.routeURL, extra: timelineEntry),
              onDelete: (timelineEntry) =>
                  _confirmDelete(context, ref, timelineEntry),
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
          color: AppColors.bgWhite,
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
                    Expanded(flex: 10, child: Text('Mood', style: headerStyle)),
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

const String _stackHintText = '카드를 눌러 열어볼 수 있어요';

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

List<Widget> _buildSlotSections({
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
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              color: AppColors.placeholder.withOpacity(0.2),
              thickness: 1,
              height: 1,
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

  @override
  Widget build(BuildContext context) {
    final label = slot.label;
    final entries = slot.entries;
    final firstEntryTime = slot.firstEntryTime(context);

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
                Text(label, style: slotLabelStyle),
                if (firstEntryTime != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(firstEntryTime, style: timeStyle),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 10,
            child: entries.isEmpty
                ? const SizedBox(height: 52)
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
                          Row(
                            children: [
                              const Icon(
                                Icons.layers,
                                size: 16,
                                color: AppColors.placeholder,
                              ),
                              const SizedBox(width: 4),
                              if (stackLabelStyle != null)
                                Text(
                                  '${entries.length}개의 기록이 있어요',
                                  style: stackLabelStyle,
                                ),
                              if (stackHintStyle != null) ...[
                                const SizedBox(width: 8),
                                Text(_stackHintText, style: stackHintStyle),
                              ],
                            ],
                          ),
                        const SizedBox(height: 12),
                        _StackedEntryCards(
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

class _StackedEntryCards extends StatelessWidget {
  const _StackedEntryCards({
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
    const double overlap = 18;
    const double baseHeight = 128;
    final int layeredCount = entries.length > 1 ? entries.length - 1 : 0;
    final double totalHeight = baseHeight + overlap * layeredCount;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < entries.length; i++)
            Positioned(
              top: overlap * i,
              left: overlap * i,
              right: 0,
              child: _TimelineEntryTile(
                entry: entries[i],
                moodTitleStyle: moodTitleStyle,
                messageStyle: messageStyle,
                onEdit: () => onEdit(entries[i]),
                onDelete: () => onDelete(entries[i]),
              ),
            ),
        ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgBeige,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${entry.emotion.emoji} ${entry.emotion.displayNameEn}',
                      style: moodTitleStyle,
                    ),
                  ),
                  PopupMenuButton<_EntryAction>(
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
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _EntryAction.edit,
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                      PopupMenuItem(
                        value: _EntryAction.delete,
                        child: ListTile(
                          leading: Icon(Icons.delete_outline),
                          title: Text('Delete'),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (entry.message != null && entry.message!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Text(entry.message!, style: messageStyle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _EntryAction { edit, delete }

Future<void> _confirmDelete(
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
