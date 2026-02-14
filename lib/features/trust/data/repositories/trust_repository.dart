import '../datasources/trust_remote_ds.dart';
import '../models/report_model.dart';

class TrustRepository {
  TrustRepository({required this.remote});

  final TrustRemoteDs remote;

  Future<void> submitReport({
    required String reporterId,
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
  }) {
    final model = ReportModel(
      id: '',
      reporterId: reporterId,
      targetType: targetType,
      targetId: targetId,
      reason: reason,
      details: details,
    );
    return remote.submitReport(model);
  }
}
