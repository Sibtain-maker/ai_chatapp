import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chatapp/features/scanner/data/ai_enhancement_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

void main() {
  group('AI Enhancement Service Tests', () {
    late AIEnhancementService aiEnhancementService;
    
    setUpAll(() {
      aiEnhancementService = AIEnhancementService();
    });

    group('Enhancement Processing Tests', () {
      test('enhanceDocument processes valid image within 3 second constraint', () async {
        // Arrange
        final testImage = _createTestImage(200, 300);
        final tempFile = await _createTempImageFile(testImage, 'test.jpg');
        
        try {
          // Act
          final result = await aiEnhancementService.enhanceDocument(
            originalFile: tempFile,
            userId: 'test-user-123',
          );

          // Assert
          expect(result.processingTimeMs, lessThan(3000), 
              reason: 'Enhancement must complete within 3 seconds');
          expect(result.originalFile.path, equals(tempFile.path));
          expect(result.enhancedFile.existsSync(), isTrue);
          expect(result.enhancementMetadata.algorithm, equals('AI_HYBRID_V1'));
          expect(result.enhancementMetadata.qualityScore, greaterThanOrEqualTo(100));
          expect(result.enhancementMetadata.qualityScore, lessThanOrEqualTo(200));
          
          // Cleanup
          await aiEnhancementService.cleanupTempFile(result.enhancedFile);
        } finally {
          await tempFile.delete();
        }
      });

      test('enhanceDocument handles invalid image file gracefully', () async {
        // Arrange
        final invalidFile = await _createTempTextFile('not an image');
        
        try {
          // Act & Assert
          expect(
            () => aiEnhancementService.enhanceDocument(
              originalFile: invalidFile,
              userId: 'test-user-123',
            ),
            throwsA(isA<Exception>()),
          );
        } finally {
          await invalidFile.delete();
        }
      });

      test('enhanceDocument creates enhanced file different from original', () async {
        // Arrange
        final testImage = _createTestImage(100, 150);
        final tempFile = await _createTempImageFile(testImage, 'test.png');
        
        try {
          // Act
          final result = await aiEnhancementService.enhanceDocument(
            originalFile: tempFile,
            userId: 'test-user-123',
          );

          // Assert
          expect(result.enhancedFile.path, isNot(equals(result.originalFile.path)));
          expect(result.enhancedFile.existsSync(), isTrue);
          
          // Enhanced file should be different from original
          final originalBytes = await result.originalFile.readAsBytes();
          final enhancedBytes = await result.enhancedFile.readAsBytes();
          expect(enhancedBytes, isNot(equals(originalBytes)));
          
          // Cleanup
          await aiEnhancementService.cleanupTempFile(result.enhancedFile);
        } finally {
          await tempFile.delete();
        }
      });

      test('enhancement quality score is reasonable', () async {
        // Arrange
        final testImage = _createTestImage(150, 200);
        final tempFile = await _createTempImageFile(testImage, 'test.jpg');
        
        try {
          // Act
          final result = await aiEnhancementService.enhanceDocument(
            originalFile: tempFile,
            userId: 'test-user-123',
          );

          // Assert
          final qualityScore = result.enhancementMetadata.qualityScore;
          expect(qualityScore, greaterThanOrEqualTo(100.0));
          expect(qualityScore, lessThanOrEqualTo(200.0));
          
          // Cleanup
          await aiEnhancementService.cleanupTempFile(result.enhancedFile);
        } finally {
          await tempFile.delete();
        }
      });
    });

    group('Enhancement Metadata Tests', () {
      test('enhancement metadata contains required fields', () async {
        // Arrange
        final testImage = _createTestImage(100, 100);
        final tempFile = await _createTempImageFile(testImage, 'test.jpg');
        
        try {
          // Act
          final result = await aiEnhancementService.enhanceDocument(
            originalFile: tempFile,
            userId: 'test-user-123',
          );

          // Assert
          final metadata = result.enhancementMetadata;
          expect(metadata.algorithm, isNotEmpty);
          expect(metadata.qualityScore, isA<double>());
          expect(metadata.processingDate, isA<DateTime>());
          
          // Test JSON serialization
          final json = metadata.toJson();
          expect(json['algorithm'], equals(metadata.algorithm));
          expect(json['quality_score'], equals(metadata.qualityScore));
          expect(json['processing_date'], isA<String>());
          
          // Test JSON deserialization
          final deserializedMetadata = EnhancementMetadata.fromJson(json);
          expect(deserializedMetadata.algorithm, equals(metadata.algorithm));
          expect(deserializedMetadata.qualityScore, equals(metadata.qualityScore));
          
          // Cleanup
          await aiEnhancementService.cleanupTempFile(result.enhancedFile);
        } finally {
          await tempFile.delete();
        }
      });
    });

    group('File Management Tests', () {
      test('cleanupTempFile removes file successfully', () async {
        // Arrange
        final testImage = _createTestImage(50, 50);
        final tempFile = await _createTempImageFile(testImage, 'cleanup_test.jpg');
        
        // Act
        await aiEnhancementService.cleanupTempFile(tempFile);
        
        // Assert
        expect(tempFile.existsSync(), isFalse);
      });

      test('cleanupTempFile handles non-existent file gracefully', () async {
        // Arrange
        final nonExistentFile = File('/path/that/does/not/exist.jpg');
        
        // Act & Assert - should not throw
        await aiEnhancementService.cleanupTempFile(nonExistentFile);
      });
    });

    group('Performance Tests', () {
      test('enhancement meets performance requirements for various image sizes', () async {
        final testSizes = [
          [100, 100],   // Small
          [500, 700],   // Medium
          [800, 1200],  // Large
        ];

        for (final size in testSizes) {
          final testImage = _createTestImage(size[0], size[1]);
          final tempFile = await _createTempImageFile(testImage, 'perf_test_${size[0]}x${size[1]}.jpg');
          
          try {
            final result = await aiEnhancementService.enhanceDocument(
              originalFile: tempFile,
              userId: 'test-user-123',
            );

            expect(result.processingTimeMs, lessThan(3000), 
                reason: 'Enhancement of ${size[0]}x${size[1]} image must complete within 3 seconds');
            
            await aiEnhancementService.cleanupTempFile(result.enhancedFile);
          } finally {
            await tempFile.delete();
          }
        }
      });
    });
  });
}

// Helper function to create a test image
img.Image _createTestImage(int width, int height) {
  final image = img.Image(width: width, height: height);
  
  // Fill with a gradient pattern to simulate a document
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final intensity = ((x + y) * 255 / (width + height)).round();
      final color = img.ColorRgb8(intensity, intensity, intensity);
      image.setPixel(x, y, color);
    }
  }
  
  return image;
}

// Helper function to create a temporary image file
Future<File> _createTempImageFile(img.Image image, String fileName) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/$fileName');
  
  final bytes = Uint8List.fromList(img.encodeJpg(image));
  await file.writeAsBytes(bytes);
  
  return file;
}

// Helper function to create a temporary text file (for error testing)
Future<File> _createTempTextFile(String content) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/invalid.txt');
  
  await file.writeAsString(content);
  
  return file;
}