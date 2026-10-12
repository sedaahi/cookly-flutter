
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class RecipeInfoItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const RecipeInfoItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primary,
          size: 24,
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
