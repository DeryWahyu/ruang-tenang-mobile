import '../constants/api_constants.dart';

/// Resolves a possibly-relative media path (e.g. an avatar or thumbnail) to an
/// absolute URL using the API base URL.
///
/// Returns `null` for empty/blank input so avatar widgets can fall back to
/// initials instead of showing a broken image.
/// [cacheBuster] can be provided (like a timestamp string) to append `?v=cacheBuster` 
/// for invalidating cache when the resource is updated on the server.
String? resolveMediaUrl(String? url, {String? cacheBuster}) {
  if (url == null) return null;
  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;
  
  String resolved;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    resolved = trimmed;
  } else {
    final base = ApiConstants.baseUrl;
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    resolved = '$base$path'
        .replaceAll('//storage', '/storage')
        .replaceAll('//public', '/public')
        .replaceAll('//uploads', '/uploads');
  }

  if (cacheBuster != null && cacheBuster.isNotEmpty) {
    final separator = resolved.contains('?') ? '&' : '?';
    resolved = '$resolved${separator}v=$cacheBuster';
  }

  return resolved;
}
