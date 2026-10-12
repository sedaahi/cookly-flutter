
class RecipeModel {
  final int id;
  final String name;
  final String image;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final int caloriesPerServing;
  final String difficulty;
  final String cuisine;
  final double rating;
  final List<String> tags;
  final List<String> mealType;

  RecipeModel({
    required this.id,
    required this.name,
    required this.image,
    required this.ingredients,
    required this.instructions,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.caloriesPerServing,
    required this.difficulty,
    required this.cuisine,
    required this.rating,
    required this.tags,
    required this.mealType,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      image: json['image'] as String,
      ingredients: List<String>.from(json['ingredients'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      prepTimeMinutes: (json['prepTimeMinutes'] as num?)?.toInt() ?? 0,
      cookTimeMinutes: (json['cookTimeMinutes'] as num?)?.toInt() ?? 0,
      servings: (json['servings'] as num?)?.toInt() ?? 1,
      caloriesPerServing:
          (json['caloriesPerServing'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty'] as String? ?? '',
      cuisine: json['cuisine'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      tags: List<String>.from(json['tags'] ?? []),
      mealType: List<String>.from(json['mealType'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'ingredients': ingredients,
      'instructions': instructions,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'servings': servings,
      'caloriesPerServing': caloriesPerServing,
      'difficulty': difficulty,
      'cuisine': cuisine,
      'rating': rating,
      'tags': tags,
      'mealType': mealType,
    };
  }
}
