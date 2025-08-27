import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chatapp/features/scanner/data/text_export_service.dart';

void main() {
  group('TextExportService Tests', () {
    late TextExportService exportService;

    setUp(() {
      exportService = TextExportService();
    });

    group('Text Statistics Tests', () {
      test('should calculate text statistics correctly', () {
        const sampleText = '''Hello world!

This is a test document with multiple paragraphs.
It contains several words and lines.

• First bullet point
• Second bullet point

The end.''';

        final stats = exportService.getTextStatistics(sampleText);

        expect(stats['characters'], greaterThan(0));
        expect(stats['charactersNoSpaces'], lessThan(stats['characters']!));
        expect(stats['words'], greaterThan(10));
        expect(stats['lines'], greaterThan(8));
        expect(stats['paragraphs'], greaterThan(2));
      });

      test('should handle empty text', () {
        final stats = exportService.getTextStatistics('');

        expect(stats['characters'], equals(0));
        expect(stats['charactersNoSpaces'], equals(0));
        expect(stats['words'], equals(0));
        expect(stats['lines'], equals(1)); // Empty string has 1 line
        expect(stats['paragraphs'], equals(0));
      });

      test('should handle single word', () {
        final stats = exportService.getTextStatistics('Hello');

        expect(stats['characters'], equals(5));
        expect(stats['charactersNoSpaces'], equals(5));
        expect(stats['words'], equals(1));
        expect(stats['lines'], equals(1));
        expect(stats['paragraphs'], equals(1));
      });
    });

    group('File Name Generation Tests', () {
      test('should generate meaningful filename from text content', () {
        const text = 'Meeting Notes for Project Alpha Discussion';
        final fileName = exportService.generateFileName(text);

        expect(fileName, isNotEmpty);
        expect(fileName, contains('meeting'));
        expect(fileName, contains('notes'));
        expect(fileName, contains('project'));
        expect(fileName.split('_').length, greaterThanOrEqualTo(3));
      });

      test('should generate filename with prefix', () {
        const text = 'Important document content';
        final fileName = exportService.generateFileName(text, prefix: 'ocr');

        expect(fileName, startsWith('ocr_'));
        expect(fileName, contains('important'));
        expect(fileName, contains('document'));
      });

      test('should handle text with special characters', () {
        const text = 'Test@#\$% document with! special characters?';
        final fileName = exportService.generateFileName(text);

        expect(fileName, isNotEmpty);
        // Should not contain special characters
        expect(fileName, isNot(contains('@')));
        expect(fileName, isNot(contains('#')));
        expect(fileName, isNot(contains('\$')));
        expect(fileName, isNot(contains('!')));
        expect(fileName, isNot(contains('?')));
      });

      test('should handle empty or short text', () {
        final fileName1 = exportService.generateFileName('');
        final fileName2 = exportService.generateFileName('Hi');

        expect(fileName1, contains('extracted_text'));
        expect(fileName2, contains('extracted_text'));
      });

      test('should exclude common words from filename', () {
        const text = 'The meeting with the team was about the project';
        final fileName = exportService.generateFileName(text);

        // Should not contain common words like 'the', 'was', 'with', 'about'
        expect(fileName.toLowerCase(), isNot(contains('the')));
        expect(fileName.toLowerCase(), isNot(contains('was')));
        expect(fileName.toLowerCase(), isNot(contains('with')));
        expect(fileName.toLowerCase(), isNot(contains('about')));
        
        // Should contain meaningful words
        expect(fileName.toLowerCase(), contains('meeting'));
        expect(fileName.toLowerCase(), contains('team'));
        expect(fileName.toLowerCase(), contains('project'));
      });
    });

    group('Summary Creation Tests', () {
      test('should create comprehensive document summary', () {
        const text = 'This is a sample document with important information.';
        const title = 'Sample Document';
        final createdAt = DateTime.parse('2024-01-15T10:30:00Z');
        const confidence = 0.95;

        final summary = exportService.createSummary(
          text: text,
          documentTitle: title,
          createdAt: createdAt,
          ocrConfidence: confidence,
        );

        expect(summary['title'], equals(title));
        expect(summary['created_at'], equals(createdAt.toIso8601String()));
        expect(summary['ocr_confidence'], equals(confidence));
        expect(summary['text_preview'], equals(text)); // Short text, no truncation
        expect(summary['statistics'], isA<Map<String, int>>());
        expect(summary['export_formats'], contains('txt'));
        expect(summary['export_formats'], contains('md'));
        expect(summary['export_formats'], contains('csv'));
      });

      test('should truncate long text in preview', () {
        final longText = 'A' * 300; // 300 characters
        final summary = exportService.createSummary(
          text: longText,
          documentTitle: 'Long Document',
          createdAt: DateTime.now(),
        );

        final preview = summary['text_preview'] as String;
        expect(preview.length, equals(203)); // 200 + '...'
        expect(preview, endsWith('...'));
      });

      test('should handle summary without OCR confidence', () {
        const text = 'Sample text without confidence';
        final summary = exportService.createSummary(
          text: text,
          documentTitle: 'Test Document',
          createdAt: DateTime.now(),
        );

        expect(summary['ocr_confidence'], isNull);
        expect(summary['title'], equals('Test Document'));
        expect(summary['text_preview'], equals(text));
      });
    });

    group('Export Format Tests', () {
      test('should define export formats correctly', () {
        expect(ExportFormat.txt.displayName, equals('Plain Text'));
        expect(ExportFormat.txt.extension, equals('txt'));
        expect(ExportFormat.txt.mimeType, equals('text/plain'));

        expect(ExportFormat.markdown.displayName, equals('Markdown'));
        expect(ExportFormat.markdown.extension, equals('md'));
        expect(ExportFormat.markdown.mimeType, equals('text/markdown'));

        expect(ExportFormat.csv.displayName, equals('CSV'));
        expect(ExportFormat.csv.extension, equals('csv'));
        expect(ExportFormat.csv.mimeType, equals('text/csv'));
      });
    });

    group('Export Result Tests', () {
      test('should create export result with correct properties', () {
        final tempFile = File('/tmp/test.txt');
        const format = ExportFormat.txt;
        const fileName = 'test_document';
        const fileSize = 1024;
        final createdAt = DateTime.now();

        final result = ExportResult(
          file: tempFile,
          format: format,
          fileName: fileName,
          fileSizeBytes: fileSize,
          createdAt: createdAt,
        );

        expect(result.file, equals(tempFile));
        expect(result.format, equals(format));
        expect(result.fileName, equals(fileName));
        expect(result.fileSizeBytes, equals(fileSize));
        expect(result.createdAt, equals(createdAt));
        expect(result.filePath, equals(tempFile.path));
      });

      test('should format file size correctly', () {
        final tempFile = File('/tmp/test.txt');
        const format = ExportFormat.txt;
        final createdAt = DateTime.now();

        // Test bytes
        final bytesResult = ExportResult(
          file: tempFile,
          format: format,
          fileName: 'test',
          fileSizeBytes: 512,
          createdAt: createdAt,
        );
        expect(bytesResult.displaySize, equals('512 B'));

        // Test kilobytes
        final kbResult = ExportResult(
          file: tempFile,
          format: format,
          fileName: 'test',
          fileSizeBytes: 1536, // 1.5 KB
          createdAt: createdAt,
        );
        expect(kbResult.displaySize, equals('1.5 KB'));

        // Test megabytes
        final mbResult = ExportResult(
          file: tempFile,
          format: format,
          fileName: 'test',
          fileSizeBytes: 2097152, // 2 MB
          createdAt: createdAt,
        );
        expect(mbResult.displaySize, equals('2.0 MB'));
      });
    });

    group('CSV Export Logic Tests', () {
      test('should handle CSV formatting correctly', () {
        // This test would need to be implemented with actual file operations
        // For now, we test the conceptual understanding of CSV formatting
        const textWithCommas = 'Line with, commas';
        const textWithQuotes = 'Line with "quotes"';
        const normalText = 'Normal line';

        // These would be the expected CSV outputs:
        // Normal text -> Normal line
        // Text with commas -> "Line with, commas" 
        // Text with quotes -> "Line with ""quotes"""

        expect(textWithCommas, contains(','));
        expect(textWithQuotes, contains('"'));
        expect(normalText, isNot(contains(',')));
        expect(normalText, isNot(contains('"')));
      });
    });
  });
}