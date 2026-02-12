import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';
import 'supabase_service.dart';

/// A service that handles CRUD operations for posts via Supabase.
class PostService {
  PostService._();
  static final PostService instance = PostService._();
  final SupabaseClient _client = SupabaseService.client;

  Future<List<PostModel>> fetchPosts() async {
    final response = await _client.from('posts').select();
    final data = response as List<dynamic>;
    return data.map((row) => PostModel.fromMap(row as Map<String, dynamic>)).toList();
  }

  Future<PostModel> createPost(String title, String content) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    final response = await _client.from('posts').insert({
      'author_id': userId,
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
}