class DocumentModel {
  final String id;
  final String userId;
  final String title;
  final String filePath;
  final String fileType;
  final int fileSize;
  final DateTime createdAt;
  final bool isEnhanced;
  final Map<String, dynamic>? enhancementMetadata;
  final String? originalFilePath;
  final String? extractedText;
  final bool hasOcrText;
  final double? ocrConfidence;
  final Map<String, dynamic>? ocrMetadata;

  const DocumentModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.createdAt,
    this.isEnhanced = false,
    this.enhancementMetadata,
    this.originalFilePath,
    this.extractedText,
    this.hasOcrText = false,
    this.ocrConfidence,
    this.ocrMetadata,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      filePath: json['file_path'] as String,
      fileType: json['file_type'] as String,
      fileSize: json['file_size'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      isEnhanced: json['is_enhanced'] as bool? ?? false,
      enhancementMetadata: json['enhancement_metadata'] as Map<String, dynamic>?,
      originalFilePath: json['original_file_path'] as String?,
      extractedText: json['extracted_text'] as String?,
      hasOcrText: json['has_ocr_text'] as bool? ?? false,
      ocrConfidence: (json['ocr_confidence'] as num?)?.toDouble(),
      ocrMetadata: json['ocr_metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'file_path': filePath,
      'file_type': fileType,
      'file_size': fileSize,
      'created_at': createdAt.toIso8601String(),
      'is_enhanced': isEnhanced,
      'enhancement_metadata': enhancementMetadata,
      'original_file_path': originalFilePath,
      'extracted_text': extractedText,
      'has_ocr_text': hasOcrText,
      'ocr_confidence': ocrConfidence,
      'ocr_metadata': ocrMetadata,
    };
  }

  DocumentModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? filePath,
    String? fileType,
    int? fileSize,
    DateTime? createdAt,
    bool? isEnhanced,
    Map<String, dynamic>? enhancementMetadata,
    String? originalFilePath,
    String? extractedText,
    bool? hasOcrText,
    double? ocrConfidence,
    Map<String, dynamic>? ocrMetadata,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      isEnhanced: isEnhanced ?? this.isEnhanced,
      enhancementMetadata: enhancementMetadata ?? this.enhancementMetadata,
      originalFilePath: originalFilePath ?? this.originalFilePath,
      extractedText: extractedText ?? this.extractedText,
      hasOcrText: hasOcrText ?? this.hasOcrText,
      ocrConfidence: ocrConfidence ?? this.ocrConfidence,
      ocrMetadata: ocrMetadata ?? this.ocrMetadata,
    );
  }
}