import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/router/app_router.dart';
import '../core/widgets/loading_widget.dart';
import '../providers/app_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    
    return Scaffold(
      appBar: AppConfiguration.showAppBar
          ? AppBar(
              title: Text(AppConfiguration.appName),
              centerTitle: true,
              actions: [
                // Theme Toggle
                IconButton(
                  icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () {
                    final currentMode = ref.read(themeModeProvider.notifier).state;
                    ref.read(themeModeProvider.notifier).state = 
                        currentMode == ThemeMode.light 
                            ? ThemeMode.dark 
                            : ThemeMode.light;
                  },
                  tooltip: 'Toggle Theme',
                ),
                
                // Settings
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    context.pushNamed('settings');
                  },
                  tooltip: 'Settings',
                ),
              ],
            )
          : null,
      
      body: isLoading 
          ? const LoadingWidget()
          : _buildMainContent(context, ref),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(RoutePaths.webview);
        },
        child: const Icon(Icons.web),
      ),
    );
  }
  
  Widget _buildMainContent(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App Icon
          Container(
            decoration: BoxDecoration(
              color: AppConfiguration.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(30),
            child: Text(
              AppConfiguration.appIcon,
              style: const TextStyle(fontSize: 80),
            ),
          ),
          const SizedBox(height: 30),
          
          // App Name
          Text(
            AppConfiguration.appName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          
          // URL
          Text(
            AppConfiguration.appUrl,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 40),
          
          // Start Button
          ElevatedButton.icon(
            onPressed: () {
              ref.read(isLoadingProvider.notifier).state = true;
              context.go(RoutePaths.webview);
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Open Web App'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}