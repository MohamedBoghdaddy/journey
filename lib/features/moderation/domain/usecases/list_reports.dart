import '../../data/repositories/moderation_repository.dart';
import '../entities/mod_report.dart';

class ListReports {
  ListReports(this.repo);

  final ModerationRepository repo;

  Future<List<ModReport>> call() => repo.listReports();
}
