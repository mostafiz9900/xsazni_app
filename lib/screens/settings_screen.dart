import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xsazni/providers/settings_providers.dart';
import '../../../core/config/app_config.dart';
import '../providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final settingNotifier = ref.watch(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Appearance Section
          _buildSection(
            title: 'Appearance',
            icon: Icons.palette,
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Switch between light and dark theme'),
                secondary: const Icon(Icons.dark_mode),
                value: isDarkMode,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).state = value
                      ? ThemeMode.dark
                      : ThemeMode.light;
                },
              ),
            ],
          ),

          // About Section
          _buildSection(
            title: 'About',
            icon: Icons.info,
            children: [
              ListTile(
                leading: Image.asset(
                  AppConfiguration.appIcon,
                  width: 20,
                  height: 20,
                ),
                title: Text(AppConfiguration.appName),
                subtitle: Text('Version ${AppConfiguration.version}'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.web),
                title: const Text('Website'),
                subtitle: Text(AppConfiguration.appUrl),
                onTap: () {
                  ref
                      .read(settingsProvider.notifier)
                      .launchUrlCustom(AppConfiguration.appUrl);
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                onTap: () => _showPrivacyDialog(context),
                // onTap: () {
                //   showDialog(
                //     context: context,
                //     builder: (context) => const PrivacyPolicyDialog(),
                //   );
                // },
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Developer'),
                subtitle: Text(AppConfiguration.developerName),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Contact Us'),
                subtitle: Text(AppConfiguration.contactEmail),
                onTap: () async {
                  settingNotifier.sendSimpleEmail();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PrivacyPolicyDialog(),
    );
  }
}

class PrivacyPolicyDialog extends ConsumerWidget {
  const PrivacyPolicyDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildContent(isDarkMode),
            _buildFooter(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConfiguration.primaryColor,
            AppConfiguration.primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.privacy_tip, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Text(
            AppConfiguration.privacyPolicy,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: isDarkMode ? Colors.white70 : Colors.grey[800],
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: AppConfiguration.primaryColor),
              ),
              child: const Text('Close'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Add your URL launcher here
                ref
                    .read(settingsProvider.notifier)
                    .launchUrlCustom(
                      '${AppConfiguration.appUrl}policies/privacy-policy',
                    );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: AppConfiguration.primaryColor),
              ),
              child: const Text('View Online'),
            ),
          ),
        ],
      ),
    );
  }
}
/*

```import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_config.dart';
import '../../providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance', Icons.palette),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch theme'),
              value: isDarkMode,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).state = value
                    ? ThemeMode.dark
                    : ThemeMode.light;
              },
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('About', Icons.info),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Divider(height: 1),
                _buildSimpleTile(
                  icon: const Icon(Icons.web, size: 24, color: Colors.green),
                  title: 'Website',
                  subtitle: AppConfiguration.appUrl,
                  onTap: () => _launchUrl(AppConfiguration.appUrl, context),
                ),
                _buildSimpleTile(
                  icon: const Icon(
                    Icons.privacy_tip,
                    size: 24,
                    color: Colors.blue,
                  ),
                  title: 'Privacy Policy',
                  onTap: () => _showPrivacyDialog(context),
                ),
                _buildSimpleTile(
                  icon: const Icon(Icons.code, size: 24, color: Colors.purple),
                  title: 'Developer',
                  subtitle: AppConfiguration.developerName,
                  showArrow: false,
                ),
                _buildSimpleTile(
                  icon: const Icon(Icons.email, size: 24, color: Colors.red),
                  title: 'Contact Us',
                  subtitle: AppConfiguration.contactEmail,
                  onTap: () => _sendEmail(context),
                ),
                _buildSimpleTile(
                  icon: Image.asset(
                    AppConfiguration.appIcon,
                    width: 20,
                    height: 20,

                    // style: const TextStyle(fontSize: 28),
                  ),
                  title: AppConfiguration.appName,
                  subtitle: 'Version ${AppConfiguration.version}',
                  showArrow: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleTile({
    required Widget icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(width: 32, child: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            if (showArrow)
              Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Future<void> _sendEmail(BuildContext context) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: AppConfiguration.contactEmail,
        query:
            'subject=${Uri.encodeComponent('Support Request')}&body=${Uri.encodeComponent('Hello, I need help with your app.')}',
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      } else {
        _showMessage(context, 'No email app found', Colors.red);
      }
    } catch (e) {
      _showMessage(context, 'Error: $e', Colors.red);
    }
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showMessage(context, 'Could not open URL', Colors.red);
      }
    } catch (e) {
      _showMessage(context, 'Error: $e', Colors.red);
    }
  }

  void _showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppConfiguration.primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.privacy_tip,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    AppConfiguration.privacyPolicy,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _launchUrl(
                            '${AppConfiguration.appUrl}/privacy',
                            context,
                          );
                        },
                        child: const Text('View Online'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

```import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../core/config/app_config.dart';

// Simple providers using Provider (not StateProvider)
final isLoadingProvider = Provider<bool>((ref) => false);

final errorMessageProvider = Provider<String?>((ref) => null);

// Simple functions (no state management needed)
void sendEmail(BuildContext context) async {
  try {
    final String to = AppConfiguration.contactEmail;
    const String subject = 'Support Request';
    const String body = 'Hello, I need help with your app.';

    final String emailUrl =
        'mailto:$to?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';
    final Uri uri = Uri.parse(emailUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No email app found')));
    }
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error: $e')));
  }
}

void launchUrlCustom(String url, BuildContext context) async {
  try {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open: $url')));
    }
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error: $e')));
  }
}

void shareApp(BuildContext context) async {
  final String message =
      'Check out ${AppConfiguration.appName} app!\nDownload from: ${AppConfiguration.appUrl}';
  await Share.share(message);
}
```

*/