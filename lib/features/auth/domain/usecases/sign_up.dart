import '../../data/repositories/auth_repository.dart';

class SignUp {
  SignUp(this.repo);

  final AuthRepository repo;

  Future<void> call(String email, String password) {
    return repo.signUp(email, password);
  }
}
