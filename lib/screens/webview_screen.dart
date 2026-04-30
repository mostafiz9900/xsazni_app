import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xsazni/core/widgets/loading_widget.dart';
import '../../../core/config/app_config.dart';
import '../../../core/router/app_router.dart';
import '../core/widgets/bottom_nav_bar.dart';
import '../providers/webview_notifier.dart';

// class WebViewScreen3 extends ConsumerWidget {
//   const WebViewScreen3({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final webState = ref.watch(webViewProvider);
//     final webNotifier = ref.read(webViewProvider.notifier);

//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) async {
//         if (didPop) return;
//         await webNotifier.handleBackNavigation();
//       },
//       child: Scaffold(
//         body: SafeArea(
//           child: Stack(
//             children: [
//               if (webState.hasError)
//                 ErrorCustomWidget(onRetry: webNotifier.reload)
//               else
//                 InAppWebView(
//                   initialUrlRequest: URLRequest(
//                     url: WebUri(AppConfiguration.appUrl),
//                   ),
//                   initialSettings: _getWebViewSettings(),
//                   onWebViewCreated: (controller) =>
//                       webNotifier.setController(controller),
//                   onLoadStart: (controller, url) =>
//                       webNotifier.setLoadStart(url?.toString() ?? ''),
//                   onLoadStop: (controller, url) =>
//                       webNotifier.setLoadStop(url?.toString() ?? ''),
//                   onProgressChanged: (controller, p) =>
//                       webNotifier.updateProgress(p),
//                   onLoadError: (controller, url, code, message) =>
//                       webNotifier.setLoadError(),
//                   shouldOverrideUrlLoading: (controller, action) =>
//                       _handleUrlOverride(action),
//                 ),
//               if (webState.isLoading && webState.progress < 100)
//                 LoadingWidget(progress: webState.progress / 100),
//             ],
//           ),
//         ),
//         bottomNavigationBar: BottomNavBar(),
//       ),
//     );
//   }

//   InAppWebViewSettings _getWebViewSettings() {
//     return InAppWebViewSettings(
//       javaScriptEnabled: AppConfiguration.enableJavaScript,
//       supportZoom: AppConfiguration.enableZoom,
//       builtInZoomControls: AppConfiguration.enableZoom,
//       useShouldOverrideUrlLoading: true,
//       allowFileAccess: true,
//       cacheEnabled: AppConfiguration.enableCache,
//       mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
//     );
//   }

//   Future<NavigationActionPolicy?> _handleUrlOverride(
//     NavigationAction action,
//   ) async {
//     final uri = action.request.url;
//     if (uri != null) {
//       final urlString = uri.toString();
//       if (urlString.contains('accounts.google.com'))
//         return NavigationActionPolicy.ALLOW;

//       if (urlString.startsWith('tel:') ||
//           urlString.startsWith('mailto:') ||
//           urlString.startsWith('whatsapp:')) {
//         if (await canLaunchUrl(uri)) {
//           await launchUrl(uri, mode: LaunchMode.externalApplication);
//         }
//         return NavigationActionPolicy.CANCEL;
//       }
//     }
//     return NavigationActionPolicy.ALLOW;
//   }
// }

class WebViewScreen extends ConsumerStatefulWidget {
  const WebViewScreen({super.key});

