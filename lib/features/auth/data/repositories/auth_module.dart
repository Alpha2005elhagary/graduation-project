import 'package:breakbot/core/di/injection_container.dart';
import 'package:breakbot/core/storage/local_storage_manager.dart';



import 'package:breakbot/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:breakbot/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:breakbot/features/auth/domain/usecases/auth_usecases.dart';
import 'package:breakbot/features/auth/presentation/viewmodels/auth_viewmodels.dart';

void configureAuthDependencies() {
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      storage: getIt<LocalStorageManager>(),
    ),
  );
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerLazySingleton<FingerprintLoginUseCase>(
    () => FingerprintLoginUseCase(getIt<IAuthRepository>()),
  );
  getIt.registerLazySingleton<LoginViewModel>(
    () => LoginViewModel(
      loginUseCase: getIt<LoginUseCase>(),
      fingerprintLoginUseCase: getIt<FingerprintLoginUseCase>(),
    ),
  );
  getIt.registerLazySingleton<RegisterViewModel>(
    () => RegisterViewModel(
      registerUseCase: getIt<RegisterUseCase>(),
    ),
  );
}