import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/document_model.dart';
import '../../../shared/providers/supabase_provider.dart';

class ScannerService {
  final StorageService _storageService;
  final SupabaseClient _supabase;
  final Uuid _uuid = const Uuid();

  ScannerService(this._storageService, this._supabase);

  Future<DocumentModel> saveScannedDocument({
    required File imageFile,
    required String userId,
    String? title,
  }) async {
    try {
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = imageFile.path.split('.').last;
      final fileName = 'scan_$timestamp.$extension';
      
      // Get file size
      final fileSize = await imageFile.length();
      
      // Upload to storage
      final filePath = await _storageService.uploadDocument(
        file: imageFile,
        fileName: fileName,
        userId: userId,
      );

      // Create document record
      final documentId = _uuid.v4();
      final document = DocumentModel(
        id: documentId,
        userId: userId,
        title: title ?? 'Scanned Document ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        filePath: filePath,
        fileType: extension.toUpperCase(),
        fileSize: fileSize,
        createdAt: DateTime.now(),
      );

      // Save to database
      await _supabase
          .from('documents')
          .insert(document.toJson());

      return document;
    } catch (e) {
      throw Exception('Failed to save scanned document: $e');
    }
  }

  Future<List<DocumentModel>> getUserDocuments(String userId) async {
    try {
      final response = await _supabase
          .from('documents')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => DocumentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user documents: $e');
    }
  }

  Future<void> deleteDocument(DocumentModel document) async {
    try {
      // Delete from storage
      await _storageService.deleteDocument(document.filePath);
      
      // Delete from database
      await _supabase
          .from('documents')
          .delete()
          .eq('id', document.id);
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  Future<String> getDocumentUrl(DocumentModel document) async {
    return _storageService.getDocumentUrl(document.filePath);
  }
}

final scannerServiceProvider = Provider<ScannerService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final supabase = ref.watch(supabaseClientProvider);
  return ScannerService(storageService, supabase);
});