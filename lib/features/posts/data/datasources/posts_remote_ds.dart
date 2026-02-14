import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/logger.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';

class PostsRemoteDs {
  PostsRemoteDs({required this.client});

  final SupabaseClient? client;

  Future<List<PostModel>> listFeed({int limit = 30}) async {
    final sb = client;
    if (sb == null) return [];
    try {
      final rows = await sb
          .from(DbTables.posts)
          .select('*')
          .order('created_at', ascending: false)
          .limit(limit);
      return (rows as List).map((e) => PostModel.fromMap(e)).toList();
    } catch (e) {
      Logger.w('listFeed failed: $e');
      return [];
    }
  }

  Future<List<PostModel>> listSpacePosts(String spaceId, {int limit = 30}) async {
    final sb = client;
    if (sb == null) return [];
    try {
      final rows = await sb
          .from(DbTables.posts)
          .select('*')
          .eq('space_id', spaceId)
          .order('created_at', ascending: false)
          .limit(limit);
      return (rows as List).map((e) => PostModel.fromMap(e)).toList();
    } catch (e) {
      Logger.w('listSpacePosts failed: $e');
      return [];
    }
  }

  Future<PostModel?> getPost(String postId) async {
    final sb = client;
    if (sb == null) return null;
    try {
      final row = await sb.from(DbTables.posts).select('*').eq('id', postId).maybeSingle();
      if (row == null) return null;
      return PostModel.fromMap(row);
    } catch (e) {
      Logger.w('getPost failed: $e');
      return null;
    }
  }

  Future<PostModel> createPost({
    required String authorId,
    String? spaceId,
    required String title,
    required String content,
  }) async {
    final sb = client;
    if (sb == null) throw const NetworkException('Supabase not initialized.');
    try {
      final row = await sb.from(DbTables.posts).insert({
        'author_id': authorId,
        'space_id': spaceId,
        'title': title,
        'content': content,
      }).select('*').single();
      return PostModel.fromMap(row);
    } catch (e) {
      throw NetworkException('Create post failed', cause: e);
    }
  }

  Future<void> toggleLike({required String postId, required String userId}) async {
    final sb = client;
    if (sb == null) return;

    // Try reactions table
    try {
      final existing = await sb
          .from(DbTables.reactions)
          .select('id')
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();
      if (existing != null) {
        await sb.from(DbTables.reactions).delete().eq('id', existing['id']);
      } else {
        await sb.from(DbTables.reactions).insert({
          'post_id': postId,
          'user_id': userId,
          'type': 'like',
        });
      }
      return;
    } catch (_) {
      // ignore and fallback to votes
    }

    try {
      final existing = await sb
          .from(DbTables.votes)
          .select('id')
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();
      if (existing != null) {
        await sb.from(DbTables.votes).delete().eq('id', existing['id']);
      } else {
        await sb.from(DbTables.votes).insert({
          'post_id': postId,
          'user_id': userId,
          'value': 1,
        });
      }
    } catch (e) {
      Logger.w('toggleLike failed: $e');
    }
  }

  Future<List<CommentModel>> listComments(String postId, {int limit = 50}) async {
    final sb = client;
    if (sb == null) return [];
    try {
      final rows = await sb
          .from(DbTables.comments)
          .select('*')
          .eq('post_id', postId)
          .order('created_at', ascending: true)
          .limit(limit);
      return (rows as List).map((e) => CommentModel.fromMap(e)).toList();
    } catch (e) {
      Logger.w('listComments failed: $e');
      return [];
    }
  }

  Future<CommentModel> addComment({
    required String postId,
    required String userId,
    required String content,
  }) async {
    final sb = client;
    if (sb == null) throw const NetworkException('Supabase not initialized.');
    try {
      final row = await sb.from(DbTables.comments).insert({
        'post_id': postId,
        'user_id': userId,
        'content': content,
      }).select('*').single();
      return CommentModel.fromMap(row);
    } catch (e) {
      throw NetworkException('Add comment failed', cause: e);
    }
  }
}
