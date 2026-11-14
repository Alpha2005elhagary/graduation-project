import 'package:breakbot/core/di/injection_container.dart';
import 'package:breakbot/core/storage/local_storage_manager.dart';



import 'package:breakbot/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:breakbot/features/habits/domain/repositories/i_habit_repository.dart';
import 'package:breakbot/features/habits/domain/usecases/habit_usecases.dart';
import 'package:breakbot/features/habits/presentation/viewmodels/habits_viewmodel.dart';

void configureHabitsDependencies() {
  getIt.registerLazySingleton<IHabitRepository>(
    () => HabitRepositoryImpl(
      storage: getIt<LocalStorageManager>(),
    ),
  );
  getIt.registerLazySingleton<GetTodayHabitsUseCase>(
    () => GetTodayHabitsUseCase(getIt<IHabitRepository>()),
  );
  getIt.registerLazySingleton<CheckInHabitUseCase>(
    () => CheckInHabitUseCase(getIt<IHabitRepository>()),
  );
  getIt.registerLazySingleton<AddHabitUseCase>(
    () => AddHabitUseCase(getIt<IHabitRepository>()),
  );
  getIt.registerLazySingleton<VerifyHabitPhotoUseCase>(
    () => VerifyHabitPhotoUseCase(getIt<IHabitRepository>()),
  );
  getIt.registerLazySingleton<ToggleHabitUseCase>(
    () => ToggleHabitUseCase(getIt<IHabitRepository>()),
  );
  getIt.registerLazySingleton<GetAllHabitsUseCase>(
    () => GetAllHabitsUseCase(getIt<IHabitRepository>()),
  );
  getIt.registerLazySingleton<HabitsViewModel>(
    () => HabitsViewModel(
      getTodayHabitsUseCase: getIt<GetTodayHabitsUseCase>(),
      checkInHabitUseCase: getIt<CheckInHabitUseCase>(),
      addHabitUseCase: getIt<AddHabitUseCase>(),
      verifyHabitPhotoUseCase: getIt<VerifyHabitPhotoUseCase>(),
      toggleHabitUseCase: getIt<ToggleHabitUseCase>(),
      getAllHabitsUseCase: getIt<GetAllHabitsUseCase>(),
    ),
  );
}