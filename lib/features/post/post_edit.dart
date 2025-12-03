import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mood_tracker/core/constants/app_text_styles.dart';
import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/constants/sizes.dart';
import 'package:mood_tracker/core/models/emotion_type.dart';
import 'package:mood_tracker/core/models/timeline_entry.dart';

import 'package:mood_tracker/features/post/model/mood_shape.dart';
import 'package:mood_tracker/features/post/post_viewmodel.dart';

class PostEditScreen extends ConsumerStatefulWidget {
  const PostEditScreen({super.key, this.entry});

  static const String routeName = 'postEdit';
  static const String routeURL = '/post/edit';

  final TimelineEntry? entry;

  @override
  ConsumerState<PostEditScreen> createState() => _PostEditScreenState();
}

class _PostEditScreenState extends ConsumerState<PostEditScreen> {
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(moodEntryFormProvider.notifier);
      if (widget.entry != null) {
        notifier.startEditing(widget.entry!);
      } else {
        notifier.startNew();
      }
      final currentForm = ref.read(moodEntryFormProvider);
      _messageController.text = currentForm.message;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<MoodEntryForm>(moodEntryFormProvider, (previous, next) {
      if (_messageController.text != next.message) {
        _messageController.value = TextEditingValue(
          text: next.message,
          selection: TextSelection.collapsed(offset: next.message.length),
        );
      }
    });

    final form = ref.watch(moodEntryFormProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final Size screenSize = MediaQuery.of(context).size;
    final double journalMinHeight = math.max(screenSize.height * 0.35, 360);

    final EmotionType emotion = form.emotion;
    final MoodShapeSnapshot shape = MoodShapeEngine.resolve(
      MoodShapeEngine.sliderAnchorForEmotion(emotion),
    );

    Future<void> handleSubmit() async {
      if (form.isSubmitting) return;
      FocusScope.of(context).unfocus();

      final notifier = ref.read(moodEntryFormProvider.notifier);
      final success = await notifier.submit();
      if (!mounted) return;

      if (success) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        return;
      }

      final latestForm = ref.read(moodEntryFormProvider);
      final message = latestForm.errorMessage;
      if (message != null && message.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(
          color: colorScheme.onSurface,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(
          form.isEditing ? '감정 기록 수정' : '새 감정 기록',
          style: textTheme.titleMedium?.copyWith(
            fontFamily: AppFonts.playfair,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        tooltip: '기록 저장',
        backgroundColor: colorScheme.primary,
        onPressed: form.isSubmitting ? null : handleSubmit,
        icon: form.isSubmitting
            ? SizedBox(
                width: Sizes.size20,
                height: Sizes.size20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.onPrimary,
                  ),
                ),
              )
            : Icon(Icons.check, color: colorScheme.onPrimary),
        label: Text(
          form.isEditing ? '수정 완료' : '저장',
          style: textTheme.labelLarge?.copyWith(
            fontFamily: AppFonts.playfair,
            fontWeight: FontWeight.w700,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: Sizes.size32,
            right: Sizes.size32,
            bottom: Sizes.size96,
            top: Sizes.size20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '오늘의 감정',
                style: textTheme.titleMedium?.copyWith(
                  fontFamily: AppFonts.playfair,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              Gaps.v16,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: Sizes.size56,
                    height: Sizes.size56,
                    decoration: ShapeDecoration(
                      color: shape.color,
                      shape: shape.shape,
                    ),
                  ),
                  Gaps.h16,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.size8,
                        vertical: Sizes.size4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '감정을 골라주세요',
                            style: textTheme.titleSmall?.copyWith(
                              fontFamily: AppFonts.playfair,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Gaps.v12,
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: EmotionType.values.map((type) {
                                final snapshot = MoodShapeEngine.resolve(
                                  MoodShapeEngine.sliderAnchorForEmotion(type),
                                );
                                final bool isSelected = type == emotion;
                                final Color backgroundColor = isSelected
                                    ? snapshot.color.withOpacity(0.2)
                                    : colorScheme.surfaceContainerHigh;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    right: Sizes.size8,
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.size28,
                                      ),
                                      onTap: form.isSubmitting
                                          ? null
                                          : () {
                                              ref
                                                  .read(
                                                    moodEntryFormProvider
                                                        .notifier,
                                                  )
                                                  .updateEmotion(type);
                                            },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: Sizes.size12,
                                          vertical: Sizes.size8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: backgroundColor,
                                          borderRadius: BorderRadius.circular(
                                            Sizes.size28,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: snapshot.color
                                                        .withOpacity(0.2),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Text(
                                          '${type.emoji} ${type.displayNameKo}',
                                          style: textTheme.bodySmall?.copyWith(
                                            fontFamily: AppFonts.playfair,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? colorScheme.onSurface
                                                : colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Gaps.v24,
              Text(
                '기록 시각',
                style: textTheme.titleMedium?.copyWith(
                  fontFamily: AppFonts.playfair,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              Gaps.v12,
              Container(
                height: Sizes.size150,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(Sizes.size16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: Sizes.size8,
                      offset: const Offset(0, Sizes.size4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: Sizes.size12),
                child: CupertinoTheme(
                  data: CupertinoTheme.of(context).copyWith(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: textTheme.titleMedium?.copyWith(
                        fontFamily: AppFonts.playfair,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    key: ValueKey(form.timestamp.millisecondsSinceEpoch),
                    initialDateTime: form.timestamp,
                    mode: CupertinoDatePickerMode.dateAndTime,
                    use24hFormat: true,
                    onDateTimeChanged: (value) {
                      ref
                          .read(moodEntryFormProvider.notifier)
                          .updateTimestamp(value);
                    },
                  ),
                ),
              ),
              Gaps.v24,
              Text(
                '기분 기록',
                style: textTheme.titleMedium?.copyWith(
                  fontFamily: AppFonts.playfair,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              Gaps.v8,
              Text(
                '오늘의 생각을 적어보세요',
                style: textTheme.bodySmall?.copyWith(
                  fontFamily: AppFonts.playfair,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Gaps.v12,
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: journalMinHeight),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  minLines: 6,
                  maxLength: 500,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  enabled: !form.isSubmitting,
                  onChanged: (value) => ref
                      .read(moodEntryFormProvider.notifier)
                      .updateMessage(value),
                  decoration: InputDecoration(
                    hintText: '기분을 기록해보세요',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Sizes.size16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Sizes.size16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Sizes.size16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(Sizes.size20),
                  ),
                  style: textTheme.bodyMedium?.copyWith(
                    fontFamily: AppFonts.playfair,
                    color: colorScheme.onSurface,
                    height: 1.4,
                  ),
                  cursorColor: colorScheme.primary,
                ),
              ),
              Gaps.v12,
              Row(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: form.errorMessage == null
                          ? const SizedBox.shrink()
                          : Text(
                              form.errorMessage!,
                              key: ValueKey(form.errorMessage),
                              style: textTheme.bodySmall?.copyWith(
                                fontFamily: AppFonts.playfair,
                                color: colorScheme.error,
                              ),
                            ),
                    ),
                  ),
                  Text(
                    '${form.message.length}/500',
                    style: textTheme.bodySmall?.copyWith(
                      fontFamily: AppFonts.playfair,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
