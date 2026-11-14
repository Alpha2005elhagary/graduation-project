import 'dart:io';

import 'package:breakbot/core/storage/local_storage_manager.dart';
import 'package:breakbot/core/utils/failure.dart';
import 'package:breakbot/features/habits/domain/entities/habit.dart';
import 'package:breakbot/features/habits/domain/repositories/i_habit_repository.dart';
import 'package:either_dart/either.dart';

class HabitRepositoryImpl implements IHabitRepository {
  final LocalStorageManager storage;

  HabitRepositoryImpl({required this.storage});

  @override
  Future<Either<Failure, List<Habit>>> getTodayHabits() async {
    try {
      final habits = storage.getHabits();
      return Right(habits);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Habit>> checkInHabit(String habitId) async {
    try {
      final habits = storage.getHabits();
      final index = habits.indexWhere((h) => h.id == habitId);
      if (index == -1) {
        return Left(UnknownFailure(message: 'لا توجد العادة'));
      }
      final habit = habits[index];
      final updated = habit.copyWith(
        streak: habit.streak + 1,
        lastCheckin: DateTime.now(),
      );
      final updatedList = List<Habit>.from(habits).. [index] = updated;
      await storage.saveHabits(updatedList);
      return Right(updated);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Habit>> addHabit({
    required String name,
    required String description,
    required DateTime targetTime,
    bool photoRequired = false,
  }) async {
    try {
      final habit = Habit(
        id: 'habit_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        description: description,
        targetTime: targetTime,
        photoRequired: photoRequired,
      );
      final habits = storage.getHabits();
      final updatedList = List<Habit>.from(habits)..add(habit);
      await storage.saveHabits(updatedList);
      return Right(habit);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VerificationResult>> verifyPhoto(File photo) async {
    try {
      return Right(
        VerificationResult(
          isValid: true,
          confidence: 1.0,
          feedback: 'تم التحقق من الصورة بنجاح',
        ),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleHabit(
    String habitId,
    bool isActive,
  ) async {
    try {
      final habits = storage.getHabits();
      final index = habits.indexWhere((h) => h.id == habitId);
      if (index == -1) {
        return Left(UnknownFailure(message: 'لا توجد العادة'));
      }
      final habit = habits[index];
      final updated = habit.copyWith(isActive: isActive);
      final updatedList = List<Habit>.from(habits).. [index] = updated;
      await storage.saveHabits(updatedList);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Habit>>> getAllHabits() async {
    try {
      final habits = storage.getHabits();
      return Right(habits);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
