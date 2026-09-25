import 'package:cached_network_image/cached_network_image.dart';

import 'media_url.dart';

/// Helpers that share the same disk cache used by [CachedNetworkImage].
class ImageCacheService {
  const ImageCacheService._();

  /// Downloads a media URL into the image disk cache without blocking the UI.
  ///
  /// Callers can use a short timeout before publishing new profile data so an
  /// already visible avatar stays in place while the next one is prepared.
  static Future<void> prefetch(
    String? source, {
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final url = resolveMediaUrl(source);
    if (url == null) return;

    try {
      await CachedNetworkImageProvider.defaultCacheManager
          .getSingleFile(url)
          .timeout(timeout);
    } catch (_) {
      // Prefetching is opportunistic. The image widget still handles loading
      // and errors if the network or cache is unavailable.
    }
  }
}
