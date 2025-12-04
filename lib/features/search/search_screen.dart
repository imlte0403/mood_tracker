import 'package:flutter/material.dart';

import 'package:mood_tracker/core/constants/app_text_styles.dart';

class SearchScreen extends StatelessWidget {
  static const String routeName = 'search';
  static const String routeURL = '/search';

  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Text(
          '검색 기능 준비 중',
          style: AppTextStyles.settings(context).copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
