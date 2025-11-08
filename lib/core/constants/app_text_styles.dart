// ignore_for_file: deprecated_member_use

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
    );
  }

  static TextStyle? authAppBar(TextTheme textTheme) {
    return textTheme.titleLarge?.copyWith(
      fontFamily: AppFonts.playfair,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle? authTitle(TextTheme textTheme) {
    return textTheme.headlineSmall?.copyWith(
      fontFamily: AppFonts.playfair,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
    );
  }

  static TextStyle? authSubtitle(TextTheme textTheme) {
    return textTheme.bodyMedium?.copyWith(
      fontFamily: AppFonts.playfair,
      color: textTheme.bodyMedium?.color?.withOpacity(0.6),
    );
  }

  static TextStyle? authLink(TextTheme textTheme) {
    return textTheme.bodyMedium?.copyWith(
      fontFamily: AppFonts.playfair,
      fontWeight: FontWeight.w600,
      color: AppColors.point,
    );
  }

  static TextStyle? authBody(TextTheme textTheme) {
    return textTheme.bodyMedium?.copyWith(
      fontFamily: AppFonts.playfair,
    );
  }

  static TextStyle? greetingName(TextTheme textTheme) {
    return textTheme.headlineLarge?.copyWith(
      fontFamily: AppFonts.playfair,
      fontWeight: FontWeight.w900,
      fontSize: Sizes.size40,
      color: AppColors.point,
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
      color: textTheme.bodySmall?.color?.withOpacity(0.6),
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
      color: textTheme.bodySmall?.color?.withOpacity(0.6),
      fontStyle: FontStyle.italic,
    );
  }

  static TextStyle? timelineStackHint(TextTheme textTheme) {
    return textTheme.bodySmall?.copyWith(
      fontFamily: AppFonts.playfair,
      color: textTheme.bodySmall?.color?.withOpacity(0.5),
      fontStyle: FontStyle.italic,
    );
  }

  static TextStyle settings(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.textTheme.bodyMedium ??
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
    return base.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: theme.colorScheme.onSurface,
    );
  }
}
