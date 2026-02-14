import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../entities/user_profile.dart';

class GetMe {
  GetMe({required this.authRepo, required this.profileRepo});

  final AuthRepository authRepo;
  final ProfileRepository profileRepo;

  Future<UserProfile?> call() async {
    final auth = authRepo.currentUser;
    if (auth == null) return null;

    final p = await profileRepo.getProfile(auth.id);
    return p ?? UserProfile(id: auth.id, email: auth.email ?? '');
  }
}
