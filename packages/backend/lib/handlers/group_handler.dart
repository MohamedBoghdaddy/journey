import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/group.dart';
import '../services/supabase_client.dart';

/// Handles CRUD operations for groups.
class GroupHandler {
  Router get router {
    final router = Router();

    // List groups
    router.get('/', (Request request) async {
      final client = SupabaseService.client;
      final result = await client.from('groups').select();
      final groups = (result as List<dynamic>).cast<Map<String, dynamic>>().map((e) => Group.fromMap(e).toMap()).toList();
      return Response.ok(jsonEncode(groups), headers: {'Content-Type': 'application/json'});
    });

    // Create a group
    router.post('/', (Request request) async {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final name = data['name'] as String?;
      final description = data['description'] as String?;
      final ownerId = data['owner_id'] as String?;
      if (name == null || description == null || ownerId == null) {
        return Response(400, body: jsonEncode({'error': 'Missing fields'}));
      }
      final client = SupabaseService.client;
      final response = await client.from('groups').insert({
        'name': name,
        'description': description,
        'owner_id': ownerId,
      }).select().single();
      final group = Group.fromMap(response as Map<String, dynamic>);
      return Response.ok(jsonEncode(group.toMap()), headers: {'Content-Type': 'application/json'});
    });

    // Update group
    router.put('/<id>', (Request request, String id) async {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final name = data['name'] as String?;
      final description = data['description'] as String?;
      if (name == null || description == null) {
        return Response(400, body: jsonEncode({'error': 'Missing fields'}));
      }
      final client = SupabaseService.client;
      await client.from('groups').update({'name': name, 'description': description}).eq('id', id);
      return Response.ok(jsonEncode({'message': 'Group updated'}), headers: {'Content-Type': 'application/json'});
    });

    // Delete group
    router.delete('/<id>', (Request request, String id) async {
      final client = SupabaseService.client;
      await client.from('groups').delete().eq('id', id);
      return Response.ok(jsonEncode({'message': 'Group deleted'}), headers: {'Content-Type': 'application/json'});
    });

    return router;
  }
}