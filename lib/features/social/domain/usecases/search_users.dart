import '../../data/repositories/social_repository.dart';
import '../entities/profile.dart';

class SearchUsers {
  SearchUsers(this.repo);

  final SocialRepository repo;

  Future<List<Profile>> call(String query) => repo.searchUsers(query);
}
