class OcrRecord {
  final int? id;
  final String imagePath;
  final String originalText;
  final String editedText;
  final DateTime createdAt;
  final DateTime updatedAt;

  OcrRecord({
    this.id,
    required this.imagePath,
    required this.originalText,
    this.editedText = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  OcrRecord copyWith({
    int? id,
    String? imagePath,
    String? originalText,
    String? editedText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OcrRecord(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      originalText: originalText ?? this.originalText,
      editedText: editedText ?? this.editedText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_path': imagePath,
      'original_text': originalText,
      'edited_text': editedText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory OcrRecord.fromMap(Map<String, dynamic> map) {
    return OcrRecord(
      id: map['id'] as int?,
      imagePath: map['image_path'] as String,
      originalText: map['original_text'] as String? ?? '',
      editedText: map['edited_text'] as String? ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  String get displayText => editedText.isNotEmpty ? editedText : originalText;

  @override
  String toString() {
    return 'OcrRecord(id: $id, imagePath: $imagePath, originalText: ${originalText.length} chars, editedText: ${editedText.length} chars)';
  }
}
