import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A compact introduction that reuses the same RuNa poses as the member web UI.
class MascotHero extends StatelessWidget {
  final String title;
  final String description;
  final String pose;
  final String? eyebrow;
  final Widget? action;

  const MascotHero({
    super.key,
    required this.title,
    required this.description,
    required this.pose,
    this.eyebrow,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 152),
      clipBehavior: Clip.antiAlias,
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
          return Stack(
            children: [
              Positioned(
                right: -8,
                bottom: -4,
                width: imageWidth,
                height: 150,
                child: Image.asset(
                  'assets/images/mascot/$pose.webp',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  excludeFromSemantics: true,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 20, imageWidth - 4, 20),
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
