import 'package:flutter/foundation.dart';

@immutable
class PodCacheConfig {
  final bool enableCache;
  final Duration cacheDuration;
  final int maxCacheObjects;
  final Map<String, String>? webCacheHeaders;

  const PodCacheConfig({
    this.enableCache = true,
    this.cacheDuration = const Duration(days: 7),
    this.maxCacheObjects = 500,
    this.webCacheHeaders,
  });

  /// Creates cache headers for Web platform
  Map<String, String> getWebHeaders(Map<String, String> existingHeaders) {
    if (!kIsWeb || !enableCache) return existingHeaders;
    
    final headers = Map<String, String>.from(existingHeaders);
    
    // Use custom headers if provided
    if (webCacheHeaders != null) {
      headers.addAll(webCacheHeaders!);
    } else if (!headers.containsKey('Cache-Control')) {
      // Add default cache headers for Web platform
      final maxAge = cacheDuration.inSeconds;
      headers['Cache-Control'] = 'max-age=$maxAge';
      headers['Pragma'] = 'cache';
      headers['Expires'] = DateTime.now()
          .add(cacheDuration)
          .toUtc()
          .toIso8601String();
    }
    
    return headers;
  }

  PodCacheConfig copyWith({
    bool? enableCache,
    Duration? cacheDuration,
    int? maxCacheObjects,
    Map<String, String>? webCacheHeaders,
  }) {
    return PodCacheConfig(
      enableCache: enableCache ?? this.enableCache,
      cacheDuration: cacheDuration ?? this.cacheDuration,
      maxCacheObjects: maxCacheObjects ?? this.maxCacheObjects,
      webCacheHeaders: webCacheHeaders ?? this.webCacheHeaders,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PodCacheConfig &&
        other.enableCache == enableCache &&
        other.cacheDuration == cacheDuration &&
        other.maxCacheObjects == maxCacheObjects &&
        _mapEquals(other.webCacheHeaders, webCacheHeaders);
  }

  @override
  int get hashCode {
    return enableCache.hashCode ^
        cacheDuration.hashCode ^
        maxCacheObjects.hashCode ^
        (webCacheHeaders?.hashCode ?? 0);
  }

  bool _mapEquals(Map<String, String>? a, Map<String, String>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}