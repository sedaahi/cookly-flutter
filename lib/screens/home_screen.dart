
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/recipe_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueListenable<int> refreshListenable;

  const HomeScreen({
    super.key,
    required this.refreshListenable,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  final LocalStorageService _localStorageService =
      LocalStorageService();

  final TextEditingController searchController =
      TextEditingController();

  // API ve kullanıcının tariflerini ayrı tutuyoruz.
  List<RecipeModel> apiRecipes = [];
  List<RecipeModel> myRecipes = [];

  Set<int> favoriteIds = {};

  bool isLoading = true;
  String errorMessage = '';

  String selectedCategory = 'All';
  String searchQuery = '';

  final List<String> categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Snack',
    'Appetizer',
    'Beverage',
  ];

  @override
  void initState() {
    super.initState();

    loadRecipes();
    loadFavorites();

    widget.refreshListenable.addListener(refreshLocalData);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refreshListenable !=
        widget.refreshListenable) {
      oldWidget.refreshListenable.removeListener(
        refreshLocalData,
      );

      widget.refreshListenable.addListener(
        refreshLocalData,
      );
    }
  }

  @override
  void dispose() {
    widget.refreshListenable.removeListener(
      refreshLocalData,
    );

    searchController.dispose();
    super.dispose();
  }

  // Hem API hem de yerel tarifleri yükler.
  Future<void> loadRecipes() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    // Yerel tarifleri API'den bağımsız yükle.
    await loadMyRecipes();

    try {
      final result = await apiService.getRecipes();

      if (!mounted) return;

      setState(() {
        apiRecipes = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('LOAD API RECIPES ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Could not load online recipes.';
      });
    }
  }

  // Kullanıcının kendi tariflerini yükler.
  Future<void> loadMyRecipes() async {
    try {
      final savedRecipes =
          await _localStorageService.getMyRecipes();

      if (!mounted) return;

      setState(() {
        myRecipes = savedRecipes;
      });
    } catch (e) {
      debugPrint('LOAD MY RECIPES ERROR: $e');
    }
  }

  // Favori listesini yükler.
  Future<void> loadFavorites() async {
    final savedIds =
        await _localStorageService.getFavorites();

    if (!mounted) return;

    setState(() {
      favoriteIds = savedIds.toSet();
    });
  }

  // Yerel veriler değiştiğinde iki listeyi de yeniler.
  Future<void> refreshLocalData() async {
    await Future.wait([
      loadMyRecipes(),
      loadFavorites(),
    ]);
  }

  // Sayfa aşağı çekildiğinde bütün verileri yeniler.
  Future<void> refreshAll() async {
    await Future.wait([
      loadRecipes(),
      loadFavorites(),
    ]);
  }

  Future<void> toggleFavorite(int recipeId) async {
    final isNowFavorite =
        await _localStorageService.toggleFavorite(recipeId);

    if (!mounted) return;

    setState(() {
      if (isNowFavorite) {
        favoriteIds.add(recipeId);
      } else {
        favoriteIds.remove(recipeId);
      }
    });
  }

  // İki farklı kaynaktan gelen tarifleri birleştirir.
  List<RecipeModel> get allRecipes {
    return [
      ...myRecipes,
      ...apiRecipes,
    ];
  }

  // Bir tarifin kullanıcıya ait olup olmadığını kontrol eder.
  bool isMyRecipe(int recipeId) {
    return myRecipes.any(
      (recipe) => recipe.id == recipeId,
    );
  }

  // Kategori ve arama filtreleri bütün tariflere uygulanır.
  List<RecipeModel> get filteredRecipes {
    final query = searchQuery.trim().toLowerCase();

    return allRecipes.where((recipe) {
      final matchesCategory =
          selectedCategory == 'All' ||
          recipe.mealType.contains(selectedCategory);

      final matchesSearch =
          recipe.name.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Tarif detayına gider.
  Future<void> openRecipe(RecipeModel recipe) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(
          recipe: recipe,
          isMyRecipe: isMyRecipe(recipe.id),
        ),
      ),
    );

    // Tarif güncellendiyse veya silindiyse listeyi yenile.
    if (result == true) {
      await refreshLocalData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleRecipes = filteredRecipes;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cookly.',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.favorite_border_rounded,
            ),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: refreshAll,

        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),

          children: [
            const SizedBox(height: 14),

            const Text(
              'What are we cooking\ntoday?',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                height: 1.2,
                color: AppTheme.textDark,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Find something delicious to make.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 46,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,

                separatorBuilder: (_, _) =>
                    const SizedBox(width: 10),

                itemBuilder: (context, index) {
                  final category = categories[index];

                  final isSelected =
                      selectedCategory == category;

                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: AppTheme.primary,
                    backgroundColor: Colors.white,

                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppTheme.textDark,
                      fontWeight: FontWeight.w600,
                    ),

                    side: BorderSide.none,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(24),
                    ),

                    onSelected: (_) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  'Discover Recipes',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  '${visibleRecipes.length} recipes',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              // API yüklenemese bile yerel tarifler gösterilir.
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 16,
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 36,
                      ),
                      const SizedBox(height: 8),

                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                      ),

                      TextButton(
                        onPressed: loadRecipes,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),

              if (visibleRecipes.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text('No recipes found.'),
                  ),
                )
              else
                ...visibleRecipes.map(
                  (recipe) => RecipeCard(
                    recipe: recipe,

                    isFavorite:
                        favoriteIds.contains(recipe.id),

                    onFavoriteTap: () =>
                        toggleFavorite(recipe.id),

                    onTap: () => openRecipe(recipe),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
