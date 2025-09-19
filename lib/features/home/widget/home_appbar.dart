import 'package:flutter/material.dart';

import 'package:mood_tracker/core/constants/app_text_styles.dart';
import 'package:mood_tracker/core/constants/app_color.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: AppColors.bgWhite,
      surfaceTintColor: AppColors.bgWhite,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        'MoodLine',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontFamily: AppFonts.playfair,
        ),
      ),
    );
  }
}
