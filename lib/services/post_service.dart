import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';
import 'supabase_service.dart';
import 'reputation_service.dart';

/// A service that handles CRUD operations for posts via Supabase.
class PostService {
  PostService._();
  static final PostService instance = PostService._();
  final SupabaseClient _client = SupabaseService.client;

  /// Fetches posts from the `posts` table. If a [spaceId] is provided the
  /// query is filtered to posts within that space. Posts are ordered by
  /// creation date descending so that the newest appear first.
  Future<List<PostModel>> fetchPosts({String? spaceId}) async {
    final query = _client.from('posts').select();
    if (spaceId != null) {
      query.eq('space_id', spaceId);
    }
    // Request the count of votes if supported by a database view or function. If
    // the backend exposes a materialized view with a `vote_count` column this
    // will populate the field on [PostModel].
    query.order('created_at', ascending: false);
    final response = await query;
    final data = response as List<dynamic>;
    return data
        .map((row) => PostModel.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  /// Creates a post within a specific space. The current user must be
  /// authenticated; otherwise an exception is thrown.
  Future<PostModel> createPost(
    String spaceId,
    String title,
    String content,
  ) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    final response = await _client.from('posts').insert({
      'author_id': userId,
      'space_id': spaceId,
      'title': title,
      'content': content,
    }).select().single();
    return PostModel.fromMap(response as Map<String, dynamic>);
  }

  Future<void> updatePost(String postId, String title, String content) async {
    await _client.from('posts').update({
      'title': title,
      'content': content,
    }).eq('id', postId);
  }

  Future<void> deletePost(String postId) async {
    await _client.from('posts').delete().eq('id', postId);
  }

  /// Inserts a vote record for the given post. If the user has already voted
  /// this method will throw an exception due to a unique constraint violation
  /// on the `(post_id, user_id)` pair (if enforced in your database). It is
  /// recommended to handle this error in the calling code and call
  /// [removeVote] instead to toggle the vote.
  Future<void> upvotePost(String postId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    // Insert a new vote record. A unique constraint on (post_id, user_id)
    // should prevent duplicate votes from the same user.
    await _client.from('votes').insert({
      'post_id': postId,
      'user_id': userId,
    });
    // After voting, increase the reputation of the post author. We fetch the
    // post to determine the author_id and then call the [ReputationService].
    final post = await _client.from('posts').select('author_id').eq('id', postId).single() as Map<String, dynamic>;
    final authorId = post['author_id'] as String;
    // Do not award reputation if the user votes on their own post.
    if (authorId != userId) {
      try {
        // Increase the author's reputation by 1 point. Adjust this value to
        // tune your reward system.
        await ReputationService.instance.increaseReputation(authorId, 1);
      } catch (_) {
        // Ignore errors when updating reputation; the vote has already been
        // recorded. In a production app you may want to surface this via
        // logging or user feedback.
      }
    }
  }

  /// Removes a vote previously added by the current user for the given post.
  Future<void> removeVote(String postId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    await _client
        .from('votes')
        .delete()
        .match({'post_id': postId, 'user_id': userId});
    // Decrease the reputation of the post author when a vote is removed. Fetch
    // the author of the post and subtract one point (if it’s not the same
    // user). As with upvotes, errors are swallowed to avoid interfering with
    // the main vote removal operation.
    final post = await _client.from('posts').select('author_id').eq('id', postId).single() as Map<String, dynamic>;
    final authorId = post['author_id'] as String;
    if (authorId != userId) {
      try {
        await ReputationService.instance.increaseReputation(authorId, -1);
      } catch (_) {
        // Ignore errors during reputation update.
      }
    }
  }

  /// Checks if the current user has already voted on the given post. Returns
  /// `true` if a vote exists, otherwise `false`.
  Future<bool> hasVoted(String postId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;
    final response = await _client
        .from('votes')
        .select('id')
        .match({'post_id': postId, 'user_id': userId})
        .maybeSingle();
    return response != null;
  }
}