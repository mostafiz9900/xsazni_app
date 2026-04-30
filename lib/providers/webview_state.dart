class WebViewState {
  final bool isLoading;
  final bool hasError;
  final int progress;
  final String currentUrl;
  final bool canGoBack;
  final bool canGoForward;
  final bool isGoogleSignInPage;
  final bool isNavigating;

  WebViewState({
    this.isLoading = true,
    this.hasError = false,
    this.progress = 0,
    this.currentUrl = '',
    this.canGoBack = false,
    this.canGoForward = false,
    this.isGoogleSignInPage = false,
    this.isNavigating = false,
  });

  WebViewState copyWith({
    bool? isLoading,
    bool? hasError,
    int? progress,
    String? currentUrl,
    bool? canGoBack,
    bool? canGoForward,
    bool? isGoogleSignInPage,
    bool? isNavigating,
  }) {
    return WebViewState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      progress: progress ?? this.progress,
      currentUrl: currentUrl ?? this.currentUrl,
      canGoBack: canGoBack ?? this.canGoBack,
      canGoForward: canGoForward ?? this.canGoForward,
      isGoogleSignInPage: isGoogleSignInPage ?? this.isGoogleSignInPage,
      isNavigating: isNavigating ?? this.isNavigating,
    );
  }
}
