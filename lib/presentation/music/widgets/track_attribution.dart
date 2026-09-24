import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/music.dart';

class TrackAttribution extends StatelessWidget {
  final Song song;

  const TrackAttribution({super.key, required this.song});

  Future<void> _openLink(String? value) async {
    if (value == null || value.trim().isEmpty) return;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if ((song.attribution ?? '').isEmpty &&
        (song.sourceUrl ?? '').isEmpty &&
        (song.licenseUrl ?? '').isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if ((song.attribution ?? '').isNotEmpty)
          Text(
            song.attribution!,
            style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground),
          ),
        if ((song.sourceUrl ?? '').isNotEmpty)
          InkWell(
            onTap: () => _openLink(song.sourceUrl),
            child: const Text(
              'Sumber',
              style: TextStyle(fontSize: 10, color: AppColors.mutedForeground, decoration: TextDecoration.underline),
            ),
          ),
        if ((song.licenseUrl ?? '').isNotEmpty)
          InkWell(
            onTap: () => _openLink(song.licenseUrl),
            child: const Text(
              'Lisensi',
              style: TextStyle(fontSize: 10, color: AppColors.mutedForeground, decoration: TextDecoration.underline),
            ),
          ),
      ],
    );
  }
}
