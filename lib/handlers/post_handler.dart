import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/post_model.dart';
import '../services/supabase_client.dart';

/// CRUD endpoints for posts.
///
/// Routes:
/// - GET    /            => list posts (optional ?space_id=...)
/// - POST   /            => create post {title, content, author_id, space_id}
/// - PUT    /<id>        => update post {title, content}
/// - DELETE /<id>        => delete post
class PostHandler {
  Router get router {
    final r = Router();

    // List posts (optionally by space)
    r.get('/', (Request request) async {
      try {
        final client = SupabaseService.client;
        final spaceId = request.url.queryParameters['space_id'];

        dynamic query = client.from('posts').select('*');
        if (spaceId != null && spaceId.trim().isNotEmpty) {
          query = query.eq('space_id', spaceId);
        }

        final result = await query;

        final posts = (result as List)
            .cast<Map<String, dynamic>>()
            .map((m) => PostModel.fromMap(m).toMap())
            .toList();

        return _json(200, posts);
      } catch (e) {
        return _json(
            500, {'error': 'Failed to list posts', 'details': e.toString()});
      }
    });

    // Create post
    r.post('/', (Request request) async {
      try {
        final body = await request.readAsString();
        final data = (jsonDecode(body) as Map).cast<String, dynamic>();

        final title = data['title'] as String?;
        final content = data['content'] as String?;
        final authorId = data['author_id'] as String?;
        final spaceId = data['space_id'] as String?;

        if (title == null ||
            content == null ||
            authorId == null ||
            spaceId == null) {
          return _json(400, {'error': 'Missing fields'});
        }

        final client = SupabaseService.client;
        final inserted = await client
            .from('posts')
            .insert({
              'title': title,
              'content': content,
              'author_id': authorId,
              'space_id': spaceId,
            })
            .select()
            .single();

        final post = PostModel.fromMap(inserted as Map<String, dynamic>);
        return _json(200, post.toMap());
      } catch (e) {
        return _json(
            400, {'error': 'Invalid JSON or request', 'details': e.toString()});
      }
    });

    // Update post
    r.put('/<id>', (Request request, String id) async {
      try {
        final body = await request.readAsString();
        final data = (jsonDecode(body) as Map).cast<String, dynamic>();

        final title = data['title'] as String?;
        final content = data['content'] as String?;

        if (title == null || content == null) {
          return _json(400, {'error': 'Missing fields'});
        }

        final client = SupabaseService.client;
        await client
            .from('posts')
            .update({'title': title, 'content': content}).eq('id', id);

        return _json(200, {'message': 'Post updated'});
      } catch (e) {
        return _json(
            400, {'error': 'Invalid JSON or request', 'details': e.toString()});
      }
    });

    // Delete post
    r.delete('/<id>', (Request request, String id) async {
      try {
        final client = SupabaseService.client;
        await client.from('posts').delete().eq('id', id);
        return _json(200, {'message': 'Post deleted'});
      } catch (e) {
        return _json(
            500, {'error': 'Failed to delete post', 'details': e.toString()});
      }
    });

    return r;
  }

  Response _json(int status, Object body) {
    return Response(
      status,
      body: jsonEncode(body),
      headers: const {'Content-Type': 'application/json'},
    );
  }
}
