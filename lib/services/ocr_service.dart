import 'dart:io';
import 'package:flutter/services.dart';
import '../models/ocr_result.dart';

class OcrService {
  static final OcrService instance = OcrService._internal();
  
  static const MethodChannel _channel = MethodChannel('com.ocr.app/rapidocr');
  
  bool _isInitialized = false;
  int _recognitionCount = 0;
  static const int _maxRecognitionsBeforeReset = 10;

  OcrService._internal();

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      final result = await _channel.invokeMethod<bool>('initialize');
      _isInitialized = result ?? false;
      _recognitionCount = 0;
      return _isInitialized;
    } on PlatformException catch (e) {
      print('Failed to initialize OCR: ${e.message}');
      return false;
    }
  }

  Future<OcrResult> recognizeText(String imagePath) async {
    // 每识别10次重置一次引擎，防止内存泄漏
    if (_recognitionCount >= _maxRecognitionsBeforeReset) {
      await release();
      await initialize();
    }

    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        return OcrResult.empty();
      }
    }

    final stopwatch = Stopwatch()..start();

    try {
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        return OcrResult.empty();
      }

      final dynamic rawResult = await _channel.invokeMethod(
        'recognizeText',
        {'imagePath': imagePath},
      );

      stopwatch.stop();
      _recognitionCount++;

      if (rawResult == null) {
        return OcrResult.empty();
      }

      final Map<String, dynamic> result = _convertToStringDynamicMap(rawResult);
      return _parseResult(result, stopwatch.elapsed);
    } on PlatformException catch (e) {
      stopwatch.stop();
      print('OCR recognition failed: ${e.message}');
      // 发生错误时重置引擎
      _isInitialized = false;
      return OcrResult(
        text: '',
        processingTime: stopwatch.elapsed,
      );
    }
  }

  Future<OcrResult> recognizeTextFromBytes(Uint8List imageBytes) async {
    // 每识别10次重置一次引擎，防止内存泄漏
    if (_recognitionCount >= _maxRecognitionsBeforeReset) {
      await release();
      await initialize();
    }

    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        return OcrResult.empty();
      }
    }

    final stopwatch = Stopwatch()..start();

    try {
      final dynamic rawResult = await _channel.invokeMethod(
        'recognizeTextFromBytes',
        {'imageBytes': imageBytes},
      );

      stopwatch.stop();
      _recognitionCount++;

      if (rawResult == null) {
        return OcrResult.empty();
      }

      final Map<String, dynamic> result = _convertToStringDynamicMap(rawResult);
      return _parseResult(result, stopwatch.elapsed);
    } on PlatformException catch (e) {
      stopwatch.stop();
      print('OCR recognition failed: ${e.message}');
      // 发生错误时重置引擎
      _isInitialized = false;
      return OcrResult(
        text: '',
        processingTime: stopwatch.elapsed,
      );
    }
  }

  Map<String, dynamic> _convertToStringDynamicMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return {};
  }

  OcrResult _parseResult(Map<String, dynamic> result, Duration processingTime) {
    final String text = result['text'] as String? ?? '';
    final double confidence = (result['confidence'] as num?)?.toDouble() ?? 0.0;
    
    final List<dynamic>? blocksData = result['blocks'] as List<dynamic>?;
    final List<TextBlock> blocks = [];
    
    if (blocksData != null) {
      for (final blockData in blocksData) {
        if (blockData is Map) {
          final blockMap = blockData.map((key, value) => MapEntry(key.toString(), value));
          blocks.add(TextBlock.fromMap(blockMap));
        }
      }
    }

    return OcrResult(
      text: text,
      confidence: confidence,
      blocks: blocks,
      processingTime: processingTime,
    );
  }

  Future<void> release() async {
    if (!_isInitialized) return;
    
    try {
      await _channel.invokeMethod('release');
      _isInitialized = false;
      _recognitionCount = 0;
    } on PlatformException catch (e) {
      print('Failed to release OCR: ${e.message}');
    }
  }

  bool get isInitialized => _isInitialized;
  int get recognitionCount => _recognitionCount;
}
