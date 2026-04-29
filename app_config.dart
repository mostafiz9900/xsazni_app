import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class AppConfig {
  static const String baseUrl = 'https://flutter.dev';
  static const String appTitle = 'WebFlux Pro';
  static const Color primaryColor = Colors.indigo;
  static const bool supportDarkTheme = true;
  static const FlexScheme scheme = FlexScheme.indigo;
  static const String userAgent =
      "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36";

  static const Duration animationDuration = Duration(milliseconds: 300);
}
