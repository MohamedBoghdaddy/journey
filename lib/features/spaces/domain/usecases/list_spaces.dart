import '../../data/repositories/spaces_repository.dart';
import '../entities/space.dart';

class ListSpaces {
  ListSpaces(this.repo);

  final SpacesRepository repo;

  Future<List<Space>> call() => repo.listSpaces();
}
