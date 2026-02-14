import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';

class AuthRemoteDs {
  AuthRemoteDs({required this.client});

  final SupabaseClient? client;

  User? get currentUser {
    final sb = client;
    if (sb == null) return null;
    return sb.auth.currentUser;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final sb = client;
    if (sb == null) {
      throw const NetworkException('Supabase not initialized.');
    }
    try {
      return await sb.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw AppAuthException(e.message, code: '${e.statusCode}', cause: e);
    } catch (e) {
      throw AppAuthException('Sign in failed', cause: e);
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    final sb = client;
    if (sb == null) {
      throw const NetworkException('Supabase not initialized.');
    }
    try {
      return await sb.auth.signUp(email: email, password: password);
    } on AuthException catch (e) {
      throw AppAuthException(e.message, code: '${e.statusCode}', cause: e);
    } catch (e) {
      throw AppAuthException('Sign up failed', cause: e);
    }
  }

  Future<void> signOut() async {
    final sb = client;
    if (sb == null) return;
    try {
      await sb.auth.signOut();
    } catch (e) {
      throw AppAuthException('Sign out failed', cause: e);
    }
  }
}
