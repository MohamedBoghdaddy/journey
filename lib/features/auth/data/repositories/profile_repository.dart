import '../../domain/entities/user_profile.dart';
import '../datasources/profile_remote_ds.dart';
import '../models/user_model.dart';

class ProfileRepository {
  ProfileRepository({required this.profileRemote});

  final ProfileRemoteDs profileRemote;

  Future<UserProfile?> getProfile(String userId) async {
    final m = await profileRemote.getProfile(userId);
    return m?.toEntity();
  }

  Future<UserProfile?> upsertProfile(UserProfile profile) async {
    final m = UserModel.fromEntity(profile);
    final saved = await profileRemote.upsertProfile(m);
    return saved?.toEntity();
  }
}
