import 'package:breakbot/core/di/injection_container.dart';
import 'package:breakbot/core/storage/local_storage_manager.dart';



import 'package:breakbot/features/focus/data/repositories/focus_repository_impl.dart';
import 'package:breakbot/features/focus/domain/repositories/i_focus_repository.dart';
import 'package:breakbot/features/focus/domain/usecases/focus_usecases.dart';
import 'package:breakbot/features/focus/presentation/viewmodels/focus_viewmodel.dart';

void configureFocusDependencies() {
  getIt.registerLazySingleton<IFocusRepository>(
    () => FocusRepositoryImpl(storage: getIt<LocalStorageManager>()),
  );
  getIt.registerLazySingleton<StartFocusSessionUseCase>(
    () => StartFocusSessionUseCase(getIt<IFocusRepository>()),
  );
  getIt.registerLazySingleton<StopFocusSessionUseCase>(
    () => StopFocusSessionUseCase(getIt<IFocusRepository>()),
  );
  getIt.registerLazySingleton<GetFocusSessionHistoryUseCase>(
    () => GetFocusSessionHistoryUseCase(getIt<IFocusRepository>()),
  );
  getIt.registerLazySingleton<FocusViewModel>(
    () => FocusViewModel(
      startFocusSessionUseCase: getIt<StartFocusSessionUseCase>(),
      stopFocusSessionUseCase: getIt<StopFocusSessionUseCase>(),
      getFocusSessionHistoryUseCase: getIt<GetFocusSessionHistoryUseCase>(),
    ),
  );
}