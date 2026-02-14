import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/utils/logger.dart';
import '../models/profile_model.dart';

class SocialRemoteDs {
  SocialRemoteDs({required this.client});

  final SupabaseClient? client;

  Future<ProfileModel?> getProfile(String userId) async {
    final sb = client;
    if (sb == null) return null;
    try {
      final row = await sb.from(DbTables.profiles).select('*').eq('id', userId).maybeSingle();
      if (row == null) return null;
      return ProfileModel.fromMap(row);
    } catch (e) {
      Logger.w('getProfile failed: $e');
      return null;
    }
  }

  Future<List<ProfileModel>> searchUsers(String query, {int limit = 30}) async {
    final sb = client;
    if (sb == null) return [];
    try {
      final q = query.trim();
      if (q.isEmpty) {
        final rows = await sb.from(DbTables.profiles).select('*').limit(limit);
        return (rows as List).map((e) => ProfileModel.fromMap(e)).toList();
      }

      // If your DB has a full-text search, replace this with a real search.
      final rows = await sb
          .from(DbTables.profiles)
          .select('*')
          .or('email.ilike.%$q%,display_name.ilike.%$q%')
          .limit(limit);
      return (rows as List).map((e) => ProfileModel.fromMap(e)).toList();
    } catch (e) {
      Logger.w('searchUsers failed: $e');
      return [];
    }
  }

  Future<bool> isFollowing({required String followerId, required String followingId}) async {
    final sb = client;
    if (sb == null) return false;
    try {
      final row = await sb
          .from(DbTables.follows)
          .select('follower_id')
          .eq('follower_id', followerId)
          .eq('following_id', followingId)
          .maybeSingle();
      return row != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> follow({required String followerId, required String followingId}) async {
    final sb = client;
    if (sb == null) return;
    try {
      await sb.from(DbTables.follows).upsert({
        'follower_id': followerId,
        'following_id': followingId,
      });
    } catch (e) {
      Logger.w('follow failed: $e');
    }
  }

  Future<void> unfollow({required String followerId, required String followingId}) async {
    final sb = client;
    if (sb == null) return;
    try {
      await sb
          .from(DbTables.follows)
          .delete()
          .eq('follower_id', followerId)
          .eq('following_id', followingId);
    } catch (e) {
      Logger.w('unfollow failed: $e');
    }
  }
}
