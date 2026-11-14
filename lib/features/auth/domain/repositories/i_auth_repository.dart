import 'package:breakbot/core/utils/failure.dart';
import 'package:breakbot/shared/models/user.dart';
import 'package:either_dart/either.dart';

abstract class IAuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> fingerprintLogin();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, void>> setFingerprintEnabled(bool enabled);
  Future<Either<Failure, bool>> isFingerprintEnabled();
}