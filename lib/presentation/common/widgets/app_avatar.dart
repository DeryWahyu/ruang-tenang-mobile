import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool showBorder;
  final Widget? badge;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppDimensions.avatarMd,
    this.backgroundColor,
    this.onTap,
    this.showBorder = false,
    this.badge,
  });

  const AppAvatar.small({
    super.key,
    this.imageUrl,
    this.name,
    this.backgroundColor,
    this.onTap,
    this.showBorder = false,
    this.badge,
  }) : size = AppDimensions.avatarSm;

  const AppAvatar.medium({
    super.key,
    this.imageUrl,
    this.name,
    this.backgroundColor,
    this.onTap,
    this.showBorder = false,
    this.badge,
  }) : size = AppDimensions.avatarMd;

  const AppAvatar.large({
    super.key,
    this.imageUrl,
    this.name,
    this.backgroundColor,
    this.onTap,
    this.showBorder = false,
    this.badge,
  }) : size = AppDimensions.avatarLg;

  const AppAvatar.xl({
    super.key,
    this.imageUrl,
    this.name,
    this.backgroundColor,
    this.onTap,
    this.showBorder = false,
    this.badge,
  }) : size = AppDimensions.avatarXl;

  String get _initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  double get _fontSize {
    if (size <= AppDimensions.avatarSm) return 12;
    if (size <= AppDimensions.avatarMd) return 14;
    if (size <= AppDimensions.avatarLg) return 20;
    return 28;
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? AppColors.red100,
        border: showBorder
            ? Border.all(color: AppColors.card, width: 2)
            : null,
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildInitials(),
                errorWidget: (context, url, error) => _buildInitials(),
              ),
            )
          : _buildInitials(),
    );

    if (badge != null) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: -2,
            bottom: -2,
            child: badge!,
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        _initials,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: _fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
