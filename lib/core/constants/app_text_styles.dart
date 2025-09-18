import 'package:flutter/material.dart';

import 'package:mood_tracker/core/constants/app_color.dart';
import 'package:mood_tracker/core/constants/sizes.dart';

class AppFonts {
  static const playfair = 'PlayfairDisplay';
}

class AppTextStyles {
  const AppTextStyles._();

  static TextStyle? greetingHello(TextTheme textTheme) {
    return textTheme.headlineMedium?.copyWith(
      fontFamily: AppFonts.playfair,
      fontWeight: FontWeight.w800,
      color: AppColors.text,
    );
  }

  static TextStyle? greetingName(TextTheme textTheme) {
    return textTheme.headlineLarge?.copyWith(
      fontFamily: AppFonts.playfair,
      fontWeight: FontWeight.w900,
      color: AppColors.point,
      fontSize: Sizes.size40,
    );
  }

  static TextStyle? weeklyCalendarTitle(TextTheme textTheme) {
    return textTheme.titleMedium?.copyWith(
      fontFamily: AppFonts.playfair,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle? weeklyCalendarLabel(TextTheme textTheme) {
    return textTheme.labelLarge?.copyWith(
      fontFamily: AppFonts.playfair,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle? weeklyCalendarDayNumber(TextTheme textTheme) {
    return textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
  }
}
