import 'package:breakbot/core/storage/local_storage_manager.dart';
import 'package:breakbot/core/utils/failure.dart';
import 'package:breakbot/features/coach/domain/repositories/i_coach_repository.dart';
import 'package:either_dart/either.dart';

class CoachRepositoryImpl implements ICoachRepository {
  final LocalStorageManager storage;

  CoachRepositoryImpl({required this.storage});

  @override
  Future<Either<Failure, String>> sendMessage(String message) async {
    try {
      final response = 'لقد استلمت رسالتك: "$message". كيف يمكنني مساعدتك أكثر؟';
      return Right(response);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMoodCraving() async {
    try {
      return Right({
        'mood': 5,
        'craving': 3,
        'message': 'كيف تشعر الآن؟',
      });
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getRelapseRisk() async {
    try {
      return Right(0.0);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
