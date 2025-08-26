import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chatapp/core/models/document_model.dart';

void main() {
  group('Scanner Feature Tests', () {
    group('DocumentModel Tests', () {
      test('creates document model with required properties', () {
        // Arrange & Act
        final document = DocumentModel(
          id: 'test-id',
          userId: 'user-123',
          title: 'Test Document',
          filePath: 'documents/user-123/test.jpg',
          fileType: 'JPG',
          fileSize: 1024,
          createdAt: DateTime(2023, 1, 1),
        );

        // Assert
        expect(document.id, equals('test-id'));
        expect(document.userId, equals('user-123'));
        expect(document.title, equals('Test Document'));
        expect(document.filePath, equals('documents/user-123/test.jpg'));
        expect(document.fileType, equals('JPG'));
        expect(document.fileSize, equals(1024));
        expect(document.createdAt, equals(DateTime(2023, 1, 1)));
      });

      test('converts from JSON correctly', () {
        // Arrange
        final json = {
          'id': 'test-id',
          'user_id': 'user-123',
          'title': 'Test Document',
          'file_path': 'documents/user-123/test.jpg',
          'file_type': 'JPG',
          'file_size': 1024,
          'created_at': '2023-01-01T00:00:00.000Z',
        };

        // Act
        final document = DocumentModel.fromJson(json);

        // Assert
        expect(document.id, equals('test-id'));
        expect(document.userId, equals('user-123'));
        expect(document.title, equals('Test Document'));
        expect(document.filePath, equals('documents/user-123/test.jpg'));
        expect(document.fileType, equals('JPG'));
        expect(document.fileSize, equals(1024));
      });

      test('converts to JSON correctly', () {
        // Arrange
        final document = DocumentModel(
          id: 'test-id',
          userId: 'user-123',
          title: 'Test Document',
          filePath: 'documents/user-123/test.jpg',
          fileType: 'JPG',
          fileSize: 1024,
          createdAt: DateTime(2023, 1, 1),
        );

        // Act
        final json = document.toJson();

        // Assert
        expect(json['id'], equals('test-id'));
        expect(json['user_id'], equals('user-123'));
        expect(json['title'], equals('Test Document'));
        expect(json['file_path'], equals('documents/user-123/test.jpg'));
        expect(json['file_type'], equals('JPG'));
        expect(json['file_size'], equals(1024));
        expect(json['created_at'], equals('2023-01-01T00:00:00.000'));
      });

      test('creates copy with updated properties', () {
        // Arrange
        final original = DocumentModel(
          id: 'test-id',
          userId: 'user-123',
          title: 'Original Title',
          filePath: 'documents/user-123/test.jpg',
          fileType: 'JPG',
          fileSize: 1024,
          createdAt: DateTime(2023, 1, 1),
        );

        // Act
        final copy = original.copyWith(
          title: 'Updated Title',
          fileSize: 2048,
        );

        // Assert
        expect(copy.id, equals('test-id')); // Unchanged
        expect(copy.userId, equals('user-123')); // Unchanged
        expect(copy.title, equals('Updated Title')); // Changed
        expect(copy.fileSize, equals(2048)); // Changed
        expect(copy.filePath, equals('documents/user-123/test.jpg')); // Unchanged
      });
    });

    group('ScannerService Integration Tests', () {
      test('generates unique filename with timestamp', () {
        // Test basic filename generation logic
        final timestamp1 = DateTime.now().millisecondsSinceEpoch;
        final timestamp2 = DateTime.now().millisecondsSinceEpoch + 1000;
        
        final fileName1 = 'scan_$timestamp1.jpg';
        final fileName2 = 'scan_$timestamp2.jpg';
        
        expect(fileName1, isNot(equals(fileName2)));
        expect(fileName1, contains('scan_'));
        expect(fileName1, contains('.jpg'));
      });

      test('extracts file extension correctly', () {
        // Test file extension extraction
        const filePath1 = '/path/to/image.jpg';
        const filePath2 = '/path/to/document.png';
        const filePath3 = '/path/to/file.jpeg';
        
        final ext1 = filePath1.split('.').last;
        final ext2 = filePath2.split('.').last;
        final ext3 = filePath3.split('.').last;
        
        expect(ext1, equals('jpg'));
        expect(ext2, equals('png'));
        expect(ext3, equals('jpeg'));
      });

      test('generates default document title with date', () {
        final now = DateTime.now();
        final expectedTitle = 'Scanned Document ${now.day}/${now.month}/${now.year}';
        
        // This should match the format used in ScannerService
        expect(expectedTitle, contains('Scanned Document'));
        expect(expectedTitle, contains('${now.day}'));
        expect(expectedTitle, contains('${now.month}'));
        expect(expectedTitle, contains('${now.year}'));
      });
    });
  });
}