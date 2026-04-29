class UrlHelper {
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;
    
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return false;
    }
    
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasAuthority;
  }
  
  static String formatUrl(String url) {
    var formattedUrl = url.trim();
    
    if (!formattedUrl.startsWith('http://') && 
        !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }
    
    return formattedUrl;
  }
  
  static String getDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url;
    }
  }
}