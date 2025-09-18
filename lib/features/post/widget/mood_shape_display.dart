import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/constants/sizes.dart';
import 'package:mood_tracker/core/models/emotion_type.dart';
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
      duration: const Duration(milliseconds: 320),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
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
      _previousEmotion = mood.emotion;
    } else if (_previousEmotion != mood.emotion) {
      _previousEmotion = mood.emotion;
      _scaleController.forward(from: 0);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(Sizes.size24),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              final double scale = 0.9 + (0.1 * _scaleAnimation.value);
              return Transform.scale(scale: scale, child: child);
            },
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: _MorphingMoodPainter(
                color: mood.currentColor,
                radii: mood.radii,
              ),
            ),
          ),
        ),
        Gaps.v24,
        Text(
          _emotionMessage(mood.emotion),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        Gaps.v12,
        Text(
          mood.emotion.displayNameEn,
          style: theme.textTheme.titleMedium?.copyWith(
            color: mood.currentColor,
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
    final activeEmotion = ref.watch(currentMoodDataProvider).emotion;

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
                color: MoodSliderData.colorForEmotion(emotion),
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

class _MorphingMoodPainter extends CustomPainter {
  const _MorphingMoodPainter({required this.color, required this.radii});

  final Color color;
  final List<double> radii;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Path path = _createPath(size);
    canvas.drawPath(path, paint);
  }

  Path _createPath(Size size) {
    final Path path = Path();
    if (radii.isEmpty) {
      return path;
    }
    final Offset center = size.center(Offset.zero);
    final double base = size.shortestSide / 2 * 0.92;
    final int count = radii.length;

    final List<Offset> points = List<Offset>.generate(count, (int i) {
      final double angle = (2 * math.pi * i) / count;
      final double distance = base * radii[i];
      return Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );
    });

    path.moveTo(points.first.dx, points.first.dy);
    const double tension = 0.6;

    for (int i = 0; i < count; i++) {
      final Offset p0 = points[i];
      final Offset p1 = points[(i + 1) % count];
      final Offset pm1 = points[(i - 1 + count) % count];
      final Offset p2 = points[(i + 2) % count];

      final Offset control1 = p0 + _scaleOffset(p1 - pm1, tension / 6);
      final Offset control2 = p1 - _scaleOffset(p2 - p0, tension / 6);

      path.cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        p1.dx,
        p1.dy,
      );
    }

    path.close();
    return path;
  }

  Offset _scaleOffset(Offset offset, double factor) {
    return Offset(offset.dx * factor, offset.dy * factor);
  }

  @override
  bool shouldRepaint(covariant _MorphingMoodPainter oldDelegate) {
    return oldDelegate.color != color || !listEquals(oldDelegate.radii, radii);
  }
}
