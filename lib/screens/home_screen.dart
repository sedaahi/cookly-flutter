import 'package:flutter/material.dart';

import '../models/recipe_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

import '../theme/app_theme.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController searchController = TextEditingController();
  final LocalStorageService _localStorageService = LocalStorageService();

  List<RecipeModel> recipes = [];
  bool isLoading = true;
  String errorMessage = '';

  String selectedCategory = 'All';
  String searchQuery = '';

  Set<int> favoriteIds = {};

  final List<String> categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Snack',
    'Appetizer',
  ];

  Future<void> loadRecipes() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final result = await apiService.getRecipes();

      if (!mounted) return;

      setState(() {
        recipes = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  List<RecipeModel> get filteredRecipes {
    return recipes.where((recipe) {
      final matchesCategory =
          selectedCategory == 'All' ||
          recipe.mealType.contains(selectedCategory);

      final matchesSearch = recipe.name.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> loadFavorites() async {
    final savedIds = await _localStorageService.getFavorites();

    if (!mounted) return;

    setState(() {
      favoriteIds = savedIds.toSet();
    });
  }

  Future<void> toggleFavorite(int recipeId) async {
    final isNowFavorite = await _localStorageService.toggleFavorite(recipeId);

    if (!mounted) return;

    setState(() {
      if (isNowFavorite) {
        favoriteIds.add(recipeId);
      } else {
        favoriteIds.remove(recipeId);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadRecipes(); // Mevcut API yükleme metodunun adını koru
    loadFavorites();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
            icon: const Icon(Icons.favorite_border_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadRecipes,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              style: TextStyle(fontSize: 14, color: Colors.black54),
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
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 46,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;

                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: AppTheme.primary,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Discover Recipes',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
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
                child: Center(child: CircularProgressIndicator()),
              )
            else if (errorMessage.isNotEmpty)
              Column(
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 48),
                  const SizedBox(height: 12),
                  Text(errorMessage, textAlign: TextAlign.center),
                  TextButton(
                    onPressed: loadRecipes,
                    child: const Text('Try Again'),
                  ),
                ],
              )
            else if (visibleRecipes.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: Text('No recipes found.')),
              )
            else
              ...visibleRecipes.map(
                (recipe) => RecipeCard(
                  isFavorite: favoriteIds.contains(recipe.id),
                  onFavoriteTap: () => toggleFavorite(recipe.id),
                  recipe: recipe,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
