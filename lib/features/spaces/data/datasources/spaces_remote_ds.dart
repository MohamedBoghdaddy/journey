import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/logger.dart';
import '../models/space_model.dart';

class SpacesRemoteDs {
  SpacesRemoteDs({required this.client});

  final SupabaseClient? client;

  Future<List<SpaceModel>> listSpaces({int limit = 50}) async {
    final sb = client;
    if (sb == null) return [];
    try {
      final rows = await sb
          .from(DbTables.spaces)
          .select('*')
          .order('created_at', ascending: false)
          .limit(limit);
      return (rows as List).map((e) => SpaceModel.fromMap(e)).toList();
    } catch (e) {
      Logger.w('listSpaces failed: $e');
      return [];
    }
  }

  Future<SpaceModel?> getSpace(String spaceId) async {
    final sb = client;
    if (sb == null) return null;
    try {
      final row = await sb.from(DbTables.spaces).select('*').eq('id', spaceId).maybeSingle();
      if (row == null) return null;
      return SpaceModel.fromMap(row);
    } catch (e) {
      Logger.w('getSpace failed: $e');
      return null;
    }
  }

  Future<SpaceModel> createSpace({
    required String name,
    String? description,
    String? city,
    required String ownerId,
  }) async {
    final sb = client;
    if (sb == null) throw const NetworkException('Supabase not initialized.');
    try {
      final row = await sb.from(DbTables.spaces).insert({
        'name': name,
        'description': description,
        'city': city,
        'owner_id': ownerId,
      }).select('*').single();
      return SpaceModel.fromMap(row);
    } catch (e) {
      throw NetworkException('Create space failed', cause: e);
    }
  }

  Future<void> joinSpace({required String spaceId, required String userId}) async {
    final sb = client;
    if (sb == null) return;
    try {
      await sb.from(DbTables.spaceMembers).upsert({
        'space_id': spaceId,
        'user_id': userId,
      });
    } catch (e) {
      Logger.w('joinSpace failed: $e');
    }
  }

  Future<void> leaveSpace({required String spaceId, required String userId}) async {
    final sb = client;
    if (sb == null) return;
    try {
      await sb.from(DbTables.spaceMembers).delete().eq('space_id', spaceId).eq('user_id', userId);
    } catch (e) {
      Logger.w('leaveSpace failed: $e');
    }
  }

  Future<List<Map<String, dynamic>>> listMembers(String spaceId, {int limit = 50}) async {
    final sb = client;
    if (sb == null) return [];
    try {
      // Tries to join profiles if RLS allows it.
      final rows = await sb
          .from(DbTables.spaceMembers)
          .select('user_id, created_at, profiles:profiles(id,email,display_name,avatar_url)')
          .eq('space_id', spaceId)
          .limit(limit);
      return (rows as List).cast<Map<String, dynamic>>();
    } catch (e) {
      Logger.w('listMembers failed: $e');
      return [];
    }
  }

  Future<bool> isMember(String spaceId, String userId) async {
    final sb = client;
    if (sb == null) return false;
    try {
      final row = await sb
          .from(DbTables.spaceMembers)
          .select('space_id')
          .eq('space_id', spaceId)
          .eq('user_id', userId)
          .maybeSingle();
      return row != null;
    } catch (e) {
      return false;
    }
  }
}
