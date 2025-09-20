import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mood_tracker/core/constants/app_color.dart';
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
    final textTheme = theme.textTheme;

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
      backgroundColor: AppColors.bgWhite,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.point,
        onPressed: handleSubmit,
        child: form.isSubmitting
            ? const SizedBox(
                width: Sizes.size20,
                height: Sizes.size20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.bgWhite),
                ),
              )
            : const Icon(Icons.check, color: AppColors.bgWhite),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
              child: CupertinoNavigationBarBackButton(
                color: AppColors.text,
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: Sizes.size96),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.size32,
                  vertical: Sizes.size20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gaps.v56,
                    Row(
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
                              horizontal: Sizes.size16,
                              vertical: Sizes.size8,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<EmotionType>(
                                value: emotion,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                ),
                                style: textTheme.headlineSmall?.copyWith(
                                  fontFamily: AppFonts.playfair,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                                dropdownColor: AppColors.bgWhite,
                                onChanged: form.isSubmitting
                                    ? null
                                    : (value) {
                                        if (value == null) return;
                                        ref
                                            .read(
                                              moodEntryFormProvider.notifier,
                                            )
                                            .updateEmotion(value);
                                      },
                                items: EmotionType.values
                                    .map(
                                      (type) => DropdownMenuItem<EmotionType>(
                                        value: type,
                                        child: Text(
                                          '${type.emoji} ${type.displayNameEn}',
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Gaps.v24,
                    Container(
                      height: Sizes.size100,
                      decoration: BoxDecoration(
                        color: AppColors.bgWhite,
                        borderRadius: BorderRadius.circular(Sizes.size16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.size12,
                      ),
                      child: CupertinoTheme(
                        data: CupertinoTheme.of(context).copyWith(
                          textTheme: CupertinoTextThemeData(
                            dateTimePickerTextStyle: textTheme.titleMedium
                                ?.copyWith(
                                  fontFamily: AppFonts.playfair,
                                  color: AppColors.text,
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
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 400),
                      child: TextField(
                        controller: _messageController,
                        maxLines: null,
                        minLines: 6,
                        enabled: !form.isSubmitting,
                        onChanged: (value) => ref
                            .read(moodEntryFormProvider.notifier)
                            .updateMessage(value),
                        decoration: InputDecoration(
                          hintText: '기분을 기록해보세요',
                          filled: true,
                          fillColor: AppColors.bgBeige,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Sizes.size16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(Sizes.size20),
                        ),
                        style: textTheme.bodyMedium?.copyWith(
                          fontFamily: AppFonts.playfair,
                          color: AppColors.text,
                        ),
                        cursorColor: AppColors.point,
                      ),
                    ),
                    if (form.errorMessage != null) ...[
                      Gaps.v12,
                      Text(
                        form.errorMessage!,
                        style: textTheme.bodySmall?.copyWith(
                          fontFamily: AppFonts.playfair,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
