
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageStorageService {
  Future<String> saveImage(XFile image) async {
    final directory = await getApplicationDocumentsDirectory();

    final imagesDirectory = Directory(
      path.join(directory.path, 'recipe_images'),
    );

    if (!await imagesDirectory.exists()) {
      await imagesDirectory.create(recursive: true);
    }

    final extension = path.extension(image.path).toLowerCase();
    final fileName =
        'recipe_${DateTime.now().microsecondsSinceEpoch}$extension';

    final savedImage = await File(image.path).copy(
      path.join(imagesDirectory.path, fileName),
    );

    return savedImage.path;
  }
}
