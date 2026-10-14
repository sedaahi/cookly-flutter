
import 'dart:io';

import 'package:flutter/material.dart';

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
      imageWidget = Image.file(
        File(image),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
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
