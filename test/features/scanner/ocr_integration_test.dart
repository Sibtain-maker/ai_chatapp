import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chatapp/features/scanner/data/ocr_service.dart';
import 'package:ai_chatapp/core/models/document_model.dart';

void main() {
  group('OCR Integration Tests', () {
    
    group('OcrResult Tests', () {
      test('should create OcrResult with all required fields', () {
        final result = OcrResult(
          extractedText: 'Sample extracted text',
          processingTimeMs: 2500,
          confidence: 0.92,
          textBlocks: 3,
          detectedLanguage: 'en',
          formattingMetadata: {
            'bullet_points': 1,
            'paragraphs': 2,
            'total_blocks': 3,
          },
        );

        expect(result.extractedText, equals('Sample extracted text'));
        expect(result.processingTimeMs, equals(2500));
        expect(result.confidence, equals(0.92));
        expect(result.textBlocks, equals(3));
        expect(result.detectedLanguage, equals('en'));
        expect(result.formattingMetadata['bullet_points'], equals(1));
      });

      test('should meet accuracy requirements correctly', () {
        final highAccuracyResult = OcrResult(
          extractedText: 'Test text',
          processingTimeMs: 2000,
          confidence: 0.95, // 95%
          textBlocks: 5,
          detectedLanguage: 'en',
          formattingMetadata: {},
        );
        
        expect(highAccuracyResult.meetsAccuracyRequirement, isTrue);
        
        final lowAccuracyResult = OcrResult(
          extractedText: 'Test text',
          processingTimeMs: 2000,
          confidence: 0.85, // 85%
          textBlocks: 5,
          detectedLanguage: 'en',
          formattingMetadata: {},
        );
        
        expect(lowAccuracyResult.meetsAccuracyRequirement, isFalse);
      });

      test('should meet time requirements correctly', () {
        final fastResult = OcrResult(
          extractedText: 'Test text',
          processingTimeMs: 3000, // 3 seconds
          confidence: 0.95,
          textBlocks: 5,
          detectedLanguage: 'en',
          formattingMetadata: {},
        );
        
        expect(fastResult.meetsTimeRequirement, isTrue);
        
        final slowResult = OcrResult(
          extractedText: 'Test text',
          processingTimeMs: 6000, // 6 seconds
          confidence: 0.95,
          textBlocks: 5,
          detectedLanguage: 'en',
          formattingMetadata: {},
        );
        
        expect(slowResult.meetsTimeRequirement, isFalse);
      });

      test('should serialize and deserialize correctly', () {
        final original = OcrResult(
          extractedText: 'Sample text with formatting',
          processingTimeMs: 2500,
          confidence: 0.94,
          textBlocks: 3,
          detectedLanguage: 'en',
          formattingMetadata: {
            'bullet_points': 2,
            'paragraphs': 1,
            'total_blocks': 3,
            'processing_algorithm': 'google_mlkit_v1',
          },
        );
        
        final json = original.toJson();
        final deserialized = OcrResult.fromJson(json);
        
        expect(deserialized.extractedText, equals(original.extractedText));
        expect(deserialized.processingTimeMs, equals(original.processingTimeMs));
        expect(deserialized.confidence, equals(original.confidence));
        expect(deserialized.textBlocks, equals(original.textBlocks));
        expect(deserialized.detectedLanguage, equals(original.detectedLanguage));
        expect(deserialized.formattingMetadata['bullet_points'], equals(2));
      });
    });

    group('DocumentModel OCR Integration Tests', () {
      test('should create DocumentModel with OCR fields', () {
        final document = DocumentModel(
          id: 'doc_123',
          userId: 'user_456',
          title: 'Test Document',
          filePath: '/path/to/document.jpg',
          fileType: 'JPG',
          fileSize: 1024,
          createdAt: DateTime.now(),
          isEnhanced: true,
          extractedText: 'This is extracted text from OCR',
          hasOcrText: true,
          ocrConfidence: 0.92,
          ocrMetadata: {
            'processing_time_ms': 2500,
            'text_blocks': 3,
            'detected_language': 'en',
          },
        );

        expect(document.extractedText, equals('This is extracted text from OCR'));
        expect(document.hasOcrText, isTrue);
        expect(document.ocrConfidence, equals(0.92));
        expect(document.ocrMetadata!['processing_time_ms'], equals(2500));
      });

      test('should serialize DocumentModel with OCR data correctly', () {
        final original = DocumentModel(
          id: 'doc_123',
          userId: 'user_456',
          title: 'Test Document',
          filePath: '/path/to/document.jpg',
          fileType: 'JPG',
          fileSize: 1024,
          createdAt: DateTime.parse('2024-01-01T12:00:00Z'),
          extractedText: 'Sample OCR text',
          hasOcrText: true,
          ocrConfidence: 0.95,
          ocrMetadata: {
            'processing_algorithm': 'google_mlkit_v1',
            'confidence': 0.95,
          },
        );

        final json = original.toJson();
        final deserialized = DocumentModel.fromJson(json);

        expect(deserialized.extractedText, equals(original.extractedText));
        expect(deserialized.hasOcrText, equals(original.hasOcrText));
        expect(deserialized.ocrConfidence, equals(original.ocrConfidence));
        expect(deserialized.ocrMetadata, equals(original.ocrMetadata));
      });

      test('should handle document without OCR data', () {
        final document = DocumentModel(
          id: 'doc_123',
          userId: 'user_456',
          title: 'Test Document',
          filePath: '/path/to/document.jpg',
          fileType: 'JPG',
          fileSize: 1024,
          createdAt: DateTime.now(),
        );

        expect(document.extractedText, isNull);
        expect(document.hasOcrText, isFalse);
        expect(document.ocrConfidence, isNull);
        expect(document.ocrMetadata, isNull);
      });

      test('should copyWith OCR data correctly', () {
        final original = DocumentModel(
          id: 'doc_123',
          userId: 'user_456',
          title: 'Test Document',
          filePath: '/path/to/document.jpg',
          fileType: 'JPG',
          fileSize: 1024,
          createdAt: DateTime.now(),
        );

        final withOcr = original.copyWith(
          extractedText: 'New OCR text',
          hasOcrText: true,
          ocrConfidence: 0.88,
          ocrMetadata: {'algorithm': 'test_v1'},
        );

        expect(withOcr.extractedText, equals('New OCR text'));
        expect(withOcr.hasOcrText, isTrue);
        expect(withOcr.ocrConfidence, equals(0.88));
        expect(withOcr.ocrMetadata!['algorithm'], equals('test_v1'));
        
        // Original fields should remain unchanged
        expect(withOcr.id, equals(original.id));
        expect(withOcr.title, equals(original.title));
      });
    });

    group('Performance and Accuracy Validation Tests', () {
      test('should validate OCR performance requirements', () {
        // Test case: High quality OCR result that meets all requirements
        final perfectResult = OcrResult(
          extractedText: 'The quick brown fox jumps over the lazy dog. This text should be extracted with high accuracy.',
          processingTimeMs: 2800, // Less than 5 seconds
          confidence: 0.96, // Greater than 90%
          textBlocks: 2,
          detectedLanguage: 'en',
          formattingMetadata: {
            'bullet_points': 0,
            'paragraphs': 1,
            'total_blocks': 2,
          },
        );

        expect(perfectResult.meetsAccuracyRequirement, isTrue, 
               reason: 'Should meet 90% accuracy requirement');
        expect(perfectResult.meetsTimeRequirement, isTrue, 
               reason: 'Should meet 5-second processing requirement');
        expect(perfectResult.confidence, greaterThan(0.9),
               reason: 'Confidence should be greater than 90%');
        expect(perfectResult.processingTimeMs, lessThan(5000),
               reason: 'Processing time should be less than 5 seconds');
      });

      test('should identify failing OCR results', () {
        // Test case: Low quality OCR result that fails requirements
        final failingResult = OcrResult(
          extractedText: 'Pwr qlt txt',
          processingTimeMs: 7000, // Exceeds 5 seconds
          confidence: 0.75, // Below 90%
          textBlocks: 1,
          detectedLanguage: 'en',
          formattingMetadata: {
            'processing_algorithm': 'fallback_v1',
          },
        );

        expect(failingResult.meetsAccuracyRequirement, isFalse,
               reason: 'Should fail 90% accuracy requirement');
        expect(failingResult.meetsTimeRequirement, isFalse,
               reason: 'Should fail 5-second processing requirement');
      });
    });

    group('Text Formatting Validation Tests', () {
      test('should validate formatted text preservation', () {
        final formattedText = '''
**Meeting Notes**

Agenda Items:
• Review project status
• Discuss budget allocation
• Plan next sprint

Action Items:
1. Update documentation
2. Schedule team meeting
3. Review code changes

Notes:
The meeting went well and all topics were covered.
''';

        final result = OcrResult(
          extractedText: formattedText,
          processingTimeMs: 3200,
          confidence: 0.93,
          textBlocks: 4,
          detectedLanguage: 'en',
          formattingMetadata: {
            'bullet_points': 3,
            'numbered_lists': 3,
            'paragraphs': 2,
            'total_blocks': 4,
          },
        );

        expect(result.extractedText, contains('**Meeting Notes**'));
        expect(result.extractedText, contains('• Review project status'));
        expect(result.extractedText, contains('1. Update documentation'));
        expect(result.formattingMetadata['bullet_points'], equals(3));
        expect(result.formattingMetadata['numbered_lists'], equals(3));
        expect(result.meetsAccuracyRequirement, isTrue);
      });
    });
  });
}