  @override
  ConsumerState<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends ConsumerState<WebViewScreen> {
  late InAppWebViewController webViewController;

  List<String> historyStack = [];
  bool isNavigating = false;
  bool isGoogleSignInPage = false;

  InAppWebViewSettings get settings => InAppWebViewSettings(
    isInspectable: false,
    javaScriptEnabled: AppConfiguration.enableJavaScript,
    javaScriptCanOpenWindowsAutomatically: true,
    supportZoom: AppConfiguration.enableZoom,
    builtInZoomControls: AppConfiguration.enableZoom,
    displayZoomControls: false,
    useShouldOverrideUrlLoading: true,
    allowFileAccess: true,
    cacheEnabled: AppConfiguration.enableCache,
    loadsImagesAutomatically: AppConfiguration.loadImages,
    mediaPlaybackRequiresUserGesture: true,
    allowsInlineMediaPlayback: true,
    allowsPictureInPictureMediaPlayback: true,
    geolocationEnabled: true,
    databaseEnabled: true,
    domStorageEnabled: true,
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
  );

  bool isLoading = true;
  bool hasError = false;
  int progress = 0;
  String currentUrl = AppConfiguration.appUrl;
  bool canGoBack = false;
  bool canGoForward = false;

  @override
  void initState() {
    super.initState();
    historyStack.add(AppConfiguration.appUrl);
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.exit_to_app,
                    color: Colors.red,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Exit App',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Message
                const Text(
                  'Are you sure you want to exit?',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);

                          if (AppConfiguration.backButtonExitApp) {
                            SystemNavigator.pop();
                          } else {}
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Exit',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        // await _handleBackNavigation();

        if (canGoBack) {
          await _handleBackNavigation();
        } else if (AppConfiguration.backButtonExitApp) {
          _showExitDialog();
          // if (context.mounted) {
          //   context.go(RoutePaths.home);
          // }
        }
      },
      child: Scaffold(
        // ✅ No AppBar - body full screen
        body: SafeArea(
          child: Stack(
            children: [
              if (hasError)
                _buildErrorWidget()
              else
                InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri(AppConfiguration.appUrl),
                  ),
                  initialSettings: settings,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) async {
                    final urlString = url?.toString() ?? '';
                    // print('=== LOAD START ===');
                    // print('URL: $urlString');

                    setState(() {
                      isLoading = true;
                      hasError = false;
                      currentUrl = urlString;
                      isGoogleSignInPage =
                          urlString.contains('accounts.google.com') ||
                          urlString.contains('google.com/signin');
                    });

                    if (historyStack.isEmpty ||
                        historyStack.last != urlString) {
                      historyStack.add(urlString);
                    }

                    final backStatus = await controller.canGoBack();
                    setState(() {
                      canGoBack = backStatus;
                    });
                  },
                  onLoadStop: (controller, url) async {
                    final urlString = url?.toString() ?? '';
                    // print('=== LOAD STOP ===');
                    // print('URL: $urlString');

                    setState(() {
                      isLoading = false;
                      currentUrl = urlString;
                      isGoogleSignInPage =
                          urlString.contains('accounts.google.com') ||
                          urlString.contains('google.com/signin');
                    });

                    canGoBack = await controller.canGoBack();
                    canGoForward = await controller.canGoForward();
                    isNavigating = false;
                  },
                  onProgressChanged: (controller, progress) {
                    setState(() {
                      this.progress = progress;
                    });
                  },
                  onLoadError: (controller, url, code, message) {
                    setState(() {
                      hasError = true;
                      isLoading = false;
                    });
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                        final uri = navigationAction.request.url;
                        if (uri != null) {
                          final urlString = uri.toString();

                          if (urlString.contains('accounts.google.com') ||
                              urlString.contains('google.com/signin')) {
                            return NavigationActionPolicy.ALLOW;
                          }

                          if (urlString.startsWith('tel:') ||
                              urlString.startsWith('mailto:') ||
                              urlString.startsWith('whatsapp://')) {
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                            return NavigationActionPolicy.CANCEL;
                          }
                        }
                        return NavigationActionPolicy.ALLOW;
                      },
                ),
              if (isLoading && progress < 100)
                LoadingWidget(progress: progress / 100),
            ],
          ),
        ),
        // ✅ Bottom Navigation Bar
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  // ✅ Bottom Navigation Bar with Back, Forward, Settings, Home
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // ✅ Back Button
              _buildNavButton(
                icon: Icons.arrow_back,
                label: 'Back',
                onPressed: (canGoBack || isGoogleSignInPage) && !isNavigating
                    ? _handleBackNavigation
                    : null,
              ),

              // ✅ Forward Button
              _buildNavButton(
                icon: Icons.arrow_forward,
                label: 'Forward',
                onPressed: canGoForward && !isNavigating
                    ? () async {
                        await webViewController.goForward();
                        await _updateNavigationState();
                      }
                    : null,
              ),

              // ✅ Settings Button
              _buildNavButton(
                icon: Icons.settings,
                label: 'Settings',
                onPressed: () {
                  context.pushNamed('settings');
                },
              ),

              // ✅ Home Button (Go to initial URL)
              // _buildNavButton(
              //   icon: Icons.home,
              //   label: 'Home',
              //   onPressed: () async {
              //     setState(() {
              //       isNavigating = true;
              //     });
              //     await webViewController.loadUrl(
              //       urlRequest: URLRequest(
              //         url: WebUri(AppConfiguration.appUrl),
              //       ),
              //     );
              //     historyStack.clear();
              //     historyStack.add(AppConfiguration.appUrl);
              //     setState(() {
              //       currentUrl = AppConfiguration.appUrl;
              //       isGoogleSignInPage = false;
              //       isNavigating = false;
              //     });
              //     await _updateNavigationState();
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Custom Navigation Button Widget
  Widget _buildNavButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    // বর্তমান থিমের কালার স্কিমটি নিয়ে আসা
    final colorScheme = Theme.of(context).colorScheme;

    // বাটন যখন একটিভ থাকবে তখন প্রাইমারি কালার, আর ডিজেবল থাকলে হালকা গ্রে
    final bool isEnabled = onPressed != null;
    final Color activeColor = colorScheme.primary;
    final Color disabledColor = colorScheme.onSurfaceVariant.withOpacity(0.38);

    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isEnabled ? activeColor : disabledColor,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isEnabled ? FontWeight.w600 : FontWeight.normal,
                  color: isEnabled ? activeColor : disabledColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Back Navigation Handler
  Future<void> _handleBackNavigation() async {
    ('=== HANDLE BACK NAVIGATION ===');
    // print('Current URL: $currentUrl');
    // print('canGoBack: $canGoBack');
    // prinprintt('isGoogleSignInPage: $isGoogleSignInPage');

    if (isNavigating) return;

    setState(() {
      isNavigating = true;
    });

    try {
      if (isGoogleSignInPage) {
        // ✅ Method 1: JavaScript back
        try {
          await webViewController.evaluateJavascript(
            source: 'window.history.back()',
          );
          await Future.delayed(const Duration(milliseconds: 300));

          final newUrl = await webViewController.getUrl();
          final newUrlString = newUrl?.toString() ?? '';

          if (!newUrlString.contains('accounts.google.com')) {
            setState(() {
              currentUrl = newUrlString;
              isGoogleSignInPage = false;
            });
            await _updateNavigationState();
            setState(() {
              isNavigating = false;
            });
            return;
          }
        } catch (e) {
          // print('JS back failed: $e');
        }

        // ✅ Method 2: Multiple goBack attempts
        for (int i = 0; i < 3; i++) {
          if (await webViewController.canGoBack()) {
            await webViewController.goBack();
            await Future.delayed(const Duration(milliseconds: 200));

            final newUrl = await webViewController.getUrl();
            final newUrlString = newUrl?.toString() ?? '';

            if (!newUrlString.contains('accounts.google.com')) {
              setState(() {
                currentUrl = newUrlString;
                isGoogleSignInPage = false;
              });
              await _updateNavigationState();
              setState(() {
                isNavigating = false;
              });
              return;
            }
          }
        }

        // ✅ Method 3: Load from history
        if (historyStack.length > 1) {
          await webViewController.loadUrl(
            urlRequest: URLRequest(
              url: WebUri(historyStack[historyStack.length - 2]),
            ),
          );
          await Future.delayed(const Duration(milliseconds: 300));
          setState(() {
            currentUrl = historyStack[historyStack.length - 2];
            isGoogleSignInPage = false;
          });
        }
      } else if (canGoBack) {
        await webViewController.goBack();
        await Future.delayed(const Duration(milliseconds: 200));

        final newUrl = await webViewController.getUrl();
        setState(() {
          currentUrl = newUrl?.toString() ?? '';
        });
      }

      await _updateNavigationState();
    } catch (e) {
      // print('Back navigation error: $e');
    } finally {
      setState(() {
        isNavigating = false;
      });
    }
  }

  // ✅ Update Navigation State
  Future<void> _updateNavigationState() async {
    try {
      final back = await webViewController.canGoBack();
      final forward = await webViewController.canGoForward();
      setState(() {
        canGoBack = back;
        canGoForward = forward;
      });
    } catch (e) {
      // print('Error updating navigation state: $e');
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 20),
          Text(
            AppConfiguration.errorMessage,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            'Please check your internet connection',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                hasError = false;
                isLoading = true;
              });
              webViewController.reload();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class WebViewScreen2 extends ConsumerStatefulWidget {
  const WebViewScreen2({super.key});

  @override
  ConsumerState<WebViewScreen2> createState() => _WebViewScreenState2();
}

