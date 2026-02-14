import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/logger.dart';
import '../models/mod_report_model.dart';

class ModerationRemoteDs {
  ModerationRemoteDs({required this.client});

  final SupabaseClient? client;

  Future<List<ModReportModel>> listReports({int limit = 100}) async {
    final sb = client;
    if (sb == null) return [];
    try {
      final rows = await sb
          .from(DbTables.reports)
          .select('*')
          .order('created_at', ascending: false)
          .limit(limit);
      return (rows as List).map((e) => ModReportModel.fromMap(e)).toList();
    } catch (e) {
      Logger.w('listReports failed: $e');
      return [];
    }
  }

  Future<void> resolveReport({
    required String reportId,
    required String resolverId,
    required String status, // 'resolved' | 'rejected'
  }) async {
    final sb = client;
    if (sb == null) throw const NetworkException('Supabase not initialized.');
    try {
      await sb.from(DbTables.reports).update({
        'status': status,
        'resolved_by': resolverId,
        'resolved_at': DateTime.now().toIso8601String(),
      }).eq('id', reportId);
    } catch (e) {
      throw NetworkException('Resolve report failed', cause: e);
    }
  }
}
