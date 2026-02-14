import '../entities/user_profile.dart';
import '../../data/repositories/profile_repository.dart';

class UpdateProfile {
  UpdateProfile(this.repo);

  final ProfileRepository repo;

  Future<UserProfile?> call(UserProfile profile) => repo.upsertProfile(profile);
}
