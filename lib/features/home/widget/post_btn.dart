import 'package:flutter/material.dart';

import 'package:mood_tracker/constants/app_color.dart';
import 'package:mood_tracker/constants/sizes.dart';

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
        backgroundColor: AppColors.point,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: AppColors.bgWhite,
          size: Sizes.size36,
        ),
      ),
    );
  }
}
