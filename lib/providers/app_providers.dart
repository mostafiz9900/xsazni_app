import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';

/// ============ Theme Mode Provider ============
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Initial value from config
    return AppConfiguration.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
  
  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
  

  void setLightMode() {
    state = ThemeMode.light;
  }
  
  void setDarkMode() {
    state = ThemeMode.dark;
  }
  
  void setSystemMode() {
    state = ThemeMode.system;
  }
}

/// ============ Loading Provider ============
final isLoadingProvider = NotifierProvider<LoadingNotifier, bool>(() {
  return LoadingNotifier();
});

class LoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  
  void show() => state = true;
  void hide() => state = false;
  void toggle() => state = !state;
}

/// ============ Current URL Provider ============
final currentUrlProvider = NotifierProvider<CurrentUrlNotifier, String>(() {
  return CurrentUrlNotifier();
});

class CurrentUrlNotifier extends Notifier<String> {
  @override
  String build() => AppConfiguration.appUrl;
  
  void update(String url) {
    state = url;
  }
  
  void reset() {
    state = AppConfiguration.appUrl;
  }
}

/// ============ Navigation State Provider ============
final canGoBackProvider = NotifierProvider<CanGoBackNotifier, bool>(() {
  return CanGoBackNotifier();
});

class CanGoBackNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  
  void set(bool value) => state = value;
}

final canGoForwardProvider = NotifierProvider<CanGoForwardNotifier, bool>(() {
  return CanGoForwardNotifier();
});

class CanGoForwardNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  
  void set(bool value) => state = value;
}

/// ============ WebView Controller Provider ============
final webViewControllerProvider = Provider((ref) => null);

/// ============ App Config Providers (Read-only) ============
final appNameProvider = Provider<String>((ref) => AppConfiguration.appName);
final appUrlProvider = Provider<String>((ref) => AppConfiguration.appUrl);
final appIconProvider = Provider<String>((ref) => AppConfiguration.appIcon);
final appVersionProvider = Provider<String>((ref) => AppConfiguration.version);