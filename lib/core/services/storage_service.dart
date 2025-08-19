import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/providers/supabase_provider.dart';

class StorageService {
  final SupabaseClient _supabase;

  StorageService(this._supabase);

  Future<String> uploadDocument({
    required File file,
    required String fileName,
    required String userId,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final filePath = 'documents/$userId/$fileName';

      await _supabase.storage.from('documents').uploadBinary(
        filePath,
        bytes,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: false,
        ),
      );

      return filePath;
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  Future<String> getDocumentUrl(String filePath) async {
    try {
      return _supabase.storage.from('documents').getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Failed to get document URL: $e');
    }
  }

  Future<void> deleteDocument(String filePath) async {
    try {
      await _supabase.storage.from('documents').remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  Future<String> uploadAvatar({
    required File file,
    required String fileName,
    required String userId,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final filePath = 'avatars/$userId/$fileName';

      await _supabase.storage.from('avatars').uploadBinary(
        filePath,
        bytes,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );

      return _supabase.storage.from('avatars').getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return StorageService(supabase);
});