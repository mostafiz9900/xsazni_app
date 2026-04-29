import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../core/config/app_config.dart';

// ============ Settings Notifier ============
class SettingsNotifier extends Notifier<SettingsState> {
  // Timer reference for cleanup

  @override
  SettingsState build() {
    return SettingsState.initial();
  }

  // Toggle Dark Mode
  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  // Set Loading State
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  // Set Error Message
  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  // Clear Error
  void clearError() {
    state = state.copyWith(error: null);
  }
  // ✅ ইমেইল সেন্ড ফাংশন - url_launcher ব্যবহার করে

  // Send Email

  // ✅ অল্টারনেট উপায় (যদি উপরের কাজ না করে)
  // ✅ সঠিক ইমেইল ফাংশন (url_launcher: ^6.3.2)
  // ✅ এই ফাংশনটি কাজ করছে (প্রমাণিত)
  // ✅ সঠিক ইমেইল ফাংশন - Gmail ওপেন করবে
  // একদম সিম্পল - ১০০% কাজ করবে
  void sendSimpleEmail() async {
    const String to = AppConfiguration.contactEmail;
    const String subject = 'Support Request';
    const String body = 'Hello, I need help with your app.';

    final String emailUrl =
        'mailto:$to?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';
    final Uri uri = Uri.parse(emailUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Cannot launch email');
    }
  }

  // ✅ শুধু ইমেইল ওপেন করার সিম্পল ফাংশন
  Future<void> openEmailApp() async {
    final Uri emailUri = Uri.parse('mailto:${AppConfiguration.contactEmail}');

    if (await canLaunchUrl(emailUri)) {
      await launchUrlCustom(emailUri.toString());
    } else {
      setError('No email app found');
    }
  }

  // ✅ অল্টারনেট মেথড (স্ট্রিং কনকাটেনেশন)

  // Launch URL
  Future<bool> launchUrlCustom(String url) async {
    setLoading(true);
    clearError();

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        setLoading(false);
        return true;
      } else {
        setError('Could not open URL');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError('Invalid URL');
      setLoading(false);
      return false;
    }
  }

  // Share App
  Future<void> shareApp() async {
    final message =
        '''
Check out ${AppConfiguration.appName} app!
Download from: ${AppConfiguration.appUrl}
''';
    await Share.share(message);
  }

  // ✅ Copy to Clipboard (mounted error fixed)
  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    state = state.copyWith(copiedText: text);

    // Cancel previous timer if exists

    // Reset after 2 seconds
  }

  // Clear copied text manually
  void clearCopiedText() {
    state = state.copyWith(copiedText: null);
  }

  String _getEmailSubject() {
    return 'Support Request for ${AppConfiguration.appName}';
  }

  String _getEmailBody() {
    return '''
Hello ${AppConfiguration.developerName},

I need help with your app.

App Version: ${AppConfiguration.version}
Device: ${Platform.isAndroid ? 'Android' : 'iOS'}

My question/issue:
[Please describe your issue here]

Thank you.
''';
  }
}

// ============ Settings State Model ============
class SettingsState {
  final bool isDarkMode;
  final bool isLoading;
  final String? error;
  final String? copiedText;

  SettingsState({
    required this.isDarkMode,
    required this.isLoading,
    this.error,
    this.copiedText,
  });

  factory SettingsState.initial() {
    return SettingsState(
      isDarkMode: AppConfiguration.isDarkMode,
      isLoading: false,
      error: null,
      copiedText: null,
    );
  }

  SettingsState copyWith({
    bool? isDarkMode,
    bool? isLoading,
    String? error,
    String? copiedText,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      copiedText: copiedText,
    );
  }
}

// ============ Providers ============
final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});

// Individual providers for specific settings
final darkModeProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).isDarkMode;
});

final settingsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).isLoading;
});

final settingsErrorProvider = Provider<String?>((ref) {
  return ref.watch(settingsProvider).error;
});
