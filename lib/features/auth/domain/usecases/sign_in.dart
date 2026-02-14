import '../../data/repositories/auth_repository.dart';

class SignIn {
  SignIn(this.repo);

  final AuthRepository repo;

  Future<void> call(String email, String password) {
    return repo.signIn(email, password);
  }
}
