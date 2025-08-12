import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Paleta de colores de la aplicación
class AppColors {
  static const Color primary = Colors.black;
  static const Color secondary = Colors.white;
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFF6B7280); // Grey 500
  static const Color textTertiary = Color(0xFF9CA3AF); // Grey 400
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF9FAFB); // Grey 50
  static const Color overlay = Color(0x80000000); // Black with 50% opacity
  static const Color borderLight = Color(0xFFE5E7EB); // Grey 200
  static const Color accent = Color.fromARGB(255, 2, 94, 86); // Blue 600
}

ThemeData theme() {
  return ThemeData(
    fontFamily: 'Inter',
    appBarTheme: appBarTheme(),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      background: AppColors.background,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
      bodySmall: TextStyle(color: AppColors.textTertiary),
    ),
  );
}

void configureSystemUI() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
}


AppBarTheme appBarTheme() {
  return const AppBarTheme(
    color: Colors.white,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
  );
}