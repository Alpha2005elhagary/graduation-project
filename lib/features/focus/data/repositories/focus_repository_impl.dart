import 'package:breakbot/core/storage/local_storage_manager.dart';
import 'package:breakbot/core/utils/failure.dart';
import 'package:breakbot/features/focus/domain/entities/focus_session.dart';
import 'package:breakbot/features/focus/domain/repositories/i_focus_repository.dart';
import 'package:either_dart/either.dart';

class FocusRepositoryImpl implements IFocusRepository {
  final LocalStorageManager storage;

  FocusRepositoryImpl({required this.storage});

  @override
  Future<Either<Failure, void>> startSession(int minutes) async {
    try {
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> stopSession() async {
    try {
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FocusSession>>> getSessionHistory() async {
    try {
      final sessions = storage.getFocusSessions();
      return Right(sessions);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
