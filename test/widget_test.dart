
import 'package:flutter_test/flutter_test.dart';
import 'package:cookly_flutter/models/recipe_model.dart';

void main() {
  group('RecipeModel Tests', () {
    test('Recipe should be created from JSON', () {
      final json = {
        'id': 1,
        'name': 'Homemade Pizza',
        'image': 'pizza.jpg',
        'ingredients': ['Flour', 'Cheese', 'Tomato'],
        'instructions': ['Prepare dough', 'Bake pizza'],
        'prepTimeMinutes': 20,
        'cookTimeMinutes': 30,
        'servings': 4,
        'caloriesPerServing': 350,
        'difficulty': 'Easy',
        'cuisine': 'Italian',
        'rating': 4.5,
        'tags': ['Pizza'],
        'mealType': ['Dinner'],
      };

      final recipe = RecipeModel.fromJson(json);

      expect(recipe.id, 1);
      expect(recipe.name, 'Homemade Pizza');
      expect(recipe.ingredients.length, 3);
      expect(recipe.mealType, contains('Dinner'));
      expect(recipe.rating, 4.5);
    });

    test('Recipe should be converted to JSON', () {
      final recipe = RecipeModel(
        id: 2,
        name: 'Chocolate Cake',
        image: 'cake.jpg',
        ingredients: ['Flour', 'Chocolate'],
        instructions: ['Mix ingredients', 'Bake'],
        prepTimeMinutes: 15,
        cookTimeMinutes: 40,
        servings: 6,
        caloriesPerServing: 420,
        difficulty: 'Easy',
        cuisine: 'American',
        rating: 0.0,
        tags: ['Cake'],
        mealType: ['Dessert'],
      );

      final json = recipe.toJson();

      expect(json['id'], 2);
      expect(json['name'], 'Chocolate Cake');
      expect(json['mealType'], contains('Dessert'));
      expect(json['ingredients'], hasLength(2));
    });
  });
}
