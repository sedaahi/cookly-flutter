import 'dart:convert';

import 'package:cookly_flutter/models/recipe_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'image_storage_service.dart';

class LocalStorageService {
  static const String _favoritesKey = 'favorite_recipes';

  //Kaydedilmiş favori tarif ID'lerini getir
  Future<List<int>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final savedIds = prefs.getStringList(_favoritesKey) ?? [];

    return savedIds.map((id) => int.tryParse(id)).whereType<int>().toList();
  }

  //Favori listesini cihazda sakla
  Future<void> saveFavorites(List<int> recipeIds) async {
    final prefs = await SharedPreferences.getInstance();

    final ids = recipeIds.map((id) => id.toString()).toList();

    await prefs.setStringList(_favoritesKey, ids);
  }

  //Tarifin favorilerde olup olmadığının kontrolü
  Future<bool> isFavorite(int recipeId) async {
    final favorites = await getFavorites();

    return favorites.contains(recipeId);
  }

  //Favorideyse çıkarır, değilse ekle
  Future<bool> toggleFavorite(int recipeId) async {
    final favorites = await getFavorites();

    if (favorites.contains(recipeId)) {
      favorites.remove(recipeId);
    } else {
      favorites.add(recipeId);
    }

    await saveFavorites(favorites);

    return favorites.contains(recipeId);
  }

  Future<List<RecipeModel>> getMyRecipes() async {
    final prefs = await SharedPreferences.getInstance();

    final savedRecipes = prefs.getStringList('my_recipes') ?? [];

    return savedRecipes
        .map((recipe) => RecipeModel.fromJson(jsonDecode(recipe)))
        .toList();
  }

  Future<void> saveMyRecipe(RecipeModel recipe) async {
    final prefs = await SharedPreferences.getInstance();

    final savedRecipes = prefs.getStringList('my_recipes') ?? [];

    savedRecipes.add(jsonEncode(recipe.toJson()));

    await prefs.setStringList('my_recipes', savedRecipes);
  }

  Future<void> updateMyRecipe(RecipeModel updatedRecipe) async {
    final prefs = await SharedPreferences.getInstance();

    final recipes = await getMyRecipes();

    final index = recipes.indexWhere((recipe) => recipe.id == updatedRecipe.id);

    if (index == -1) {
      throw Exception('Recipe not found');
    }

    recipes[index] = updatedRecipe;

    final encodedRecipes = recipes
        .map((recipe) => jsonEncode(recipe.toJson()))
        .toList();

    final success = await prefs.setStringList('my_recipes', encodedRecipes);

    if (!success) {
      throw Exception('Could not update recipe');
    }
  }

  Future<void> deleteMyRecipe(int recipeId) async {
    final prefs = await SharedPreferences.getInstance();

    final recipes = await getMyRecipes();

    final recipeIndex = recipes.indexWhere((recipe) => recipe.id == recipeId);

    if (recipeIndex == -1) {
      throw Exception('Recipe not found');
    }

    // Silinecek tarifin fotoğraf bilgisini sakla.
    final imageName = recipes[recipeIndex].image;

    // Tarifi listeden kaldır.
    recipes.removeAt(recipeIndex);

    final encodedRecipes = recipes
        .map((recipe) => jsonEncode(recipe.toJson()))
        .toList();

    final success = await prefs.setStringList('my_recipes', encodedRecipes);

    if (!success) {
      throw Exception('Could not delete recipe');
    }

    // Tarif başarıyla silindikten sonra fotoğrafı temizle.
    try {
      final imageStorageService = ImageStorageService();

      await imageStorageService.deleteImage(imageName);
    } catch (e) {
      // Fotoğraf temizlenemese de tarif silinmiş durumda.
      debugPrint('IMAGE CLEANUP ERROR: $e');
    }
  }
}
