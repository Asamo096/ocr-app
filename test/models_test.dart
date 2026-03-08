import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_app/models/ocr_record.dart';
import 'package:ocr_app/models/ocr_result.dart';

void main() {
  group('OcrRecord', () {
    test('should create record with required fields', () {
      final record = OcrRecord(
        imagePath: '/path/to/image.jpg',
        originalText: '测试文本',
      );

      expect(record.imagePath, '/path/to/image.jpg');
      expect(record.originalText, '测试文本');
      expect(record.editedText, '');
      expect(record.id, isNull);
    });

    test('should create record with all fields', () {
      final now = DateTime.now();
      final record = OcrRecord(
        id: 1,
        imagePath: '/path/to/image.jpg',
        originalText: '原始文本',
        editedText: '编辑文本',
        createdAt: now,
        updatedAt: now,
      );

      expect(record.id, 1);
      expect(record.imagePath, '/path/to/image.jpg');
      expect(record.originalText, '原始文本');
      expect(record.editedText, '编辑文本');
      expect(record.createdAt, now);
      expect(record.updatedAt, now);
    });

    test('should return displayText correctly', () {
      final recordWithEdited = OcrRecord(
        imagePath: '/path',
        originalText: '原始',
        editedText: '编辑',
      );
      expect(recordWithEdited.displayText, '编辑');

      final recordWithoutEdited = OcrRecord(
        imagePath: '/path',
        originalText: '原始',
      );
      expect(recordWithoutEdited.displayText, '原始');
    });

    test('should convert to and from map', () {
      final record = OcrRecord(
        id: 1,
        imagePath: '/path/to/image.jpg',
        originalText: '测试',
        editedText: '编辑',
      );

      final map = record.toMap();
      final fromMap = OcrRecord.fromMap(map);

      expect(fromMap.id, record.id);
      expect(fromMap.imagePath, record.imagePath);
      expect(fromMap.originalText, record.originalText);
      expect(fromMap.editedText, record.editedText);
    });

    test('should copy with new values', () {
      final record = OcrRecord(
        id: 1,
        imagePath: '/path',
        originalText: '原始',
      );

      final copied = record.copyWith(editedText: '新编辑');

      expect(copied.id, 1);
      expect(copied.imagePath, '/path');
      expect(copied.originalText, '原始');
      expect(copied.editedText, '新编辑');
    });
  });

  group('OcrResult', () {
    test('should create empty result', () {
      final result = OcrResult.empty();

      expect(result.text, '');
      expect(result.isEmpty, true);
      expect(result.isNotEmpty, false);
    });

    test('should create result with text', () {
      final result = OcrResult(
        text: '识别文本',
        confidence: 0.95,
      );

      expect(result.text, '识别文本');
      expect(result.confidence, 0.95);
      expect(result.isEmpty, false);
      expect(result.isNotEmpty, true);
    });

    test('should convert to and from map', () {
      final result = OcrResult(
        text: '测试',
        confidence: 0.9,
        processingTime: const Duration(milliseconds: 500),
      );

      final map = result.toMap();
      final fromMap = OcrResult.fromMap(map);

      expect(fromMap.text, result.text);
      expect(fromMap.confidence, result.confidence);
      expect(fromMap.processingTime, result.processingTime);
    });
  });
}
