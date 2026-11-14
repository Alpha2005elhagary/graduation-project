import 'dart:io';
import 'package:breakbot/core/utils/failure.dart';
import 'package:breakbot/features/habits/domain/entities/habit.dart';
import 'package:either_dart/either.dart';

abstract class IHabitRepository {
  Future<Either<Failure, List<Habit>>> getTodayHabits();
  Future<Either<Failure, Habit>> checkInHabit(String habitId);
  Future<Either<Failure, Habit>> addHabit({
    required String name,
    required String description,
    required DateTime targetTime,
    bool photoRequired,
  });
  Future<Either<Failure, VerificationResult>> verifyPhoto(File photo);
  Future<Either<Failure, void>> toggleHabit(String habitId, bool isActive);
  Future<Either<Failure, List<Habit>>> getAllHabits();
}