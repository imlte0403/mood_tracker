import 'package:flutter/material.dart';

import 'package:mood_tracker/core/models/emotion_type.dart';
import 'package:mood_tracker/features/post/model/mood_shape.dart';

class EmotionShapeBadge extends StatelessWidget {
  const EmotionShapeBadge({
    super.key,
    required this.emotion,
    this.size = 64,
  });

  final EmotionType emotion;
  final double size;

  @override
  Widget build(BuildContext context) {
    final snapshot = MoodShapeEngine.resolve(
      MoodShapeEngine.sliderAnchorForEmotion(emotion),
    );

    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: snapshot.color,
        shape: snapshot.shape,
        shadows: [
          BoxShadow(
            color: snapshot.color.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: snapshot.color.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
