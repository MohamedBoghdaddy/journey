import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/space.dart';
import '../services/supabase_client.dart';

/// Handles CRUD operations for spaces.
class SpaceHandler {
  Router get router {
    final router = Router();

    // List spaces
    router.get('/', (Request request) async {
      final client = SupabaseService.client;
      final result = await client.from('spaces').select();
      final spaces = (result as List<dynamic>).cast<Map<String, dynamic>>().map((e) => Space.fromMap(e).toMap()).toList();
      return Response.ok(jsonEncode(spaces), headers: {'Content-Type': 'application/json'});
    });

    // Create space
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
      final response = await client.from('spaces').insert({
        'name': name,
        'description': description,
        'owner_id': ownerId,
      }).select().single();
      final space = Space.fromMap(response as Map<String, dynamic>);
      return Response.ok(jsonEncode(space.toMap()), headers: {'Content-Type': 'application/json'});
    });

    // Update space
    router.put('/<id>', (Request request, String id) async {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final name = data['name'] as String?;
      final description = data['description'] as String?;
      if (name == null || description == null) {
        return Response(400, body: jsonEncode({'error': 'Missing fields'}));
      }
      final client = SupabaseService.client;
      await client.from('spaces').update({
        'name': name,
        'description': description,
      }).eq('id', id);
      return Response.ok(jsonEncode({'message': 'Space updated'}), headers: {'Content-Type': 'application/json'});
    });

    // Delete space
    router.delete('/<id>', (Request request, String id) async {
      final client = SupabaseService.client;
      await client.from('spaces').delete().eq('id', id);
      return Response.ok(jsonEncode({'message': 'Space deleted'}), headers: {'Content-Type': 'application/json'});
    });

    return router;
  }
}