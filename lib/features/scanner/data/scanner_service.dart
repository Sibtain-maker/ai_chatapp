import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/document_model.dart';
import '../../../shared/providers/supabase_provider.dart';
import 'ai_enhancement_service.dart';

class ScannerService {
  final StorageService _storageService;
  final SupabaseClient _supabase;
  final AIEnhancementService _aiEnhancementService;
  final Uuid _uuid = const Uuid();

  ScannerService(this._storageService, this._supabase, this._aiEnhancementService);

  Future<DocumentModel> saveScannedDocument({
    required File imageFile,
    required String userId,
    String? title,
    bool enableAIEnhancement = true,
  }) async {
    try {
      File finalImageFile = imageFile;
      EnhancementMetadata? enhancementMetadata;
      
      // Apply AI enhancement if enabled
      if (enableAIEnhancement) {
        final enhancementResult = await _aiEnhancementService.enhanceDocument(
          originalFile: imageFile,
          userId: userId,
        );
        
        finalImageFile = enhancementResult.enhancedFile;
        enhancementMetadata = enhancementResult.enhancementMetadata;
        
        // Cleanup original if it was replaced
        if (finalImageFile.path != imageFile.path) {
          // Keep original for comparison, cleanup will happen later
        }
      }
      
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = finalImageFile.path.split('.').last;
      final fileName = 'scan_$timestamp.$extension';
      
      // Get file size
      final fileSize = await finalImageFile.length();
      
      // Upload enhanced image to storage
      final filePath = await _storageService.uploadDocument(
        file: finalImageFile,
        fileName: fileName,
        userId: userId,
      );

      // Create document record
      final documentId = _uuid.v4();
      final document = DocumentModel(
        id: documentId,
        userId: userId,
        title: title ?? '${enableAIEnhancement ? 'Enhanced Document' : 'Scanned Document'} ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        filePath: filePath,
        fileType: extension.toUpperCase(),
        fileSize: fileSize,
        createdAt: DateTime.now(),
        isEnhanced: enableAIEnhancement && enhancementMetadata != null,
        enhancementMetadata: enhancementMetadata?.toJson(),
        originalFilePath: enableAIEnhancement ? imageFile.path : null,
      );

      // Save to database
      await _supabase
          .from('documents')
          .insert(document.toJson());

      // Cleanup temporary enhanced file if different from original
      if (enableAIEnhancement && finalImageFile.path != imageFile.path) {
        await _aiEnhancementService.cleanupTempFile(finalImageFile);
      }

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

  /// Get enhancement result with before/after comparison
  Future<EnhancementResult> getEnhancementPreview({
    required File originalFile,
    required String userId,
  }) async {
    return _aiEnhancementService.enhanceDocument(
      originalFile: originalFile,
      userId: userId,
    );
  }
}

final scannerServiceProvider = Provider<ScannerService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final supabase = ref.watch(supabaseClientProvider);
  final aiEnhancementService = ref.watch(aiEnhancementServiceProvider);
  return ScannerService(storageService, supabase, aiEnhancementService);
});