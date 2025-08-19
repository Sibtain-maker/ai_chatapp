class DocumentModel {
  final String id;
  final String userId;
  final String title;
  final String filePath;
  final String fileType;
  final int fileSize;
  final DateTime createdAt;

  const DocumentModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.createdAt,
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
  }) {
    return DocumentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}