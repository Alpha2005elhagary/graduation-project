import 'package:breakbot/core/utils/failure.dart';
import 'package:either_dart/either.dart';

abstract class ICoachRepository {
  Future<Either<Failure, String>> sendMessage(String message);
  Future<Either<Failure, Map<String, dynamic>>> getMoodCraving();
  Future<Either<Failure, double>> getRelapseRisk();
}