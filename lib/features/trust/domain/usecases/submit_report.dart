import '../../data/repositories/trust_repository.dart';

class SubmitReport {
  SubmitReport(this.repo);

  final TrustRepository repo;

  Future<void> call({
    required String reporterId,
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
  }) {
    return repo.submitReport(
      reporterId: reporterId,
      targetType: targetType,
      targetId: targetId,
      reason: reason,
      details: details,
    );
  }
}
