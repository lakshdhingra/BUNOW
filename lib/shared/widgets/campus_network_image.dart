import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';

/// Displays a cached network image with a consistent dark placeholder and fallback.
class CampusNetworkImage extends StatelessWidget {
  const CampusNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackIcon = Icons.image_outlined,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, _) => _ImageFallback(
        width: width,
        height: height,
        icon: fallbackIcon,
        isLoading: true,
      ),
      errorWidget: (_, _, _) => _ImageFallback(
        width: width,
        height: height,
        icon: fallbackIcon,
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({
    this.width,
    this.height,
    required this.icon,
    this.isLoading = false,
  });

  final double? width;
  final double? height;
  final IconData icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceElevated,
            AppColors.surface,
            Color(0xFF1A1636),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 28,
        color: AppColors.textMuted.withValues(alpha: isLoading ? 0.35 : 0.7),
      ),
    );
  }
}
