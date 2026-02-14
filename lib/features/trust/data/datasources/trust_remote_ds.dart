import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/logger.dart';
import '../models/report_model.dart';

class TrustRemoteDs {
  TrustRemoteDs({required this.client});

  final SupabaseClient? client;

  Future<void> submitReport(ReportModel model) async {
    final sb = client;
    if (sb == null) throw const NetworkException('Supabase not initialized.');
    try {
      await sb.from(DbTables.reports).insert(model.toInsertMap());
    } catch (e) {
      Logger.w('submitReport failed: $e');
      throw NetworkException('Report submission failed', cause: e);
    }
  }
}
