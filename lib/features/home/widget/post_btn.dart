import 'package:flutter/material.dart';

import 'package:mood_tracker/core/constants/sizes.dart';

class PostBtn extends StatelessWidget {
  const PostBtn({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    const scale = 1.2;
    const baseSize = Sizes.size56;
    final targetSize = baseSize * scale;

    return SizedBox(
      width: targetSize,
      height: targetSize,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: const CircleBorder(),
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimary,
          size: Sizes.size36,
        ),
      ),
    );
  }
}
