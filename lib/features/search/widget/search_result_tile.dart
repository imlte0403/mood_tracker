import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mood_tracker/core/constants/app_text_styles.dart';
import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/models/emotion_type.dart';
import 'package:mood_tracker/core/models/timeline_entry.dart';
import 'package:mood_tracker/core/widgets/emotion_shape_badge.dart';

class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final TimelineEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateText = DateFormat('yy.MM.dd, HH:mm').format(entry.timestamp);
    final textTheme = Theme.of(context).textTheme;
    final emotionStyle = AppTextStyles.timelineMoodTitle(textTheme);
    final message = entry.message?.trim();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              EmotionShapeBadge(emotion: entry.emotion, size: 42),
              Gaps.h12,
              Expanded(
                child: Text(
                  entry.emotion.displayNameKo,
                  style:
                      emotionStyle?.copyWith(color: colorScheme.onSurface) ??
                      TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                ),
              ),
              PopupMenuButton<_EntryMenuAction>(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.more_horiz,
                  color: colorScheme.onSurfaceVariant,
                  size: 18,
                ),
                onSelected: (action) {
                  switch (action) {
                    case _EntryMenuAction.edit:
                      onEdit();
                      break;
                    case _EntryMenuAction.delete:
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _EntryMenuAction.edit,
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: colorScheme.onSurface,
                        ),
                        Gaps.h8,
                        const Text('수정'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _EntryMenuAction.delete,
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: colorScheme.error,
                        ),
                        Gaps.h8,
                        const Text('삭제'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (message != null && message.isNotEmpty) ...[
            Gaps.v12,
            Text(
              message,
              style: AppTextStyles.timelineMessage(
                textTheme,
              )?.copyWith(color: colorScheme.onSurface),
            ),
          ],
          Gaps.v12,
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              dateText,
              style: AppTextStyles.timelineTime(textTheme)?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _EntryMenuAction { edit, delete }
