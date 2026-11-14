import 'package:breakbot/core/utils/failure.dart';
import 'package:breakbot/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:breakbot/shared/models/user.dart';
import 'package:either_dart/either.dart';

class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, User>> call(String email, String password) {
    return repository.login(email, password);
  }
}

class RegisterUseCase {
  final IAuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String name,
    required String email,
    required String password,
  }) {
    return repository.register(
      name: name,
      email: email,
      password: password,
    );
  }
}

class LogoutUseCase {
  final IAuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}

class FingerprintLoginUseCase {
  final IAuthRepository repository;

  FingerprintLoginUseCase(this.repository);

  Future<Either<Failure, User>> call() {
    return repository.fingerprintLogin();
  }
}