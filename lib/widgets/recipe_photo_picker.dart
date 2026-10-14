import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';

class RecipePhotoPicker extends StatefulWidget {
  final ValueChanged<XFile?> onImageSelected;

  const RecipePhotoPicker({super.key, required this.onImageSelected});

  @override
  State<RecipePhotoPicker> createState() => _RecipePhotoPickerState();
}

class _RecipePhotoPickerState extends State<RecipePhotoPicker> {
  final ImagePicker _picker = ImagePicker();

  XFile? selectedImage;

  Future<void> pickImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (image == null) return;

      if (!mounted) return;

      setState(() {
        selectedImage = image;
      });

      widget.onImageSelected(image);
    } catch (e, stackTrace) {
      debugPrint('IMAGE PICKER ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Image selection failed: $e')));
    }
  }

  void removeImage() {
    setState(() {
      selectedImage = null;
    });

    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recipe Photo',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),

        GestureDetector(
          onTap: pickImage,
          child: Container(
            width: double.infinity,
            height: 210,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: selectedImage == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(File(selectedImage!.path), fit: BoxFit.cover),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: IconButton.filled(
                          onPressed: removeImage,
                          icon: const Icon(Icons.close_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.textDark,
                          ),
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
