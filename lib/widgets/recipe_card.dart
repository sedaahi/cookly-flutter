import 'package:flutter/material.dart';

import '../models/recipe_model.dart';
import '../theme/app_theme.dart';

class RecipeCard extends StatelessWidget {
  final RecipeModel recipe;
  final VoidCallback? onTap; //VoidCallback->parametre almayan ve geriye değer döndürmeyen bir fonksiyon
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalTime = recipe.prepTimeMinutes + recipe.cookTimeMinutes;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Stack(
                children: [
                  Image.network(
                    recipe.image,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 220,
                        child: Center(child: Icon(Icons.restaurant, size: 48)),
                      );
                    },
                  ),

                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        recipe.cuisine,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 16,
                    right: 16,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: IconButton(
                        onPressed: onFavoriteTap,
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite
                              ? AppTheme.primary
                              : AppTheme.textDark,
                        ),
                        iconSize: 24,
                        padding: const EdgeInsets.all(10),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFB347),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recipe.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(width: 18),

                      const Icon(
                        Icons.schedule_rounded,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 5),
                      Text('$totalTime min'),

                      const Spacer(),

                      Text(
                        recipe.difficulty,
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
