import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';
import '../widgets/recipe_form_field.dart';
import '../widgets/recipe_photo_picker.dart';
import '../models/recipe_model.dart';
import '../services/local_storage_service.dart';
import '../services/image_storage_service.dart';

class RecipeFormScreen extends StatefulWidget {
  final RecipeModel? recipe;

  const RecipeFormScreen({super.key, this.recipe});

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
  final ImageStorageService _imageStorageService = ImageStorageService();

  bool isSaving = false;
  XFile? selectedImage;

  bool get isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();

    final recipe = widget.recipe;

    if (recipe != null) {
      nameController.text = recipe.name;
      cuisineController.text = recipe.cuisine;
      prepTimeController.text = recipe.prepTimeMinutes.toString();
      cookTimeController.text = recipe.cookTimeMinutes.toString();
      servingsController.text = recipe.servings.toString();
      ingredientsController.text = recipe.ingredients.join('\n');
      instructionsController.text = recipe.instructions.join('\n');
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

  Future<void> saveRecipe() async {
    if (isSaving || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
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

      // Düzenleme sırasında eski fotoğrafı koruyoruz.
      String imagePath = widget.recipe?.image ?? '';

      // Yeni fotoğraf seçilmişse eskisinin yerine kullanıyoruz.
      if (selectedImage != null) {
        imagePath = await _imageStorageService.saveImage(selectedImage!);
      }

      final recipe = RecipeModel(
        // Düzenleme sırasında mevcut ID korunur.
        id: widget.recipe?.id ?? DateTime.now().microsecondsSinceEpoch,
        name: nameController.text.trim(),
        image: imagePath,
        ingredients: ingredients,
        instructions: instructions,
        prepTimeMinutes: int.parse(prepTimeController.text.trim()),
        cookTimeMinutes: int.parse(cookTimeController.text.trim()),
        servings: int.parse(servingsController.text.trim()),
        caloriesPerServing: widget.recipe?.caloriesPerServing ?? 0,
        difficulty: widget.recipe?.difficulty ?? 'Easy',
        cuisine: cuisineController.text.trim(),
        rating: widget.recipe?.rating ?? 0.0,
        tags: widget.recipe?.tags ?? [],
        mealType: widget.recipe?.mealType ?? [],
      );

      if (isEditing) {
        await _storageService.updateMyRecipe(recipe);
      } else {
        await _storageService.saveMyRecipe(recipe);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Recipe updated successfully!'
                : 'Recipe saved successfully!',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('SAVE RECIPE ERROR: $e');

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
        title: Text(
          isEditing ? 'Edit Recipe' : 'Create Recipe',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              isEditing ? 'Edit your recipe!' : 'Share your creation!',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              isEditing
                  ? 'Update the details of your delicious recipe.'
                  : 'Add the details of your delicious recipe.',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 28),

            RecipePhotoPicker(
              selectedImage: selectedImage,
              initialImage: widget.recipe?.image,
              onImageSelected: (image) {
                setState(() {
                  selectedImage = image;
                });
              },
            ),

            const SizedBox(height: 24),

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
                label: Text(
                  isSaving
                      ? 'Saving...'
                      : isEditing
                      ? 'Update Recipe'
                      : 'Save Recipe',
                ),
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
