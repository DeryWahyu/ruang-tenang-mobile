import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A compact introduction that reuses the same RuNa poses as the member web UI.
class MascotHero extends StatelessWidget {
  final String title;
  final String description;
  final String pose;
  final String? eyebrow;
  final Widget? action;
  final bool overflowMascot;

  const MascotHero({
    super.key,
    required this.title,
    required this.description,
    required this.pose,
    this.eyebrow,
    this.action,
    this.overflowMascot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 152),
      clipBehavior: overflowMascot ? Clip.none : Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF1F2), Colors.white],
        ),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(28),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageWidth = constraints.maxWidth < 330 ? 100.0 : 132.0;
          final renderedImageWidth = imageWidth + (overflowMascot ? 12 : 0);
          return Stack(
            clipBehavior: overflowMascot ? Clip.none : Clip.hardEdge,
            children: [
              Positioned(
                right: overflowMascot ? -18 : -8,
                bottom: overflowMascot ? -12 : -4,
                width: renderedImageWidth,
                height: overflowMascot ? 166 : 150,
                child: Image.asset(
                  'assets/images/mascot/$pose.webp',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  excludeFromSemantics: true,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  renderedImageWidth - 4,
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (eyebrow != null)
                      Text(
                        eyebrow!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    if (eyebrow != null) const SizedBox(height: 5),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    if (action != null) ...[
                      const SizedBox(height: 12),
                      action!,
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
