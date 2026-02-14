import '../../domain/entities/user_profile.dart';

enum AuthStatus { idle, loading, authenticated, unauthenticated, error }

class AuthState {
  const AuthState({
    required this.status,
    this.profile,
    this.errorMessage,
  });

  final AuthStatus status;
  final UserProfile? profile;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? profile,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }

  static const AuthState idle = AuthState(status: AuthStatus.idle);
}
