import 'package:flutter/foundation.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/usecases/get_me.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/update_profile.dart';
import '../state/auth_state.dart';
import '../../domain/entities/user_profile.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required SignIn signIn,
    required SignUp signUp,
    required SignOut signOut,
    required GetMe getMe,
    required UpdateProfile updateProfile,
  })  : _signIn = signIn,
        _signUp = signUp,
        _signOut = signOut,
        _getMe = getMe,
        _updateProfile = updateProfile;

  final SignIn _signIn;
  final SignUp _signUp;
  final SignOut _signOut;
  final GetMe _getMe;
  final UpdateProfile _updateProfile;

  AuthState _state = AuthState.idle;
  AuthState get state => _state;

  Future<void> bootstrap() async {
    _state = _state.copyWith(status: AuthStatus.loading, errorMessage: null);
    notifyListeners();
    try {
      final me = await _getMe();
      if (me == null) {
        _state = _state.copyWith(status: AuthStatus.unauthenticated);
      } else {
        _state = _state.copyWith(status: AuthStatus.authenticated, profile: me);
      }
    } catch (e) {
      Logger.e('Auth bootstrap failed', error: e);
      _state = _state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to load session',
      );
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _state = _state.copyWith(status: AuthStatus.loading, errorMessage: null);
    notifyListeners();
    try {
      await _signIn(email, password);
      final me = await _getMe();
      _state = _state.copyWith(
        status: AuthStatus.authenticated,
        profile: me,
      );
    } catch (e) {
      Logger.e('Sign in failed', error: e);
      _state = _state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Sign in failed',
      );
    }
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    _state = _state.copyWith(status: AuthStatus.loading, errorMessage: null);
    notifyListeners();
    try {
      await _signUp(email, password);
      final me = await _getMe();
      _state = _state.copyWith(
        status: AuthStatus.authenticated,
        profile: me,
      );
    } catch (e) {
      Logger.e('Sign up failed', error: e);
      _state = _state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Sign up failed',
      );
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    _state = _state.copyWith(status: AuthStatus.loading, errorMessage: null);
    notifyListeners();
    try {
      await _signOut();
      _state = _state.copyWith(status: AuthStatus.unauthenticated, profile: null);
    } catch (e) {
      Logger.e('Sign out failed', error: e);
      _state = _state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Sign out failed',
      );
    }
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile updated) async {
    try {
      final saved = await _updateProfile(updated);
      if (saved != null) {
        _state = _state.copyWith(profile: saved);
        notifyListeners();
      }
    } catch (e) {
      Logger.e('Update profile failed', error: e);
    }
  }
}
