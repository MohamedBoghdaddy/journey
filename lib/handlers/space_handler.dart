import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/space_model.dart';
import '../services/supabase_client.dart';

/// CRUD endpoints for spaces.
///
/// Routes:
/// - GET    /         => list spaces
/// - POST   /         => create space {name, description, owner_id}
/// - PUT    /<id>     => update space {name, description}
/// - DELETE /<id>     => delete space
class SpaceHandler {
  Router get router {
    final r = Router();

    // List spaces
    r.get('/', (Request request) async {
      try {
        final client = SupabaseService.client;
        final result = await client.from('spaces').select();

        final spaces = (result as List)
            .cast<Map<String, dynamic>>()
            .map((m) => SpaceModel.fromMap(m).toMap())
            .toList();

        return _json(200, spaces);
      } catch (e) {
        return _json(
            500, {'error': 'Failed to list spaces', 'details': e.toString()});
      }
    });

    // Create space
    r.post('/', (Request request) async {
      try {
        final body = await request.readAsString();
        final data = (jsonDecode(body) as Map).cast<String, dynamic>();

        final name = data['name'] as String?;
        final description = data['description'] as String?;
        final ownerId = data['owner_id'] as String?;

        if (name == null || description == null || ownerId == null) {
          return _json(400, {'error': 'Missing fields'});
        }

        final client = SupabaseService.client;
        final inserted = await client
            .from('spaces')
            .insert({
              'name': name,
              'description': description,
              'owner_id': ownerId,
            })
            .select()
            .single();

        final space = SpaceModel.fromMap(inserted as Map<String, dynamic>);
        return _json(200, space.toMap());
      } catch (e) {
        return _json(
            400, {'error': 'Invalid JSON or request', 'details': e.toString()});
      }
    });

    // Update space
    r.put('/<id>', (Request request, String id) async {
      try {
        final body = await request.readAsString();
        final data = (jsonDecode(body) as Map).cast<String, dynamic>();

        final name = data['name'] as String?;
        final description = data['description'] as String?;

        if (name == null || description == null) {
          return _json(400, {'error': 'Missing fields'});
        }

        final client = SupabaseService.client;
        await client.from('spaces').update({
          'name': name,
          'description': description,
        }).eq('id', id);

        return _json(200, {'message': 'Space updated'});
      } catch (e) {
        return _json(
            400, {'error': 'Invalid JSON or request', 'details': e.toString()});
      }
    });

    // Delete space
    r.delete('/<id>', (Request request, String id) async {
      try {
        final client = SupabaseService.client;
        await client.from('spaces').delete().eq('id', id);
        return _json(200, {'message': 'Space deleted'});
      } catch (e) {
        return _json(
            500, {'error': 'Failed to delete space', 'details': e.toString()});
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
