import 'package:flutter/material.dart';
import 'package:mood_tracker/core/constants/app_text_styles.dart';
import 'package:mood_tracker/core/constants/gaps.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.authTitle(textTheme),
        ),
        if (subtitle != null) ...[
          Gaps.v8,
          Text(
            subtitle!,
            style: AppTextStyles.authSubtitle(textTheme),
          ),
        ],
      ],
    );
  }
}
