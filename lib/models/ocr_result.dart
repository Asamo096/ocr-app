import 'dart:ui';

class OcrResult {
  final String text;
  final double confidence;
  final List<TextBlock> blocks;
  final Duration processingTime;

  OcrResult({
    required this.text,
    this.confidence = 0.0,
    this.blocks = const [],
    this.processingTime = Duration.zero,
  });

  factory OcrResult.empty() {
    return OcrResult(text: '');
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'confidence': confidence,
      'blocks': blocks.map((b) => b.toMap()).toList(),
      'processingTimeMs': processingTime.inMilliseconds,
    };
  }

  factory OcrResult.fromMap(Map<String, dynamic> map) {
    return OcrResult(
      text: map['text'] ?? '',
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      blocks: (map['blocks'] as List?)
          ?.map((b) => TextBlock.fromMap(_castToStringDynamicMap(b)))
          .toList() ?? [],
      processingTime: Duration(milliseconds: map['processingTimeMs'] ?? 0),
    );
  }

  bool get isEmpty => text.isEmpty;
  bool get isNotEmpty => text.isNotEmpty;

  static Map<String, dynamic> _castToStringDynamicMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return {};
  }
}

class TextBlock {
  final String text;
  final double confidence;
  final Rect boundingBox;
  final List<Point> polygon;

  const TextBlock({
    required this.text,
    this.confidence = 0.0,
    required this.boundingBox,
    this.polygon = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'confidence': confidence,
      'boundingBox': {
        'left': boundingBox.left,
        'top': boundingBox.top,
        'right': boundingBox.right,
        'bottom': boundingBox.bottom,
      },
      'polygon': polygon.map((p) => {'x': p.x, 'y': p.y}).toList(),
    };
  }

  factory TextBlock.fromMap(Map<String, dynamic> map) {
    final bbox = _castToStringDynamicMap(map['boundingBox']);
    return TextBlock(
      text: map['text']?.toString() ?? '',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      boundingBox: bbox.isNotEmpty
          ? Rect.fromLTRB(
              (bbox['left'] as num?)?.toDouble() ?? 0.0,
              (bbox['top'] as num?)?.toDouble() ?? 0.0,
              (bbox['right'] as num?)?.toDouble() ?? 0.0,
              (bbox['bottom'] as num?)?.toDouble() ?? 0.0,
            )
          : Rect.zero,
      polygon: _parsePolygon(map['polygon']),
    );
  }

  static Map<String, dynamic> _castToStringDynamicMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return {};
  }

  static List<Point> _parsePolygon(dynamic raw) {
    if (raw is! List) return [];
    return raw.map((p) {
      final pointMap = _castToStringDynamicMap(p);
      return Point(
        (pointMap['x'] as num?)?.toDouble() ?? 0.0,
        (pointMap['y'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }
}

class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);
}
