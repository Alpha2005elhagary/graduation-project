import 'package:breakbot/core/utils/failure.dart';
import 'package:breakbot/features/focus/domain/entities/focus_session.dart';
import 'package:breakbot/features/focus/domain/repositories/i_focus_repository.dart';
import 'package:either_dart/either.dart';

class StartFocusSessionUseCase {
  final IFocusRepository repository;
  StartFocusSessionUseCase(this.repository);
  Future<Either<Failure, void>> call(int minutes) =>
      repository.startSession(minutes);
}

class StopFocusSessionUseCase {
  final IFocusRepository repository;
  StopFocusSessionUseCase(this.repository);
  Future<Either<Failure, void>> call() => repository.stopSession();
}

class GetFocusSessionHistoryUseCase {
  final IFocusRepository repository;
  GetFocusSessionHistoryUseCase(this.repository);
  Future<Either<Failure, List<FocusSession>>> call() =>
      repository.getSessionHistory();
}