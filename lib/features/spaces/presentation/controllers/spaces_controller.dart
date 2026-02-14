import 'package:flutter/foundation.dart';

import '../../../../core/utils/logger.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../domain/entities/space.dart';
import '../../domain/usecases/create_space.dart';
import '../../domain/usecases/join_space.dart';
import '../../domain/usecases/leave_space.dart';
import '../../domain/usecases/list_spaces.dart';
import '../../data/repositories/spaces_repository.dart';

class SpacesController extends ChangeNotifier {
  SpacesController({
    required this.authRepo,
    required this.listSpaces,
    required this.createSpace,
    required this.joinSpace,
    required this.leaveSpace,
    required this.spacesRepo,
  });

  final AuthRepository authRepo;
  final ListSpaces listSpaces;
  final CreateSpace createSpace;
  final JoinSpace joinSpace;
  final LeaveSpace leaveSpace;
  final SpacesRepository spacesRepo;

  bool isLoading = false;
  String? error;
  List<Space> spaces = [];

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      spaces = await listSpaces();
    } catch (e) {
      Logger.e('Load spaces failed', error: e);
      error = 'Failed to load spaces';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<Space?> create({
    required String name,
    String? description,
    String? city,
  }) async {
    final me = authRepo.currentUser;
    if (me == null) {
      error = 'You must be signed in';
      notifyListeners();
      return null;
    }
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final created = await createSpace(
        name: name,
        description: description,
        city: city,
        ownerId: me.id,
      );
      spaces = [created, ...spaces];
      return created;
    } catch (e) {
      Logger.e('Create space failed', error: e);
      error = 'Failed to create space';
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleMembership(Space space, bool isMember) async {
    final me = authRepo.currentUser;
    if (me == null) return;
    try {
      if (isMember) {
        await leaveSpace(space.id, me.id);
      } else {
        await joinSpace(space.id, me.id);
      }
    } catch (e) {
      Logger.e('Membership update failed', error: e);
    }
  }

  Future<bool> isMember(String spaceId) async {
    final me = authRepo.currentUser;
    if (me == null) return false;
    return spacesRepo.isMember(spaceId, me.id);
  }
}
