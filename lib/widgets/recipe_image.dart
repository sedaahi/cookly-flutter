
import 'dart:io';

import 'package:flutter/material.dart';

import '../services/image_storage_service.dart';

class RecipeImage extends StatelessWidget {
  final String image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const RecipeImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (image.isEmpty) {
      imageWidget = _buildPlaceholder();
    } else if (image.startsWith('http://') ||
        image.startsWith('https://')) {
      // DummyJSON tariflerinin internet fotoğrafları.
      imageWidget = Image.network(
        image,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else {
      // Kullanıcının cihazda kaydettiği fotoğraflar.
      imageWidget = FutureBuilder<String>(
        future: ImageStorageService().getImagePath(image),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _buildPlaceholder();
          }

          return Image.file(
            File(snapshot.data!),
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('RECIPE IMAGE ERROR: $error');
              return _buildPlaceholder();
            },
          );
        },
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: imageWidget,
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFFFF0E6),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu_rounded,
          size: 48,
          color: Color(0xFFE76F51),
        ),
      ),
    );
  }
}
