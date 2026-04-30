import 'package:flutter/material.dart';

/// ডেভেলপার কনফিগারেশন - শুধুমাত্র এখানে পরিবর্তন করবেন
class AppConfiguration {
  // ==================== অ্যাপ বেসিক ইনফো ====================

  /// অ্যাপের নাম (প্লে স্টোরে দেখাবে)
  static const String appName = "XSAZNI";

  /// অ্যাপের ওয়েবসাইট URL
  static const String appUrl = "https://xsazni.com/";

  /// অ্যাপের সংস্করণ
  static const String version = "1.0.0";

  /// অ্যাপের আইকন (ইমোজি)
  static const String appIcon = "assets/images/xsazni-logo.png";

  // ==================== থিম কনফিগারেশন ====================

  /// থিম মোড (true = ডার্ক, false = লাইট)
  static const bool isDarkMode = false;
static const Color primaryColor = Colors.blueGrey; 
  static const Color secondaryColor = Color(0xFF00BCD4); 
  static const Color accentColor = Color(0xFFFFC107); 
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF4CAF50);

  // ==================== ওয়েবভিউ কনফিগারেশন ====================

  /// জুম সাপোর্ট
  static const bool enableZoom = true;

  /// জাভাস্ক্রিপ্ট সাপোর্ট
  static const bool enableJavaScript = true;

  /// ক্যাশে সাপোর্ট
  static const bool enableCache = true;

  /// ইমেজ লোডিং
  static const bool loadImages = true;

  /// ব্যাক বাটন এক্সিট (true = অ্যাপ এক্সিট, false = ওয়েবভিউ ব্যাক)
  static const bool backButtonExitApp = true;

  // ==================== UI কনফিগারেশন ====================

  /// স্প্ল্যাশ স্ক্রিন দেখাবে কিনা
  static const bool showSplash = true;

  /// স্প্ল্যাশ ডেলেই (সেকেন্ড)
  static const int splashDelay = 2;

  /// অ্যাপবার দেখাবে কিনা
  static const bool showAppBar = true;

  /// বটম নেভিগেশন বার দেখাবে কিনা
  static const bool showBottomBar = true;

  /// লোডিং মেসেজ
  static const String loadingMessage = "Loading...";

  /// এরর মেসেজ
  static const String errorMessage = "Failed to load page";

  // ==================== সোশ্যাল লিংক ====================

  static const String facebookUrl = "";
  static const String instagramUrl = "";
  static const String twitterUrl = "";
  static const String websiteUrl = "";

  // ==================== অ্যাবাউট সেকশন ====================

  static const String developerName = "Quality Can Do Soft";
  static const String contactEmail = "sohelrana31b@gmail.com";
  static String privacyPolicy =
      """
 Privacy Policy for $appName

Last updated: ${DateTime.now().year}

1. Information Collection
This app does not collect any personal information. All data is stored locally on your device.

2. Website Content
All website content is loaded from $appUrl which is owned and operated by $developerName.

3. Data Storage
Your preferences and settings are stored locally using SharedPreferences.

4. Third-Party Services
This app does not share any data with third parties.

5. Contact Us
For any questions, contact us at: $contactEmail

6. Changes to Policy
We may update this privacy policy from time to time.

© ${DateTime.now().year} $developerName. All rights reserved.
  """;
}
