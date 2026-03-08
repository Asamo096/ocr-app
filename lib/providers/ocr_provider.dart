import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/ocr_record.dart';
import '../models/ocr_result.dart';
import '../services/ocr_service.dart';
import '../services/database_service.dart';
import '../services/image_service.dart';

enum OcrStatus {
  idle,
  loading,
  success,
  error,
}

class OcrProvider extends ChangeNotifier {
  final OcrService _ocrService = OcrService.instance;
  final DatabaseService _databaseService = DatabaseService.instance;
  final ImageService _imageService = ImageService.instance;

  OcrStatus _status = OcrStatus.idle;
  OcrResult? _currentResult;
  String? _currentImagePath;
  String _editedText = '';
  String? _errorMessage;
  List<OcrRecord> _history = [];
  bool _isLoadingHistory = false;

  OcrStatus get status => _status;
  OcrResult? get currentResult => _currentResult;
  String? get currentImagePath => _currentImagePath;
  String get editedText => _editedText;
  String? get errorMessage => _errorMessage;
  List<OcrRecord> get history => _history;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get hasResult => _currentResult != null && _currentResult!.isNotEmpty;

  void setEditedText(String text) {
    _editedText = text;
    notifyListeners();
  }

  Future<void> processImage(File imageFile) async {
    _status = OcrStatus.loading;
    _currentImagePath = imageFile.path;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _ocrService.recognizeText(imageFile.path);
      _currentResult = result;
      _editedText = result.text;
      _status = OcrStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = OcrStatus.error;
    }

    notifyListeners();
  }

  Future<void> processImageFromCamera() async {
    final imageFile = await _imageService.pickFromCamera();
    if (imageFile != null) {
      await processImage(imageFile);
    }
  }

  Future<void> processImageFromGallery() async {
    final imageFile = await _imageService.pickFromGallery();
    if (imageFile != null) {
      await processImage(imageFile);
    }
  }

  Future<OcrRecord?> saveCurrentResult() async {
    if (_currentImagePath == null || _currentResult == null) {
      return null;
    }

    final record = OcrRecord(
      imagePath: _currentImagePath!,
      originalText: _currentResult!.text,
      editedText: _editedText,
    );

    final id = await _databaseService.insertRecord(record);
    final savedRecord = record.copyWith(id: id);
    
    await loadHistory();
    
    return savedRecord;
  }

  Future<void> loadHistory() async {
    _isLoadingHistory = true;
    notifyListeners();

    try {
      _history = await _databaseService.getAllRecords();
    } catch (e) {
      _history = [];
    }

    _isLoadingHistory = false;
    notifyListeners();
  }

  Future<void> deleteRecord(int id) async {
    try {
      final record = await _databaseService.getRecordById(id);
      if (record != null) {
        await _imageService.deleteImage(record.imagePath);
      }
      await _databaseService.deleteRecord(id);
      await loadHistory();
    } catch (e) {
      debugPrint('Failed to delete record: $e');
    }
  }

  Future<void> updateRecord(OcrRecord record) async {
    await _databaseService.updateRecord(record);
    await loadHistory();
  }

  void clearCurrentResult() {
    _status = OcrStatus.idle;
    _currentResult = null;
    _currentImagePath = null;
    _editedText = '';
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    clearCurrentResult();
    _history = [];
    notifyListeners();
  }
}
