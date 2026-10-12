import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/recipe_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final ValueListenable<int> refreshListenable;

  const FavoritesScreen({super.key, required this.refreshListenable});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ApiService _apiService = ApiService();
  final LocalStorageService _storageService = LocalStorageService();

  List<RecipeModel> favoriteRecipes = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    widget.refreshListenable.addListener(onRefreshRequested);
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final favoriteIds = await _storageService.getFavorites();

      if (favoriteIds.isEmpty) {
        if (!mounted) return;

        setState(() {
          favoriteRecipes = [];
          isLoading = false;
        });
        return;
      }

      final allRecipes = await _apiService.getRecipes();

      if (!mounted) return;

      setState(() {
        favoriteRecipes = allRecipes
            .where((recipe) => favoriteIds.contains(recipe.id))
            .toList();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Could not load favorites.';
        isLoading = false;
      });
    }
  }

  void onRefreshRequested() {
    loadFavorites();
  }

  @override
  void didUpdateWidget(covariant FavoritesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refreshListenable != widget.refreshListenable) {
      oldWidget.refreshListenable.removeListener(onRefreshRequested);
      widget.refreshListenable.addListener(onRefreshRequested);
    }
  }

  @override
  void dispose() {
    widget.refreshListenable.removeListener(onRefreshRequested);
    super.dispose();
  }

  Future<void> removeFavorite(int recipeId) async {
    await _storageService.toggleFavorite(recipeId);
    await loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Favorites',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: loadFavorites,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(child: Text(errorMessage!))
            : favoriteRecipes.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 180),
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 76,
                    color: AppTheme.primary,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'No favorites yet!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Save your favorite recipes and find them here anytime.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: favoriteRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = favoriteRecipes[index];

                  return RecipeCard(
                    recipe: recipe,
                    isFavorite: true,
                    onFavoriteTap: () => removeFavorite(recipe.id),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetailScreen(recipe: recipe),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
