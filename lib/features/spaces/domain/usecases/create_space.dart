import '../../data/repositories/spaces_repository.dart';
import '../entities/space.dart';

class CreateSpace {
  CreateSpace(this.repo);

  final SpacesRepository repo;

  Future<Space> call({
    required String name,
    String? description,
    String? city,
    required String ownerId,
  }) {
    return repo.createSpace(
      name: name,
      description: description,
      city: city,
      ownerId: ownerId,
    );
  }
}
