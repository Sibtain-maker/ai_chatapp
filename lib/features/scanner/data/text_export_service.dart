import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

/// Service for exporting OCR extracted text to various formats
class TextExportService {
  
  /// Export text as plain text file
  Future<File> exportToTxt({
    required String text,
    required String fileName,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.txt');
    await file.writeAsString(text, encoding: utf8);
    return file;
  }

  /// Export text as markdown file
  Future<File> exportToMarkdown({
    required String text,
    required String fileName,
    String? title,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.md');
    
    final markdownContent = StringBuffer();
    if (title != null) {
      markdownContent.writeln('# $title\n');
    }
    markdownContent.write(text);
    
    await file.writeAsString(markdownContent.toString(), encoding: utf8);
    return file;
  }

  /// Export text as CSV (for structured data)
  Future<File> exportToCsv({
    required String text,
    required String fileName,
    String delimiter = ',',
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.csv');
    
    // Convert line-based text to CSV format
    final lines = text.split('\n');
    final csvContent = StringBuffer();
    
    for (final line in lines) {
      if (line.trim().isNotEmpty) {
        // Simple CSV conversion - escape quotes and wrap in quotes if contains delimiter
        final escaped = line.replaceAll('"', '""');
        if (escaped.contains(delimiter) || escaped.contains('"') || escaped.contains('\n')) {
          csvContent.writeln('"$escaped"');
        } else {
          csvContent.writeln(escaped);
        }
      }
    }
    
    await file.writeAsString(csvContent.toString(), encoding: utf8);
    return file;
  }

  /// Copy text to clipboard
  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Get formatted text statistics
  Map<String, int> getTextStatistics(String text) {
    final words = text.trim().split(RegExp(r'\s+'));
    final lines = text.split('\n');
    final paragraphs = text.split('\n\n').where((p) => p.trim().isNotEmpty);
    
    return {
      'characters': text.length,
      'charactersNoSpaces': text.replaceAll(RegExp(r'\s'), '').length,
      'words': words.where((w) => w.isNotEmpty).length,
      'lines': lines.length,
      'paragraphs': paragraphs.length,
    };
  }

  /// Create a shareable summary of the document
  Map<String, dynamic> createSummary({
    required String text,
    required String documentTitle,
    required DateTime createdAt,
    double? ocrConfidence,
  }) {
    final stats = getTextStatistics(text);
    
    return {
      'title': documentTitle,
      'created_at': createdAt.toIso8601String(),
      'ocr_confidence': ocrConfidence,
      'text_preview': text.length > 200 ? '${text.substring(0, 200)}...' : text,
      'statistics': stats,
      'export_formats': ['txt', 'md', 'csv'],
    };
  }

  /// Generate suggested filename based on text content
  String generateFileName(String text, {String? prefix}) {
    // Extract first meaningful words for filename
    final words = text.trim().split(RegExp(r'\s+'));
    final meaningfulWords = words
        .where((word) => word.length > 2 && !_isCommonWord(word))
        .take(3)
        .map((word) => word.toLowerCase().replaceAll(RegExp(r'[^\w]'), ''));
    
    final baseName = meaningfulWords.isEmpty 
        ? 'extracted_text'
        : meaningfulWords.join('_');
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return prefix != null ? '${prefix}_${baseName}_$timestamp' : '${baseName}_$timestamp';
  }

  /// Check if word is common and should be excluded from filename
  bool _isCommonWord(String word) {
    const commonWords = {
      'the', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with',
      'by', 'from', 'up', 'about', 'into', 'through', 'during', 'before',
      'after', 'above', 'below', 'between', 'among', 'this', 'that', 'these',
      'those', 'is', 'are', 'was', 'were', 'be', 'been', 'being', 'have',
      'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could', 'should',
    };
    
    return commonWords.contains(word.toLowerCase());
  }

  /// Cleanup temporary export files
  Future<void> cleanupExports() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync()
          .whereType<File>()
          .where((file) => file.path.contains('extracted_text') || 
                         file.path.contains('_export_'));
      
      for (final file in files) {
        // Only cleanup files older than 24 hours
        final stat = await file.stat();
        final age = DateTime.now().difference(stat.modified);
        if (age.inHours > 24) {
          await file.delete();
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }
}

/// Export format enumeration
enum ExportFormat {
  txt('Plain Text', 'txt', 'text/plain'),
  markdown('Markdown', 'md', 'text/markdown'),
  csv('CSV', 'csv', 'text/csv');
  
  const ExportFormat(this.displayName, this.extension, this.mimeType);
  
  final String displayName;
  final String extension;
  final String mimeType;
}

/// Export result class
class ExportResult {
  final File file;
  final ExportFormat format;
  final String fileName;
  final int fileSizeBytes;
  final DateTime createdAt;
  
  const ExportResult({
    required this.file,
    required this.format,
    required this.fileName,
    required this.fileSizeBytes,
    required this.createdAt,
  });
  
  String get filePath => file.path;
  
  String get displaySize {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}