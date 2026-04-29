import 'package:flutter/material.dart';
import '../config/app_config.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: AppConfiguration.primaryColor,
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppConfiguration.primaryColor,
        secondary: AppConfiguration.secondaryColor,
        tertiary: AppConfiguration.accentColor,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // কালো আইকন
          statusBarBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: AppConfiguration.primaryColor,
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: AppConfiguration.primaryColor,
        secondary: AppConfiguration.secondaryColor,
        tertiary: AppConfiguration.accentColor,
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light, // সাদা আইকন
          statusBarBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
