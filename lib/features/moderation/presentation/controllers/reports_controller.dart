import 'package:flutter/foundation.dart';

import '../../../../core/utils/logger.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../domain/entities/mod_report.dart';
import '../../domain/usecases/list_reports.dart';
import '../../domain/usecases/resolve_report.dart';

class ReportsController extends ChangeNotifier {
  ReportsController({
    required this.authRepo,
    required this.listReports,
    required this.resolveReport,
  });

  final AuthRepository authRepo;
  final ListReports listReports;
  final ResolveReport resolveReport;

  bool isLoading = false;
  String? error;
  List<ModReport> reports = [];

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      reports = await listReports();
    } catch (e) {
      Logger.e('Load reports failed', error: e);
      error = 'Failed to load reports';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> resolve(ModReport r, bool accept) async {
    final me = authRepo.currentUser;
    if (me == null) return;
    try {
      await resolveReport(reportId: r.id, resolverId: me.id, accept: accept);
      await load();
    } catch (e) {
      Logger.e('Resolve report failed', error: e);
    }
  }
}
