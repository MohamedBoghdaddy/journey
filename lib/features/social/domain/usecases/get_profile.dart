import '../../data/repositories/social_repository.dart';
import '../entities/profile.dart';

class GetProfile {
  GetProfile(this.repo);

  final SocialRepository repo;

  Future<Profile?> call(String userId) => repo.getProfile(userId);
}
