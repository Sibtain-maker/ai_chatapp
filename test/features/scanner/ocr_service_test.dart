import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chatapp/features/scanner/data/ocr_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('OcrService Tests', () {
    // Note: OCR service tests require platform channels and ML Kit
    // These are better tested in integration tests with actual devices
    
    test('should have OcrService class available', () {
      // Basic test that the class can be imported and referenced
      expect(OcrService, isNotNull);
    });

    group('Performance Tests', () {
      test('should meet time requirements', () {
        // Mock fast processing
        final result = OcrResult(
          extractedText: 'Test text',
          processingTimeMs: 3000, // 3 seconds
          confidence: 0.95,
          textBlocks: 5,
          detectedLanguage: 'en',
          formattingMetadata: {},
        );
        
        expect(result.meetsTimeRequirement, isTrue);
        
        // Mock slow processing
        final slowResult = result.copyWith(processingTimeMs: 6000); // 6 seconds
        expect(slowResult.meetsTimeRequirement, isFalse);
      });

      test('should meet accuracy requirements', () {
        // High accuracy result
        final highAccuracyResult = OcrResult(
          extractedText: 'Test text',
          processingTimeMs: 2000,
          confidence: 0.92, // 92%
          textBlocks: 5,
          detectedLanguage: 'en',
          formattingMetadata: {},
        );
        
        expect(highAccuracyResult.meetsAccuracyRequirement, isTrue);
        
        // Low accuracy result
        final lowAccuracyResult = highAccuracyResult.copyWith(confidence: 0.85); // 85%
        expect(lowAccuracyResult.meetsAccuracyRequirement, isFalse);
      });
    });

    group('OcrResult Tests', () {
      test('should serialize and deserialize correctly', () {
        final original = OcrResult(
          extractedText: 'Sample text with bullet points:\n• First item\n• Second item',
          processingTimeMs: 2500,
          confidence: 0.94,
          textBlocks: 3,
          detectedLanguage: 'en',
          formattingMetadata: {
            'bullet_points': 2,
            'paragraphs': 1,
            'total_blocks': 3,
          },
        );
        
        final json = original.toJson();
        final deserialized = OcrResult.fromJson(json);
        
        expect(deserialized.extractedText, equals(original.extractedText));
        expect(deserialized.processingTimeMs, equals(original.processingTimeMs));
        expect(deserialized.confidence, equals(original.confidence));
        expect(deserialized.textBlocks, equals(original.textBlocks));
        expect(deserialized.detectedLanguage, equals(original.detectedLanguage));
        expect(deserialized.formattingMetadata, equals(original.formattingMetadata));
      });
    });
  });
}

// Mock classes for testing
class MockRect {
  final double left, top, right, bottom;
  MockRect(this.left, this.top, this.right, this.bottom);
}

class MockTextElement {
  final String text;
  MockTextElement(this.text);
}

class MockTextLine {
  final List<MockTextElement> elements;
  MockTextLine(this.elements);
}

class MockTextBlock {
  final String text;
  final MockRect boundingBox;
  final List<MockTextLine> lines;
  
  MockTextBlock(this.text, {required this.boundingBox, List<MockTextLine>? lines}) 
    : lines = lines ?? [MockTextLine([MockTextElement(text)])];
}

class MockRecognizedText {
  final List<MockTextBlock> blocks;
  MockRecognizedText(this.blocks);
  
  String get text => blocks.map((b) => b.text).join('\n');
}

// Extension to add copyWith method for testing
extension OcrResultCopyWith on OcrResult {
  OcrResult copyWith({
    String? extractedText,
    int? processingTimeMs,
    double? confidence,
    int? textBlocks,
    String? detectedLanguage,
    Map<String, dynamic>? formattingMetadata,
  }) {
    return OcrResult(
      extractedText: extractedText ?? this.extractedText,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
      confidence: confidence ?? this.confidence,
      textBlocks: textBlocks ?? this.textBlocks,
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
      formattingMetadata: formattingMetadata ?? this.formattingMetadata,
    );
  }
}