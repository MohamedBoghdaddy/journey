import '../../domain/entities/mod_report.dart';
import '../datasources/moderation_remote_ds.dart';

class ModerationRepository {
  ModerationRepository({required this.remote});

  final ModerationRemoteDs remote;

  Future<List<ModReport>> listReports() async {
    final list = await remote.listReports();
    return list.map((m) => m.toEntity()).toList();
  }

  Future<void> resolve({
    required String reportId,
    required String resolverId,
    required bool accept,
  }) {
    return remote.resolveReport(
      reportId: reportId,
      resolverId: resolverId,
      status: accept ? 'resolved' : 'rejected',
    );
  }
}
