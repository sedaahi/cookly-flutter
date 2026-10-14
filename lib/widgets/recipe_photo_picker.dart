
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';
import 'recipe_image.dart';

class RecipePhotoPicker extends StatelessWidget {
  final XFile? selectedImage;
  final String? initialImage;
  final ValueChanged<XFile?> onImageSelected;

  const RecipePhotoPicker({
    super.key,
    required this.selectedImage,
    required this.onImageSelected,
    this.initialImage,
  });

  Future<void> pickImage(BuildContext context) async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (image == null || !context.mounted) return;

      onImageSelected(image);
    } catch (e) {
      debugPrint('IMAGE PICKER ERROR: $e');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not select image. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSelectedImage = selectedImage != null;
    final hasInitialImage =
        initialImage != null && initialImage!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recipe Photo',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),

        GestureDetector(
          onTap: () => pickImage(context),
          child: Container(
            width: double.infinity,
            height: 210,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: hasSelectedImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(selectedImage!.path),
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: IconButton.filled(
                          onPressed: () {
                            onImageSelected(null);
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.textDark,
                          ),
                        ),
                      ),
                    ],
                  )
                : hasInitialImage
                    ? RecipeImage(
                        image: initialImage!,
                        fit: BoxFit.cover,
                      )
                    : const Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: AppTheme.primary,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Add Recipe Photo',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Tap to choose from gallery',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }
}
