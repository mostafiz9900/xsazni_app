import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_config.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      // ColorScheme.fromSeed সব কালারের মধ্যে একটা সামঞ্জস্য বজায় রাখে
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConfiguration.primaryColor,
        brightness: Brightness.light,
        primary: AppConfiguration.primaryColor,
        secondary: AppConfiguration.secondaryColor,
        surface: const Color(0xFFFFFFFF), // বিশুদ্ধ সাদা ব্যাকগ্রাউন্ড
        onSurface: Colors.black, // সাদার ওপর কালো টেক্সট
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA), // হালকা ধূসর শেড
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // অ্যাপবার টেক্সট/আইকন কালার
        elevation: 0,
        systemOverlayStyle:
            SystemUiOverlayStyle.dark, // স্ট্যাটাস বার আইকন কালো
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConfiguration.primaryColor,
        brightness: Brightness.dark,
        primary: AppConfiguration.primaryColor,
        secondary: AppConfiguration.secondaryColor,
        surface: const Color(0xFF121212), // ডার্ক ব্যাকগ্রাউন্ড
        onSurface: Colors.white, // কালোর ওপর সাদা টেক্সট
      ),
      scaffoldBackgroundColor: const Color(0xFF0F0F0F),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        foregroundColor: Colors.white, // অ্যাপবার টেক্সট/আইকন কালার সাদা
        elevation: 0,
        systemOverlayStyle:
            SystemUiOverlayStyle.light, // স্ট্যাটাস বার আইকন সাদা
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
