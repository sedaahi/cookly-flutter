import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/recipe_model.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com';

  Future<List<RecipeModel>> getRecipes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/recipes?limit=0'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final List<dynamic> recipesJson = data['recipes'];

        return recipesJson.map((json) => RecipeModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Tarifler alınamadı. Hata kodu: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('API bağlantı hatası: $e');
    }
  }
}
