import 'package:breakbot/core/storage/local_storage_manager.dart';
import 'package:breakbot/core/utils/failure.dart';
import 'package:breakbot/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:breakbot/shared/models/user.dart';
import 'package:either_dart/either.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final LocalStorageManager storage;

  AuthRepositoryImpl({required this.storage});

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      // Local auth - create user locally
      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: email.split('@').first,
        email: email,
      );
      await storage.saveUser(user);
      await storage.saveAuthToken('local_token_${user.id}');
      await storage.setAuthenticated(true);
      return Right(user);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
      );
      await storage.saveUser(user);
      await storage.saveAuthToken('local_token_${user.id}');
      await storage.setAuthenticated(true);
      return Right(user);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> fingerprintLogin() async {
    try {
      final user = storage.getUser();
      if (user == null) {
        return Left(UnknownFailure(message: 'لا يوجد مستخدم محفوظ'));
      }
      return Right(user);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await storage.clearAuth();
      return const Right(null);
    } catch (_) {
      await storage.clearAuth();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = storage.getUser();
      return Right(user);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setFingerprintEnabled(bool enabled) async {
    try {
      await storage.setFingerprintEnabled(enabled);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isFingerprintEnabled() async {
    try {
      final enabled = storage.isFingerprintEnabled();
      return Right(enabled);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
