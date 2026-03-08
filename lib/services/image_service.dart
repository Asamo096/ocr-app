import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  static final ImageService instance = ImageService._internal();
  final ImagePicker _picker = ImagePicker();

  ImageService._internal();

  Future<File?> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    
    if (image == null) return null;
    
    final File savedFile = await _saveImageToAppDir(File(image.path));
    return savedFile;
  }

  Future<File?> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    
    if (image == null) return null;
    
    final File savedFile = await _saveImageToAppDir(File(image.path));
    return savedFile;
  }

  Future<File> _saveImageToAppDir(File sourceFile) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory imageDir = Directory('${appDir.path}/ocr_images');
    
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    
    final String fileName = 'ocr_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String newPath = '${imageDir.path}/$fileName';
    
    final File newFile = await sourceFile.copy(newPath);
    return newFile;
  }

  Future<bool> deleteImage(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Failed to delete image: $e');
      return false;
    }
  }

  Future<int> clearAllImages() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory imageDir = Directory('${appDir.path}/ocr_images');
      
      if (await imageDir.exists()) {
        int count = 0;
        await for (final entity in imageDir.list()) {
          if (entity is File) {
            await entity.delete();
            count++;
          }
        }
        return count;
      }
      return 0;
    } catch (e) {
      debugPrint('Failed to clear images: $e');
      return 0;
    }
  }

  Future<File?> compressImage(File sourceFile, {int quality = 70}) async {
    return sourceFile;
  }
}
