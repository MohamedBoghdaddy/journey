import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

/// Provides authentication methods using Supabase.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final SupabaseClient _client = SupabaseService.client;

  /// Registers a new user with email, password and name.
  Future<void> register(String email, String password, String name) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    final session = response.session;
    if (session == null) {
      throw Exception('Registration failed');
    }
  }

  /// Logs in a user with email and password.
  Future<void> login(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final session = response.session;
    if (session == null) {
      throw Exception('Invalid email or password');
    }
  }

  /// Logs out the current user.
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  /// Returns the currently signed-in user or null if not signed in.
  UserModel? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['name'] ?? '',
      isAdmin: user.appMetadata?['is_admin'] ?? false,
    );
  }
}