import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/logger.dart';

class StorageService {
  StorageService({required this.client});

  final SupabaseClient? client;

  Future<String?> uploadBytes({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String contentType = 'application/octet-stream',
  }) async {
    final sb = client;
    if (sb == null) return null;
    try {
      await sb.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );
      return sb.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      Logger.e('Storage upload failed', error: e);
      return null;
    }
  }
}
