import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/constants/sizes.dart';
import 'package:mood_tracker/core/models/emotion_type.dart';
import 'package:mood_tracker/features/post/model/mood_shape.dart';
import 'package:mood_tracker/features/post/post_viewmodel.dart';

class MoodShapeDisplay extends ConsumerStatefulWidget {
  const MoodShapeDisplay({super.key, this.size = 220});

  final double size;

  @override
  ConsumerState<MoodShapeDisplay> createState() => _MoodShapeDisplayState();
}

class _MoodShapeDisplayState extends ConsumerState<MoodShapeDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;
  EmotionType? _previousEmotion;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = ref.watch(currentMoodDataProvider);

    if (_previousEmotion == null) {
      _previousEmotion = mood.displayEmotion;
    } else if (_previousEmotion != mood.displayEmotion) {
      _previousEmotion = mood.displayEmotion;
      _scaleController.forward(from: 0);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.all(Sizes.size24),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              final double scale = 0.9 + (0.1 * _scaleAnimation.value);
              return Transform.scale(scale: scale, child: child);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: ShapeDecoration(
                  color: mood.color,
                  shape: mood.shape,
                  shadows: [
                    BoxShadow(
                      color: mood.color.withValues(alpha: 0.25),
                      offset: const Offset(0, 6),
                      blurRadius: 12,
                    ),
                    BoxShadow(
                      color: mood.color.withValues(alpha: 0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Gaps.v24,
        Text(
          _emotionMessage(mood.displayEmotion),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        Gaps.v12,
        Text(
          mood.displayEmotion.displayNameEn,
          style: theme.textTheme.titleMedium?.copyWith(
            color: mood.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        Gaps.v16,
        const _MoodColorIndicator(),
      ],
    );
  }

  String _emotionMessage(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.angry:
        return 'I feel frustrated.';
      case EmotionType.sad:
        return 'I feel a little down.';
      case EmotionType.anxious:
        return 'I feel nervous.';
      case EmotionType.normal:
        return 'I don\'t know my feeling.';
      case EmotionType.depressed:
        return 'I feel low.';
      case EmotionType.lucky:
        return 'I feel hopeful.';
      case EmotionType.excited:
        return 'I feel thrilled!';
      case EmotionType.happy:
        return 'I feel great!';
    }
  }
}

class _MoodColorIndicator extends ConsumerWidget {
  const _MoodColorIndicator();

  static const List<EmotionType> _order = <EmotionType>[
    EmotionType.angry,
    EmotionType.sad,
    EmotionType.anxious,
    EmotionType.normal,
    EmotionType.depressed,
    EmotionType.lucky,
    EmotionType.excited,
    EmotionType.happy,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeEmotion = ref.watch(currentMoodDataProvider).displayEmotion;

    // 색상 인디케이터
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final emotion in _order)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.size6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: emotion == activeEmotion ? Sizes.size18 : Sizes.size12,
              height: emotion == activeEmotion ? Sizes.size18 : Sizes.size12,
              decoration: BoxDecoration(
                color: MoodShapeEngine.colorForEmotion(emotion),
                shape: BoxShape.circle,
                border: emotion == activeEmotion
                    ? Border.all(color: Colors.white, width: Sizes.size2)
                    : null,
                boxShadow: emotion == activeEmotion
                    ? const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, Sizes.size2),
                          blurRadius: Sizes.size4,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

