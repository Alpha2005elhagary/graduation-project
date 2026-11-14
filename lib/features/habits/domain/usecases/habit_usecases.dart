import 'dart:io';
import 'package:breakbot/core/utils/failure.dart';
import 'package:breakbot/features/habits/domain/entities/habit.dart';
import 'package:breakbot/features/habits/domain/repositories/i_habit_repository.dart';
import 'package:either_dart/either.dart';

class GetTodayHabitsUseCase {
  final IHabitRepository repository;
  GetTodayHabitsUseCase(this.repository);
  Future<Either<Failure, List<Habit>>> call() => repository.getTodayHabits();
}

class CheckInHabitUseCase {
  final IHabitRepository repository;
  CheckInHabitUseCase(this.repository);
  Future<Either<Failure, Habit>> call(String habitId) =>
      repository.checkInHabit(habitId);
}

class AddHabitUseCase {
  final IHabitRepository repository;
  AddHabitUseCase(this.repository);
  Future<Either<Failure, Habit>> call({
    required String name,
    required String description,
    required DateTime targetTime,
    bool photoRequired = false,
  }) => repository.addHabit(
        name: name,
        description: description,
        targetTime: targetTime,
        photoRequired: photoRequired,
      );
}

class VerifyHabitPhotoUseCase {
  final IHabitRepository repository;
  VerifyHabitPhotoUseCase(this.repository);
  Future<Either<Failure, VerificationResult>> call(File photo) =>
      repository.verifyPhoto(photo);
}

class ToggleHabitUseCase {
  final IHabitRepository repository;
  ToggleHabitUseCase(this.repository);
  Future<Either<Failure, void>> call(String habitId, bool isActive) =>
      repository.toggleHabit(habitId, isActive);
}

class GetAllHabitsUseCase {
  final IHabitRepository repository;
  GetAllHabitsUseCase(this.repository);
  Future<Either<Failure, List<Habit>>> call() => repository.getAllHabits();
}