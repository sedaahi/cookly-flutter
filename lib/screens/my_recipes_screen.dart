import 'package:flutter/material.dart';

import '../models/recipe_model.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import 'recipe_form_screen.dart';
import 'recipe_detail_screen.dart';
import '../widgets/recipe_image.dart';

class MyRecipesScreen extends StatefulWidget {
  const MyRecipesScreen({super.key});

  @override
  State<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  final LocalStorageService _storageService = LocalStorageService();

  List<RecipeModel> myRecipes = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadMyRecipes();
  }

  Future<void> loadMyRecipes() async {
    try {
      final recipes = await _storageService.getMyRecipes();

      if (!mounted) return;

      setState(() {
        myRecipes = recipes;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Could not load your recipes.';
      });
    }
  }

  Future<void> openRecipeForm() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const RecipeFormScreen()),
    );

    if (saved == true) {
      await loadMyRecipes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Recipes',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : myRecipes.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 76,
                      color: AppTheme.primary,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Your cookbook is empty!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Create your own recipes and keep them all in one place.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: myRecipes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final recipe = myRecipes[index];

                return Card(
                  color: Colors.white,
                  elevation: 0,
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetailScreen(recipe: recipe),
                        ),
                      );
                    },
                    contentPadding: const EdgeInsets.all(16),

                    leading: RecipeImage(
                      image: recipe.image,
                      width: 64,
                      height: 64,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    title: Text(
                      recipe.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${recipe.cuisine} • ${recipe.prepTimeMinutes + recipe.cookTimeMinutes} min',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openRecipeForm,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Recipe'),
      ),
    );
  }
}
