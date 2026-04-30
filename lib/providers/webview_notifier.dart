import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../core/config/app_config.dart';
import 'webview_state.dart';

final webViewProvider = NotifierProvider<WebViewNotifier, WebViewState>(() {
  return WebViewNotifier();
});

class WebViewNotifier extends Notifier<WebViewState> {
  InAppWebViewController? _controller;
  final List<String> _historyStack = [AppConfiguration.appUrl];

  @override
  WebViewState build() {
    return WebViewState(currentUrl: AppConfiguration.appUrl);
  }

  void setController(InAppWebViewController controller) {
    _controller = controller;
  }

  void updateProgress(int progress) {
    state = state.copyWith(progress: progress);
  }

  void setLoadStart(String url) {
    state = state.copyWith(
      isLoading: true,
      hasError: false,
      currentUrl: url,
      isGoogleSignInPage: url.contains('accounts.google.com') || url.contains('google.com/signin'),
    );

    if (_historyStack.isEmpty || _historyStack.last != url) {
      _historyStack.add(url);
    }
  }

  Future<void> setLoadStop(String url) async {
    final back = await _controller?.canGoBack() ?? false;
    final forward = await _controller?.canGoForward() ?? false;

    state = state.copyWith(
      isLoading: false,
      currentUrl: url,
      canGoBack: back,
      canGoForward: forward,
      isNavigating: false,
      isGoogleSignInPage: url.contains('accounts.google.com') || url.contains('google.com/signin'),
    );
  }

  void setLoadError() {
    state = state.copyWith(hasError: true, isLoading: false);
  }

  Future<void> handleBackNavigation() async {
    if (state.isNavigating || _controller == null) return;

    state = state.copyWith(isNavigating: true);

    try {
      if (state.isGoogleSignInPage) {
        // Logic for Google Sign-in back navigation
        await _controller!.evaluateJavascript(source: 'window.history.back()');
        await Future.delayed(const Duration(milliseconds: 300));
        
        final current = await _controller!.getUrl();
        if (current != null && !current.toString().contains('accounts.google.com')) {
          await _updateNavigationState();
          return;
        }
        
        // Fallback to history stack if JS fails
        if (_historyStack.length > 1) {
          await _controller!.loadUrl(
            urlRequest: URLRequest(url: WebUri(_historyStack[_historyStack.length - 2])),
          );
        }
      } else if (state.canGoBack) {
        await _controller!.goBack();
      }
      await _updateNavigationState();
    } finally {
      state = state.copyWith(isNavigating: false);
    }
  }

  Future<void> goForward() async {
    if (_controller != null) {
      await _controller!.goForward();
      await _updateNavigationState();
    }
  }

  Future<void> reload() async {
    state = state.copyWith(hasError: false, isLoading: true);
    await _controller?.reload();
  }

  Future<void> _updateNavigationState() async {
    final back = await _controller?.canGoBack() ?? false;
    final forward = await _controller?.canGoForward() ?? false;
    final url = await _controller?.getUrl();
    
    state = state.copyWith(
      canGoBack: back,
      canGoForward: forward,
      currentUrl: url?.toString() ?? state.currentUrl,
    );
  }
}