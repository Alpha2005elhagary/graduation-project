import 'package:breakbot/core/di/injection_container.dart';
import 'package:breakbot/core/storage/local_storage_manager.dart';


import 'package:breakbot/features/coach/data/repositories/coach_repository_impl.dart';
import 'package:breakbot/features/coach/domain/repositories/i_coach_repository.dart';
import 'package:breakbot/features/coach/domain/usecases/coach_usecases.dart';
import 'package:breakbot/features/coach/presentation/viewmodels/coach_viewmodel.dart';

void configureCoachDependencies() {
  getIt.registerLazySingleton<ICoachRepository>(
    () => CoachRepositoryImpl(storage: getIt<LocalStorageManager>()),
  );
  getIt.registerLazySingleton<SendCoachMessageUseCase>(
    () => SendCoachMessageUseCase(getIt<ICoachRepository>()),
  );
  getIt.registerLazySingleton<GetMoodCravingUseCase>(
    () => GetMoodCravingUseCase(getIt<ICoachRepository>()),
  );
  getIt.registerLazySingleton<GetRelapseRiskUseCase>(
    () => GetRelapseRiskUseCase(getIt<ICoachRepository>()),
  );
  getIt.registerLazySingleton<CoachViewModel>(
    () => CoachViewModel(
      sendCoachMessageUseCase: getIt<SendCoachMessageUseCase>(),
      getMoodCravingUseCase: getIt<GetMoodCravingUseCase>(),
      getRelapseRiskUseCase: getIt<GetRelapseRiskUseCase>(),
    ),
  );
}