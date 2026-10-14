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
  Set<int> myRecipeIds = {};

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    widget.refreshListenable.addListener(onRefreshRequested);
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

  void onRefreshRequested() {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Favori olarak kaydedilmiş tarif ID'lerini al.
      final favoriteIds = (await _storageService.getFavorites()).toSet();

      // Kullanıcının kendi tariflerini al.
      final myRecipes = await _storageService.getMyRecipes();

      final localRecipeIds = myRecipes.map((recipe) => recipe.id).toSet();

      // Önce yerel favorileri bul.
      final localFavorites = myRecipes
          .where((recipe) => favoriteIds.contains(recipe.id))
          .toList();

      if (favoriteIds.isEmpty) {
        if (!mounted) return;

        setState(() {
          favoriteRecipes = [];
          myRecipeIds = localRecipeIds;
          isLoading = false;
        });
        return;
      }

      // API tarafında aranacak favori ID'leri.
      final apiFavoriteIds = favoriteIds.difference(localRecipeIds);

      List<RecipeModel> apiFavorites = [];
      bool apiFailed = false;

      if (apiFavoriteIds.isNotEmpty) {
        try {
          final apiRecipes = await _apiService.getRecipes();

          apiFavorites = apiRecipes
              .where((recipe) => apiFavoriteIds.contains(recipe.id))
              .toList();
        } catch (e) {
          debugPrint('FAVORITES API ERROR: $e');
          apiFailed = true;
        }
      }

      if (!mounted) return;

      setState(() {
        // Hem kendi favorilerimiz hem API favorileri.
        favoriteRecipes = [...localFavorites, ...apiFavorites];

        myRecipeIds = localRecipeIds;

        if (apiFailed) {
          errorMessage = 'Online favorites could not be loaded.';
        }

        isLoading = false;
      });
    } catch (e) {
      debugPrint('LOAD FAVORITES ERROR: $e');

      if (!mounted) return;

      setState(() {
        errorMessage = 'Could not load favorites.';
        isLoading = false;
      });
    }
  }

  Future<void> removeFavorite(int recipeId) async {
    try {
      await _storageService.toggleFavorite(recipeId);

      if (!mounted) return;

      await loadFavorites();
    } catch (e) {
      debugPrint('REMOVE FAVORITE ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not remove favorite. Please try again.'),
        ),
      );
    }
  }

  Future<void> openRecipe(RecipeModel recipe) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(
          recipe: recipe,
          isMyRecipe: myRecipeIds.contains(recipe.id),
        ),
      ),
    );

    // Tarif güncellenmiş veya silinmiş olabilir.
    if (result == true) {
      await loadFavorites();
    }
  }

  Widget buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 180),

        Icon(Icons.favorite_border_rounded, size: 76, color: AppTheme.primary),

        SizedBox(height: 20),

        Center(
          child: Text(
            'No favorites yet!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
    );
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
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),

                children: [
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 36),

                          const SizedBox(height: 8),

                          Text(errorMessage!, textAlign: TextAlign.center),

                          TextButton(
                            onPressed: loadFavorites,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),

                  if (favoriteRecipes.isEmpty)
                    SizedBox(height: 450, child: buildEmptyState())
                  else
                    ...favoriteRecipes.map(
                      (recipe) => RecipeCard(
                        recipe: recipe,
                        isFavorite: true,

                        onFavoriteTap: () => removeFavorite(recipe.id),

                        onTap: () => openRecipe(recipe),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
