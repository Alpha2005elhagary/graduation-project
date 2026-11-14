import 'package:breakbot/core/utils/failure.dart';
import 'package:breakbot/features/habits/domain/entities/habit.dart';
import 'package:breakbot/features/habits/domain/usecases/habit_usecases.dart';
import 'package:breakbot/shared/models/base_viewmodel.dart';
import 'package:either_dart/either.dart';
import 'dart:io';

class HabitsViewModel extends BaseViewModel {
  final GetTodayHabitsUseCase getTodayHabitsUseCase;
  final CheckInHabitUseCase checkInHabitUseCase;
  final AddHabitUseCase addHabitUseCase;
  final VerifyHabitPhotoUseCase verifyHabitPhotoUseCase;
  final ToggleHabitUseCase toggleHabitUseCase;
  final GetAllHabitsUseCase getAllHabitsUseCase;

  HabitsViewModel({
    required this.getTodayHabitsUseCase,
    required this.checkInHabitUseCase,
    required this.addHabitUseCase,
    required this.verifyHabitPhotoUseCase,
    required this.toggleHabitUseCase,
    required this.getAllHabitsUseCase,
  });

  List<Habit> _todayHabits = [];
  List<Habit> get todayHabits => _todayHabits;

  Future<void> loadTodayHabits() async {
    setLoading(true);
    clearError();
    final result = await getTodayHabitsUseCase();
    result.fold(
      (failure) => setError(failure.toUserMessage()),
      (habits) => _todayHabits = habits,
    );
    setLoading(false);
  }

  Future<void> checkIn(String habitId) async {
    setLoading(true);
    clearError();
    final result = await checkInHabitUseCase(habitId);
    result.fold(
      (failure) => setError(failure.toUserMessage()),
      (habit) {
        _todayHabits = _todayHabits.map((h) {
          if (h.id == habitId) {
            return h.copyWith(streak: habit.streak);
          }
          return h;
        }).toList();
      },
    );
    setLoading(false);
  }

  Future<void> addHabit({
    required String name,
    required String description,
    required DateTime targetTime,
    bool photoRequired = false,
  }) async {
    setLoading(true);
    clearError();
    final result = await addHabitUseCase(
      name: name,
      description: description,
      targetTime: targetTime,
      photoRequired: photoRequired,
    );
    result.fold(
      (failure) => setError(failure.toUserMessage()),
      (habit) => _todayHabits.add(habit),
    );
    setLoading(false);
  }

  Future<Either<Failure, VerificationResult>> verifyPhoto(File photo) async {
    setLoading(true);
    clearError();
    final result = await verifyHabitPhotoUseCase(photo);
    setLoading(false);
    return result;
  }

  Future<void> toggleHabit(String habitId, bool isActive) async {
    setLoading(true);
    clearError();
    final result = await toggleHabitUseCase(habitId, isActive);
    result.fold(
      (failure) => setError(failure.toUserMessage()),
      (_) {
        _todayHabits = _todayHabits.map((h) {
          if (h.id == habitId) {
            return h.copyWith(isActive: isActive);
          }
          return h;
        }).toList();
      },
    );
    setLoading(false);
  }
}
