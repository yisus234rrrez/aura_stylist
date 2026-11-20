import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';





abstract class AppTheme {
  static ThemeData get light {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.background,
    );

    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppFonts.body,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: AppFonts.body,
        bodyColor: AppColors.textBody,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
