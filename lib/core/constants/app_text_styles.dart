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

  static TextStyle? timelineHeader(TextTheme textTheme) {
    return textTheme.labelMedium?.copyWith(
      fontFamily: AppFonts.playfair,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle? timelineTime(TextTheme textTheme) {
    return textTheme.bodySmall?.copyWith(
      fontFamily: AppFonts.playfair,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle? timelineSlotLabel(TextTheme textTheme) {
    return textTheme.bodySmall?.copyWith(
      fontFamily: AppFonts.playfair,
      color: AppColors.placeholder,
    );
  }

  static TextStyle? timelineMoodTitle(TextTheme textTheme) {
    return textTheme.titleSmall?.copyWith(
      fontFamily: AppFonts.playfair,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle? timelineMessage(TextTheme textTheme) {
    return textTheme.bodyMedium?.copyWith(fontFamily: AppFonts.playfair);
  }

  static TextStyle? timelineStackLabel(TextTheme textTheme) {
    return textTheme.bodySmall?.copyWith(
      fontFamily: AppFonts.playfair,
      color: AppColors.placeholder,
      fontStyle: FontStyle.italic,
    );
  }

  static TextStyle? timelineStackHint(TextTheme textTheme) {
    return textTheme.bodySmall?.copyWith(
      fontFamily: AppFonts.playfair,
      color: AppColors.placeholder.withOpacity(0.7),
      fontStyle: FontStyle.italic,
    );
  }
}
