import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/post.dart';
import '../services/supabase_client.dart';

/// Handles forum post CRUD operations.
class PostHandler {
  Router get router {
    final router = Router();

    // List all posts
    router.get('/', (Request request) async {
      final client = SupabaseService.client;
      final result = await client.from('posts').select();
      final posts = (result as List<dynamic>).cast<Map<String, dynamic>>().map((e) => Post.fromMap(e).toMap()).toList();
      return Response.ok(jsonEncode(posts), headers: {'Content-Type': 'application/json'});
    });

    // Create a new post
    router.post('/', (Request request) async {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final title = data['title'] as String?;
      final content = data['content'] as String?;
      final authorId = data['author_id'] as String?;
      if (title == null || content == null || authorId == null) {
        return Response(400, body: jsonEncode({'error': 'Missing fields'}));
      }
      final client = SupabaseService.client;
      final response = await client.from('posts').insert({
        'title': title,
        'content': content,
        'author_id': authorId,
      }).select().single();
      final post = Post.fromMap(response as Map<String, dynamic>);
      return Response.ok(jsonEncode(post.toMap()), headers: {'Content-Type': 'application/json'});
    });

    // Update an existing post
    router.put('/<id>', (Request request, String id) async {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final title = data['title'] as String?;
      final content = data['content'] as String?;
      if (title == null || content == null) {
        return Response(400, body: jsonEncode({'error': 'Missing fields'}));
      }
      final client = SupabaseService.client;
      await client.from('posts').update({'title': title, 'content': content}).eq('id', id);
      return Response.ok(jsonEncode({'message': 'Post updated'}), headers: {'Content-Type': 'application/json'});
    });

    // Delete a post
    router.delete('/<id>', (Request request, String id) async {
      final client = SupabaseService.client;
      await client.from('posts').delete().eq('id', id);
      return Response.ok(jsonEncode({'message': 'Post deleted'}), headers: {'Content-Type': 'application/json'});
    });

    return router;
  }
}