class _WebViewScreenState2 extends ConsumerState<WebViewScreen2> {
  late InAppWebViewController webViewController;

  InAppWebViewSettings get settings => InAppWebViewSettings(
    isInspectable: false,
    javaScriptEnabled: AppConfiguration.enableJavaScript,
    javaScriptCanOpenWindowsAutomatically: true,
    supportZoom: AppConfiguration.enableZoom,
    builtInZoomControls: AppConfiguration.enableZoom,
    displayZoomControls: false,
    useShouldOverrideUrlLoading: true,
    allowFileAccess: true,
    cacheEnabled: AppConfiguration.enableCache,
    loadsImagesAutomatically: AppConfiguration.loadImages,
    mediaPlaybackRequiresUserGesture: false,
  );

  bool isLoading = true;
  bool hasError = false;
  int progress = 0;
  String currentUrl = AppConfiguration.appUrl;
  bool canGoBack = false;
  bool canGoForward = false;
  void _showExitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.exit_to_app,
                    color: Colors.red,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Exit App',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Message
                const Text(
                  'Are you sure you want to exit?',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);

                          if (AppConfiguration.backButtonExitApp) {
                            SystemNavigator.pop();
                          } else {}
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Exit',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }

        if (canGoBack) {
          await webViewController.goBack();
        } else if (AppConfiguration.backButtonExitApp) {
          _showExitDialog();
          // if (context.mounted) {
          //   context.go(RoutePaths.home);
          // }
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              if (hasError)
                _buildErrorWidget()
              else
                InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri(AppConfiguration.appUrl),
                  ),
                  initialSettings: settings,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      isLoading = true;
                      hasError = false;
                      currentUrl = url?.toString() ?? AppConfiguration.appUrl;
                    });
                  },
                  onLoadStop: (controller, url) async {
                    setState(() {
                      isLoading = false;
                      currentUrl = url?.toString() ?? AppConfiguration.appUrl;
                    });

                    canGoBack = await controller.canGoBack();
                    canGoForward = await controller.canGoForward();

                    // Stop loading indicator
                    // ref.read(isLoadingProvider.notifier).state = false;
                  },
                  onProgressChanged: (controller, progress) {
                    setState(() {
                      this.progress = progress;
                    });
                  },
                  onLoadError: (controller, url, code, message) {
                    setState(() {
                      hasError = true;
                      isLoading = false;
                    });
                    // ref.read(isLoadingProvider.notifier).state = false;
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                        final uri = navigationAction.request.url;

                        if (uri != null) {
                          final urlString = uri.toString();

                          // Handle external links
                          if (_isExternalLink(urlString)) {
                            await _launchExternalUrl(urlString);
                            return NavigationActionPolicy.CANCEL;
                          }
                        }

                        return NavigationActionPolicy.ALLOW;
                      },
                ),

              if (isLoading && progress < 100)
                LoadingWidget(progress: progress / 100),
            ],
          ),

          bottomNavigationBar: AppConfiguration.showBottomBar
              ? _buildBottomNavigationBar()
              : null,
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      // Refresh Button
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () => webViewController.reload(),
        tooltip: 'Refresh',
      ),

      // Share Button
      IconButton(
        icon: const Icon(Icons.share),
        onPressed: _shareUrl,
        tooltip: 'Share',
      ),

      // More Options
      PopupMenuButton<String>(
        onSelected: (value) async {
          switch (value) {
            case 'browser':
              await _openInBrowser();
              break;
            case 'copy':
              await _copyUrl();
              break;
            case 'home':
              context.go(RoutePaths.home);
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'browser',
            child: Row(
              children: [
                Icon(Icons.open_in_browser),
                SizedBox(width: 10),
                Text('Open in Browser'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'copy',
            child: Row(
              children: [
                Icon(Icons.copy),
                SizedBox(width: 10),
                Text('Copy URL'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'home',
            child: Row(
              children: [
                Icon(Icons.home),
                SizedBox(width: 10),
                Text('Go Home'),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: canGoBack
                  ? () async {
                      await webViewController.goBack();
                    }
                  : null,
            ),

            // Forward Button
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: canGoForward
                  ? () async {
                      await webViewController.goForward();
                    }
                  : null,
            ),

            // Refresh Button
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => webViewController.reload(),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                context.pushNamed('settings');
              },
              tooltip: 'Settings',
            ),
            // URL Display
            // Expanded(
            //   child: GestureDetector(
            //     onTap: _showUrlDialog,
            // child: Container(
            //   padding: const EdgeInsets.symmetric(
            //     horizontal: 12,
            //     vertical: 8,
            //   ),
            //   decoration: BoxDecoration(
            //     color: Colors.grey.withOpacity(0.2),
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   child: Text(
            //     currentUrl,
            //     style: const TextStyle(fontSize: 12),
            //     maxLines: 1,
            //     overflow: TextOverflow.ellipsis,
            //   ),
            // ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 20),
          Text(
            AppConfiguration.errorMessage,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            'Please check your internet connection',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                hasError = false;
                isLoading = true;
              });
              webViewController.reload();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
          TextButton.icon(
            onPressed: () {
              context.go(RoutePaths.home);
            },
            icon: const Icon(Icons.home),
            label: const Text('Go Home'),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  bool _isExternalLink(String url) {
    return url.startsWith('tel:') ||
        url.startsWith('mailto:') ||
        url.startsWith('whatsapp://') ||
        url.startsWith('market://');
  }

  Future<void> _shareUrl() async {
    await Share.share('Check out ${AppConfiguration.appName}: $currentUrl');
  }

  Future<void> _openInBrowser() async {
    await _launchExternalUrl(currentUrl);
  }

  Future<void> _copyUrl() async {
    await Clipboard.setData(ClipboardData(text: currentUrl));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('URL copied to clipboard')));
    }
  }

  Future<void> _launchExternalUrl(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _showUrlDialog() async {
    final controller = TextEditingController(text: currentUrl);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Navigate to URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter website URL',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              var newUrl = controller.text;
              if (!newUrl.startsWith('http')) {
                newUrl = 'https://$newUrl';
              }
              // webViewController.loadRequest(url: WebUri(newUrl));
              Navigator.pop(context);
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }
}
