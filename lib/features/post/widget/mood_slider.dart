import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/constants/sizes.dart';
import 'package:mood_tracker/features/post/model/mood_shape.dart';
import 'package:mood_tracker/features/post/post_viewmodel.dart';

class MoodSlider extends ConsumerWidget {
  const MoodSlider({super.key});

  static const double _min = kMoodSliderMin;
  static const double _max = kMoodSliderMax;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final sliderValue = ref.watch(moodSliderValueProvider);
    final moodData = ref.watch(currentMoodDataProvider);

    final activeColor = moodData.color;

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
            valueIndicatorTextStyle: TextStyle(color: colorScheme.onPrimary),
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
              final moodType = MoodShapeEngine.getMoodFromSlider(value);
              ref
                  .read(moodEntryFormProvider.notifier)
                  .updateEmotion(moodType.emotion);
            },
          ),
        ),
        Gaps.v8,
      ],
    );
  }
}
