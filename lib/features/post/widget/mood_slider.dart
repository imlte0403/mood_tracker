import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mood_tracker/constants/app_color.dart';
import 'package:mood_tracker/constants/gaps.dart';
import 'package:mood_tracker/constants/sizes.dart';
import 'package:mood_tracker/core/models/emotion_type.dart';
import 'package:mood_tracker/features/post/post_viewmodel.dart';

class MoodSlider extends ConsumerWidget {
  const MoodSlider({super.key});

  static const double _min = 0.0;
  static const double _max = 8.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sliderValue = ref.watch(moodSliderValueProvider);
    final moodData = ref.watch(currentMoodDataProvider);

    final activeColor = moodData.currentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: Sizes.size6,
            activeTrackColor: activeColor,
            inactiveTrackColor: activeColor.withValues(alpha: 0.2),
            thumbColor: activeColor,
            overlayColor: activeColor.withValues(alpha: 0.25),
            valueIndicatorColor: activeColor,
            valueIndicatorTextStyle: const TextStyle(color: Colors.white),
            trackShape: const RoundedRectSliderTrackShape(),
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: Sizes.size14,
            ),
          ),
          child: Slider(
            min: _min,
            max: _max,
            value: sliderValue,
            label: "Rating: ${sliderValue.toStringAsFixed(1)}",
            onChanged: (value) {
              ref.read(moodSliderValueProvider.notifier).state = value;
              final updatedMood = MoodSliderData.fromSliderValue(value);
              ref
                  .read(moodEntryFormProvider.notifier)
                  .updateEmotion(updatedMood.emotion);
            },
          ),
        ),
        Gaps.v8,
      ],
    );
  }
}

class _SliderLabel extends StatefulWidget {
  const _SliderLabel({required this.text});

  final String text;

  @override
  State<_SliderLabel> createState() => _SliderLabelState();
}

class _SliderLabelState extends State<_SliderLabel> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: Theme.of(
        context,
      ).textTheme.labelMedium?.copyWith(color: AppColors.placeholder),
    );
  }
}
