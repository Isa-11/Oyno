import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class VenueImage extends StatelessWidget {
  final String imageUrl;
  final String sport;
  final double height;
  final double iconSize;

  const VenueImage({
    super.key,
    required this.imageUrl,
    required this.sport,
    required this.height,
    this.iconSize = 48,
  });

  bool get _hasValidImageUrl {
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(trimmed);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  IconData get _sportIcon {
    switch (sport.toLowerCase()) {
      case 'football':
      case 'futbol':
      case 'soccer':
      case 'футбол':
        return Icons.sports_soccer;
      case 'basketball':
      case 'баскетбол':
        return Icons.sports_basketball;
      case 'volleyball':
      case 'волейбол':
        return Icons.sports_volleyball;
      case 'tennis':
      case 'теннис':
        return Icons.sports_tennis;
      case 'swimming':
      case 'плавание':
        return Icons.pool;
      default:
        return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasValidImageUrl) {
      return _buildFallback();
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallback(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }
          return Container(
            color: AppColors.surface,
            child: Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                    : null,
                color: AppColors.accent,
                strokeWidth: 2,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: double.infinity,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.cardBackground,
            AppColors.background,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_sportIcon, color: AppColors.accent, size: iconSize),
            const SizedBox(height: 12),
            Text(
              'Фото пока не добавлено',
              style: AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}