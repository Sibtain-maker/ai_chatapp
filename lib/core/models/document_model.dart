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
    );
  }
}