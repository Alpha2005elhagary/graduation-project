import 'package:breakbot/core/utils/failure.dart';
import 'package:breakbot/features/focus/domain/entities/focus_session.dart';
import 'package:either_dart/either.dart';

abstract class IFocusRepository {
  Future<Either<Failure, void>> startSession(int minutes);
  Future<Either<Failure, void>> stopSession();
  Future<Either<Failure, List<FocusSession>>> getSessionHistory();
}