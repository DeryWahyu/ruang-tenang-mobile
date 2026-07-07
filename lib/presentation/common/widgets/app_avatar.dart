import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/media_url.dart';

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

  String? get _fullImageUrl {
    return resolveMediaUrl(imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar = Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? AppColors.red100,
        border: showBorder
            ? Border.all(color: AppColors.card, width: 2)
            : null,
      ),
      child: _fullImageUrl != null && _fullImageUrl!.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: _fullImageUrl!,
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
    return Container(
      width: size,
      height: size,
      color: backgroundColor ?? AppColors.card,
      child: Image.asset(
        'assets/images/dummy-profile.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
