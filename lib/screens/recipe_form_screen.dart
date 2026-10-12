import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/recipe_form_field.dart';
import '../models/recipe_model.dart';
import '../services/local_storage_service.dart';

class RecipeFormScreen extends StatefulWidget {
  const RecipeFormScreen({super.key});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final cuisineController = TextEditingController();
  final prepTimeController = TextEditingController();
  final cookTimeController = TextEditingController();
  final servingsController = TextEditingController();
  final ingredientsController = TextEditingController();
  final instructionsController = TextEditingController();
  final LocalStorageService _storageService = LocalStorageService();
  bool isSaving = false;

  Future<void> saveRecipe() async {
    if (!_formKey.currentState!.validate() || isSaving) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    final ingredients = ingredientsController.text
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    final instructions = instructionsController.text
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    final recipe = RecipeModel(
      id: DateTime.now().microsecondsSinceEpoch,
      name: nameController.text.trim(),
      image: '',
      ingredients: ingredients,
      instructions: instructions,
      prepTimeMinutes: int.parse(prepTimeController.text.trim()),
      cookTimeMinutes: int.parse(cookTimeController.text.trim()),
      servings: int.parse(servingsController.text.trim()),
      caloriesPerServing: 0,
      difficulty: 'Easy',
      cuisine: cuisineController.text.trim(),
      rating: 0.0,
      tags: [],
      mealType: [],
    );

    try {
      await _storageService.saveMyRecipe(recipe);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe saved successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save recipe. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? positiveNumberValidator(String? value) {
    final number = int.tryParse(value?.trim() ?? '');

    if (number == null || number <= 0) {
      return 'Enter a number greater than 0';
    }

    return null;
  }

  @override
  void dispose() {
    nameController.dispose();
    cuisineController.dispose();
    prepTimeController.dispose();
    cookTimeController.dispose();
    servingsController.dispose();
    ingredientsController.dispose();
    instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Recipe',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Share your creation!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add the details of your delicious recipe.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 28),

            RecipeFormField(
              label: 'Recipe Name',
              hint: 'e.g. Homemade Pizza',
              controller: nameController,
              validator: requiredValidator,
            ),
            const SizedBox(height: 20),

            RecipeFormField(
              label: 'Cuisine',
              hint: 'e.g. Italian',
              controller: cuisineController,
              validator: requiredValidator,
            ),
            const SizedBox(height: 20),

            RecipeFormField(
              label: 'Preparation Time (min)',
              hint: 'e.g. 15',
              controller: prepTimeController,
              keyboardType: TextInputType.number,
              validator: positiveNumberValidator,
            ),
            const SizedBox(height: 20),

            RecipeFormField(
              label: 'Cooking Time (min)',
              hint: 'e.g. 30',
              controller: cookTimeController,
              keyboardType: TextInputType.number,
              validator: positiveNumberValidator,
            ),
            const SizedBox(height: 20),

            RecipeFormField(
              label: 'Servings',
              hint: 'e.g. 4',
              controller: servingsController,
              keyboardType: TextInputType.number,
              validator: positiveNumberValidator,
            ),
            const SizedBox(height: 20),

            RecipeFormField(
              label: 'Ingredients',
              hint: 'Enter one ingredient per line',
              controller: ingredientsController,
              maxLines: 5,
              validator: requiredValidator,
            ),
            const SizedBox(height: 20),

            RecipeFormField(
              label: 'Instructions',
              hint: 'Enter one step per line',
              controller: instructionsController,
              maxLines: 6,
              validator: requiredValidator,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : saveRecipe,
                icon: const Icon(Icons.check_rounded),
                label: Text(isSaving ? 'Saving...' : 'Save Recipe'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
