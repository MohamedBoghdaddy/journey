import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report_model.dart';
import 'supabase_service.dart';

/// Service for creating and retrieving content reports. Reports can be
/// associated with either posts or comments, distinguished by the
/// `target_type` field ('post' or 'comment'). Only moderators and
/// administrators should fetch reports.
class ReportService {
  ReportService._();
  static final ReportService instance = ReportService._();
  final SupabaseClient _client = SupabaseService.client;

  /// Creates a report. The [targetType] should be either 'post' or 'comment'.
  Future<void> report({
    required String targetType,
    required String targetId,
    required String reason,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    await _client.from('reports').insert({
      'reporter_id': userId,
      'target_type': targetType,
      'target_id': targetId,
      'reason': reason,
      'status': 'pending',
    });
  }

  /// Fetches all reports. Only call this if the current user has the
  /// appropriate role (checked via [RoleGuard] in the UI). Reports are
  /// returned in descending order of creation time.
  Future<List<ReportModel>> fetchReports() async {
    final response = await _client.from('reports').select().order('created_at', ascending: false);
    final data = response as List<dynamic>;
    return data.map((row) => ReportModel.fromMap(row as Map<String, dynamic>)).toList();
  }

  /// Marks a report as resolved. Moderators can optionally supply a resolution
  /// message. For simplicity this method sets the status to 'resolved'.
  Future<void> resolveReport(String reportId) async {
    await _client.from('reports').update({'status': 'resolved'}).eq('id', reportId);
  }
}