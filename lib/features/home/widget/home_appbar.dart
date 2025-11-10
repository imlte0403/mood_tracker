import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mood_tracker/core/constants/app_text_styles.dart';
import 'package:mood_tracker/features/settings/settings_screen.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        'MoodLine',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w400,
          fontFamily: AppFonts.pretendard,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: colorScheme.onSurface),
          onPressed: () => context.push(SettingsScreen.routeURL),
        ),
      ],
    );
  }
}
