import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageStorageService {
  // Fotoğrafların saklandığı klasörü döndürür.
  Future<Directory> getImagesDirectory() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();

    final imagesDirectory = Directory(
      path.join(documentsDirectory.path, 'recipe_images'),
    );

    if (!await imagesDirectory.exists()) {
      await imagesDirectory.create(recursive: true);
    }

    return imagesDirectory;
  }

  // Fotoğrafı kalıcı olarak kaydeder.
  // Tam dosya yolu yerine yalnızca dosya adını döndürür.
  Future<String> saveImage(XFile image) async {
    final directory = await getImagesDirectory();

    final extension = path.extension(image.path).toLowerCase();

    final fileName =
        'recipe_${DateTime.now().microsecondsSinceEpoch}$extension';

    await File(image.path).copy(path.join(directory.path, fileName));

    return fileName;
  }

  // Kaydedilen dosya adını güncel tam dosya yoluna dönüştürür.
  Future<String> getImagePath(String fileName) async {
    final directory = await getImagesDirectory();

    return path.join(directory.path, fileName);
  }

  Future<void> deleteImage(String imageName) async {
    // İnternetten gelen görselleri silmeye çalışma.
    if (imageName.isEmpty ||
        imageName.startsWith('http://') ||
        imageName.startsWith('https://')) {
      return;
    }

    // Yalnızca uygulamanın oluşturduğu fotoğrafları sil.
    if (imageName != path.basename(imageName) ||
        !RegExp(r'^recipe_\d+\.(jpg|jpeg|png|webp)$').hasMatch(imageName)) {
      return;
    }

    final directory = await getImagesDirectory();

    final imageFile = File(path.join(directory.path, imageName));

    if (await imageFile.exists()) {
      await imageFile.delete();
    }
  }
}
