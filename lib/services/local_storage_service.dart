import 'package:shared_preferences/shared_preferences.dart';

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
}
