import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../../core/theme/colors.dart';

/// Favorite Button Widget - Toggle favorite status
class FavoriteButton extends StatelessWidget {
  final String produceId;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const FavoriteButton({
    super.key,
    required this.produceId,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final isFavorite = favoritesProvider.isFavorite(produceId);

        return Material(
          color: Colors.white.withValues(alpha: 0.9),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () async {
              await favoritesProvider.toggleFavorite(produceId);
              
              // Show feedback
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isFavorite 
                          ? 'Removed from favorites' 
                          : 'Added to favorites',
                    ),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: size,
                color: isFavorite 
                    ? (activeColor ?? AppColors.error)
                    : (inactiveColor ?? AppColors.textSecondary),
              ),
            ),
          ),
        );
      },
    );
  }
}
