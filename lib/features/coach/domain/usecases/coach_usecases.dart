import 'package:breakbot/core/utils/failure.dart';
import 'package:breakbot/features/coach/domain/repositories/i_coach_repository.dart';
import 'package:either_dart/either.dart';

class SendCoachMessageUseCase {
  final ICoachRepository repository;
  SendCoachMessageUseCase(this.repository);
  Future<Either<Failure, String>> call(String message) =>
      repository.sendMessage(message);
}

class GetMoodCravingUseCase {
  final ICoachRepository repository;
  GetMoodCravingUseCase(this.repository);
  Future<Either<Failure, Map<String, dynamic>>> call() =>
      repository.getMoodCraving();
}

class GetRelapseRiskUseCase {
  final ICoachRepository repository;
  GetRelapseRiskUseCase(this.repository);
  Future<Either<Failure, double>> call() => repository.getRelapseRisk();
}