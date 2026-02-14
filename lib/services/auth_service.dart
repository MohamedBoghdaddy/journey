import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import 'supabase_service.dart';

/// AuthService (merged)
/// - Works with injected client OR defaults to SupabaseService.client
/// - Exposes onAuthStateChange stream
/// - Supports:
///   - register(name,email,password) -> RegisterResult (handles email confirmation)
///   - signUp(email,password) legacy helper (calls register with name fallback)
///   - login(email,password) -> UserModel (cached)
///   - logout()
///   - resendConfirmation(email)
/// - Caches currentUser as UserModel and refreshes it best-effort:
///   1) Try profiles table: id,email,role,community_reputation,reputation,name
///   2) Fallback to auth metadata (user.userMetadata)
class AuthService {
  AuthService({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  static final AuthService instance = AuthService();

  final SupabaseClient _client;

  UserModel? _currentUser;
  UserModel? get currentUser =>
      _currentUser ?? _mapSupabaseUser(_client.auth.currentUser);

  bool get isSignedIn => _client.auth.currentSession != null;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// Register with name (preferred flow for your app).
  /// Returns whether email confirmation is required (session null).
  Future<RegisterResult> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'name': name.trim(),
          'role': 'user',
          'reputation': 0,
          'community_reputation': 0,
        },
      );

      // With email confirmations ON, res.session is usually null.
      final needsEmailConfirmation = res.session == null;

      await refreshCachedProfileBestEffort(force: true, userOverride: res.user);

      final mapped = currentUser;
      if (mapped == null) {
        throw const AuthFailure('Signup failed: no user returned.');
      }

      return RegisterResult(
        user: mapped,
        needsEmailConfirmation: needsEmailConfirmation,
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure('Registration failed: $e');
    }
  }

  /// Legacy helper: sign up without name.
  /// Uses a safe default name, then refreshes cache.
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    final fallbackName = email.trim().split('@').first;
    await register(email: email, password: password, name: fallbackName);
  }

  /// Login and return the mapped user.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      await refreshCachedProfileBestEffort(force: true, userOverride: res.user);

      final mapped = currentUser;
      if (mapped == null) {
        throw const AuthFailure('Invalid email or password.');
      }
      return mapped;
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('confirm') || msg.contains('verified')) {
        throw const AuthFailure(
            'Please confirm your email first, then try again.');
      }
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure('Login failed: $e');
    }
  }

  Future<void> resendConfirmation(String email) async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email.trim(),
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure('Resend failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
      _currentUser = null;
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure('Logout failed: $e');
    }
  }

  /// Best-effort cache refresh:
  /// - tries `profiles` table (if present)
  /// - falls back to auth metadata
  Future<void> refreshCachedProfileBestEffort({
    bool force = false,
    User? userOverride,
  }) async {
    final user = userOverride ?? _client.auth.currentUser;
    if (user == null) {
      _currentUser = null;
      return;
    }

    if (!force && _currentUser != null && _currentUser!.id == user.id) return;

    // 1) Try profile row if your DB has one.
    try {
      final profile = await _client
          .from('profiles')
          .select('id,email,name,role,community_reputation,reputation')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null) {
        _currentUser = UserModel.fromMap(profile);
        return;
      }
    } catch (_) {
      // Ignore; fallback to metadata.
    }

    // 2) Fallback to auth metadata.
    _currentUser = _mapSupabaseUser(user);
  }

  UserModel? _mapSupabaseUser(User? user) {
    if (user == null) return null;

    final metadata = user.userMetadata ?? const <String, dynamic>{};

    final dynamic rep =
        metadata['community_reputation'] ?? metadata['reputation'] ?? 0;

    return UserModel.fromMap({
      'id': user.id,
      'email': user.email ?? '',
      'name': (metadata['name'] ?? '').toString(),
      'role': (metadata['role'] ?? 'user').toString(),
      'community_reputation': rep,
      'reputation': rep, // keep compatibility with older keys
    });
  }
}

class RegisterResult {
  const RegisterResult({
    required this.user,
    required this.needsEmailConfirmation,
  });

  final UserModel user;
  final bool needsEmailConfirmation;
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}
