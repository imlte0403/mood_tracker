import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mood_tracker/constants/app_color.dart';
import 'package:mood_tracker/constants/gaps.dart';
import 'package:mood_tracker/constants/sizes.dart';
import 'package:mood_tracker/core/models/emotion_type.dart';
import 'package:mood_tracker/features/post/post_viewmodel.dart';

class MoodTextField extends ConsumerStatefulWidget {
  const MoodTextField({super.key});

  @override
  ConsumerState<MoodTextField> createState() => _MoodTextFieldState();
}

class _MoodTextFieldState extends ConsumerState<MoodTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(moodEntryFormProvider).message;
    _controller = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final form = ref.watch(moodEntryFormProvider);
    final mood = ref.watch(currentMoodDataProvider);

    if (_controller.text != form.message) {
      _controller.value = _controller.value.copyWith(
        text: form.message,
        selection: TextSelection.collapsed(offset: form.message.length),
      );
    }

    final placeholder = _placeholderForEmotion(mood.emotion);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Sizes.size20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: Sizes.size8,
                offset: Offset(0, Sizes.size4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.size20,
            vertical: Sizes.size18,
          ),
          child: TextField(
            controller: _controller,
            maxLines: 5,
            minLines: 3,
            maxLength: 500,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: placeholder,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.placeholder,
              ),
              counterText: '',
            ),
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
            onChanged: (value) =>
                ref.read(moodEntryFormProvider.notifier).updateMessage(value),
          ),
        ),
        Gaps.v8,
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
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.redAccent,
                        ),
                      ),
              ),
            ),
            Text(
              '${form.message.length}/500',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.placeholder,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _placeholderForEmotion(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.angry:
        return '무엇이 나를 화나게 했을까?';
      case EmotionType.sad:
        return '슬펐던 순간을 기록해볼까요?';
      case EmotionType.anxious:
        return '마음이 불안한 이유는 무엇일까요?';
      case EmotionType.normal:
        return '평온한 지금의 기분을 남겨볼까요?';
      case EmotionType.depressed:
        return '지금 마음을 솔직하게 적어보세요.';
      case EmotionType.lucky:
        return '오늘의 행운, 무엇이었나요?';
      case EmotionType.excited:
        return '두근거렸던 순간을 떠올려봐요!';
      case EmotionType.happy:
        return '행복했던 이유를 기록해볼까요?';
    }
  }
}
