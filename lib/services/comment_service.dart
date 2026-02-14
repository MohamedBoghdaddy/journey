import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_model.dart';
import 'supabase_service.dart';

/// Service for creating and fetching comments on posts.
class CommentService {
  CommentService._();
  static final CommentService instance = CommentService._();
  final SupabaseClient _client = SupabaseService.client;

  /// Fetches all comments for a given post, ordered by creation time.
  Future<List<CommentModel>> fetchComments(String postId) async {
    final response = await _client
        .from('comments')
        .select()
        .eq('post_id', postId)
        .order('created_at', ascending: true);
    final data = response as List<dynamic>;
    return data
        .map((row) => CommentModel.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  /// Adds a comment to the specified post. Throws if the user is not
  /// authenticated.
  Future<CommentModel> addComment(String postId, String content) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    final response = await _client.from('comments').insert({
      'post_id': postId,
      'author_id': userId,
      'content': content,
    }).select().single();
    return CommentModel.fromMap(response as Map<String, dynamic>);
  }
}