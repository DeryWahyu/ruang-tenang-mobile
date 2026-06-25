import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';

/// Shimmer loading skeleton
class AppSkeleton extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const AppSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  /// Circle skeleton (for avatars)
  const AppSkeleton.circle({
    super.key,
    double size = 40,
  })  : width = size,
        height = size,
        borderRadius = 999;

  /// Text line skeleton
  const AppSkeleton.text({
    super.key,
    this.width,
  })  : height = 14,
        borderRadius = 4;

  /// Card skeleton
  const AppSkeleton.card({
    super.key,
    this.width,
    this.height = 120,
  }) : borderRadius = AppDimensions.radiusXl;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.gray200,
      highlightColor: AppColors.gray100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.gray200,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Pre-built skeleton layouts
class AppSkeletonList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final EdgeInsetsGeometry? padding;

  const AppSkeletonList({
    super.key,
    this.itemCount = 5,
    required this.itemBuilder,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      padding: padding ?? const EdgeInsets.all(AppDimensions.spacingBase),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: itemBuilder,
    );
  }
}

/// Common skeleton: list item with avatar, title, subtitle
class AppSkeletonListItem extends StatelessWidget {
  const AppSkeletonListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingBase),
      child: Row(
        children: [
          const AppSkeleton.circle(size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton.text(width: MediaQuery.sizeOf(context).width * 0.5),
                const SizedBox(height: 8),
                AppSkeleton.text(width: MediaQuery.sizeOf(context).width * 0.3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Common skeleton: card with image and text
class AppSkeletonCard extends StatelessWidget {
  const AppSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingBase),
      padding: const EdgeInsets.all(AppDimensions.spacingBase),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSkeleton(height: 140, borderRadius: 12),
          const SizedBox(height: 12),
          AppSkeleton.text(width: MediaQuery.sizeOf(context).width * 0.7),
          const SizedBox(height: 8),
          AppSkeleton.text(width: MediaQuery.sizeOf(context).width * 0.5),
          const SizedBox(height: 8),
          AppSkeleton.text(width: MediaQuery.sizeOf(context).width * 0.3),
        ],
      ),
    );
  }
}
