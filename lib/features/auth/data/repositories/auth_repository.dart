import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/user_profile.dart';
import '../datasources/auth_remote_ds.dart';

class AuthRepository {
  AuthRepository({required this.authRemote});

  final AuthRemoteDs authRemote;

  User? get currentUser => authRemote.currentUser;

  Future<void> signIn(String email, String password) async {
    await authRemote.signIn(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
    await authRemote.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await authRemote.signOut();
  }

  UserProfile requireSignedIn() {
    final u = currentUser;
    if (u == null) throw const AuthException('Not signed in');
    return UserProfile(id: u.id, email: u.email ?? '');
  }
}
