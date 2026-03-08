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
    // 删除临时文件
    try {
      await File(image.path).delete();
    } catch (e) {
      debugPrint('Failed to delete temp file: $e');
    }
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

  /// 清理旧的图片文件，只保留最近 N 张
  Future<void> cleanupOldImages({int keepCount = 50}) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory imageDir = Directory('${appDir.path}/ocr_images');
      
      if (!await imageDir.exists()) return;
      
      final files = await imageDir
          .list()
          .where((entity) => entity is File)
          .map((entity) => entity as File)
          .toList();
      
      if (files.length <= keepCount) return;
      
      // 按修改时间排序，删除最旧的
      files.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));
      
      final toDelete = files.length - keepCount;
      for (var i = 0; i < toDelete; i++) {
        await files[i].delete();
      }
      
      debugPrint('Cleaned up $toDelete old images');
    } catch (e) {
      debugPrint('Failed to cleanup images: $e');
    }
  }
}
