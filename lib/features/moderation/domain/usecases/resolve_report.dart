import '../../data/repositories/moderation_repository.dart';

class ResolveReport {
  ResolveReport(this.repo);

  final ModerationRepository repo;

  Future<void> call({
    required String reportId,
    required String resolverId,
    required bool accept,
  }) => repo.resolve(reportId: reportId, resolverId: resolverId, accept: accept);
}
