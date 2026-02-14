import 'package:flutter/foundation.dart';

import '../../../../core/utils/logger.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/follow_user.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/unfollow_user.dart';
import '../../data/repositories/social_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({
    required this.authRepo,
    required this.getProfile,
    required this.followUser,
    required this.unfollowUser,
    required this.socialRepo,
    required this.userId,
  });

  final AuthRepository authRepo;
  final GetProfile getProfile;
  final FollowUser followUser;
  final UnfollowUser unfollowUser;
  final SocialRepository socialRepo;
  final String userId;

  bool isLoading = false;
  String? error;
  Profile? profile;
  bool isMe = false;
  bool isFollowing = false;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      profile = await getProfile(userId);
      final me = authRepo.currentUser;
      isMe = me?.id == userId;
      if (me != null && !isMe) {
        isFollowing = await socialRepo.isFollowing(me.id, userId);
      }
    } catch (e) {
      Logger.e('Load profile failed', error: e);
      error = 'Failed to load profile';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFollow() async {
    final me = authRepo.currentUser;
    if (me == null || isMe) return;
    try {
      if (isFollowing) {
        await unfollowUser(me.id, userId);
        isFollowing = false;
      } else {
        await followUser(me.id, userId);
        isFollowing = true;
      }
      notifyListeners();
    } catch (e) {
      Logger.e('Toggle follow failed', error: e);
    }
  }
}
