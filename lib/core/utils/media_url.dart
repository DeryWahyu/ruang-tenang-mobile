import '../constants/api_constants.dart';

/// Resolves a possibly-relative media path (e.g. an avatar or thumbnail) to an
/// absolute URL using the API base URL.
///
/// Returns `null` for empty/blank input so avatar widgets can fall back to
/// initials instead of showing a broken image.
String? resolveMediaUrl(String? url) {
  if (url == null) return null;
  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  final base = ApiConstants.baseUrl;
  final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return '$base$path'
      .replaceAll('//storage', '/storage')
      .replaceAll('//public', '/public')
      .replaceAll('//uploads', '/uploads');
}
