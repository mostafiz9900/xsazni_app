import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xsazni/core/widgets/loading_widget.dart';
import 'package:xsazni/providers/app_providers.dart';
import '../../../core/config/app_config.dart';
import '../../../core/router/app_router.dart';

class WebViewScreen extends ConsumerStatefulWidget {
  const WebViewScreen({super.key});

  @override
  ConsumerState<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends ConsumerState<WebViewScreen> {
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (canGoBack) {
          await webViewController.goBack();
        } else if (AppConfiguration.backButtonExitApp) {
          if (context.mounted) {
            context.go(RoutePaths.home);
          }
        }
      },
      child: SafeArea(
        child: Scaffold(
          // appBar: AppConfiguration.showAppBar
          //     ? AppBar(
          //         title: Text(AppConfiguration.appName),
          //         centerTitle: true,
          //         actions: _buildAppBarActions(),
          //       )
          //     : null,
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
                    ref.read(isLoadingProvider.notifier).state = false;
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
                    ref.read(isLoadingProvider.notifier).state = false;
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
