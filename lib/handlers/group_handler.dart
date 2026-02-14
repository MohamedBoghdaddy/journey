import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/group_model.dart';
import '../services/supabase_client.dart';

/// CRUD endpoints for groups.
///
/// Routes:
/// - GET    /         => list groups
/// - POST   /         => create group {name, description, owner_id}
/// - PUT    /<id>     => update group {name, description}
/// - DELETE /<id>     => delete group
class GroupHandler {
  Router get router {
    final r = Router();

    // List groups
    r.get('/', (Request request) async {
      try {
        final client = SupabaseService.client;
        final result = await client.from('groups').select();

        final groups = (result as List)
            .cast<Map<String, dynamic>>()
            .map((m) => GroupModel.fromMap(m).toMap())
            .toList();

        return _json(200, groups);
      } catch (e) {
        return _json(
            500, {'error': 'Failed to list groups', 'details': e.toString()});
      }
    });

    // Create group
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
            .from('groups')
            .insert({
              'name': name,
              'description': description,
              'owner_id': ownerId,
            })
            .select()
            .single();

        final group = GroupModel.fromMap(inserted as Map<String, dynamic>);
        return _json(200, group.toMap());
      } catch (e) {
        return _json(
            400, {'error': 'Invalid JSON or request', 'details': e.toString()});
      }
    });

    // Update group
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
        await client
            .from('groups')
            .update({'name': name, 'description': description}).eq('id', id);

        return _json(200, {'message': 'Group updated'});
      } catch (e) {
        return _json(
            400, {'error': 'Invalid JSON or request', 'details': e.toString()});
      }
    });

    // Delete group
    r.delete('/<id>', (Request request, String id) async {
      try {
        final client = SupabaseService.client;
        await client.from('groups').delete().eq('id', id);
        return _json(200, {'message': 'Group deleted'});
      } catch (e) {
        return _json(
            500, {'error': 'Failed to delete group', 'details': e.toString()});
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
