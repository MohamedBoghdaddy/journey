import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../services/supabase_client.dart';

/// Handles report-related HTTP requests. Reports allow users to flag posts or
/// comments for moderator review. This handler exposes endpoints to create
/// reports, fetch all reports, and mark reports as resolved. Access control
/// (ensuring only moderators/admins can fetch or resolve reports) should be
/// implemented via middleware or higher-level routing and is not shown here.
class ReportHandler {
  Router get router {
    final router = Router();

    // Create a new report
    router.post('/', (Request request) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final reporterId = data['reporter_id'] as String?;
      final targetType = data['target_type'] as String?;
      final targetId = data['target_id'] as String?;
      final reason = data['reason'] as String?;
      if (reporterId == null || targetType == null || targetId == null || reason == null) {
        return Response(400, body: jsonEncode({'error': 'Missing fields'}));
      }
      final client = SupabaseService.client;
      await client.from('reports').insert({
        'reporter_id': reporterId,
        'target_type': targetType,
        'target_id': targetId,
        'reason': reason,
        'status': 'pending',
      });
      return Response.ok(jsonEncode({'message': 'Report submitted'}), headers: {'Content-Type': 'application/json'});
    });

    // Fetch all reports (for admins/moderators)
    router.get('/', (Request request) async {
      final client = SupabaseService.client;
      final response = await client.from('reports').select().order('created_at', ascending: false);
      return Response.ok(jsonEncode(response), headers: {'Content-Type': 'application/json'});
    });

    // Resolve a report
    router.put('/<id>/resolve', (Request request, String id) async {
      final client = SupabaseService.client;
      await client.from('reports').update({'status': 'resolved'}).eq('id', id);
      return Response.ok(jsonEncode({'message': 'Report resolved'}), headers: {'Content-Type': 'application/json'});
    });

    return router;
  }
}