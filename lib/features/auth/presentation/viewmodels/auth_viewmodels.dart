import 'package:breakbot/core/utils/failure.dart';
import 'package:breakbot/features/auth/domain/usecases/auth_usecases.dart';
import 'package:breakbot/shared/models/base_viewmodel.dart';

class LoginViewModel extends BaseViewModel {
  final LoginUseCase loginUseCase;
  final FingerprintLoginUseCase fingerprintLoginUseCase;

  LoginViewModel({
    required this.loginUseCase,
    required this.fingerprintLoginUseCase,
  });

  Future<void> login(String email, String password) async {
    setLoading(true);
    clearError();
    final result = await loginUseCase(email, password);
    result.fold(
      (failure) => setError(failure.toUserMessage()),
      (user) {
        // Navigation handled by listener
      },
    );
    setLoading(false);
  }

  Future<void> fingerprintLogin() async {
    setLoading(true);
    clearError();
    final result = await fingerprintLoginUseCase();
    result.fold(
      (failure) => setError(failure.toUserMessage()),
      (user) {},
    );
    setLoading(false);
  }
}

class RegisterViewModel extends BaseViewModel {
  final RegisterUseCase registerUseCase;

  RegisterViewModel({required this.registerUseCase});

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    setLoading(true);
    clearError();
    final result = await registerUseCase(
      name: name,
      email: email,
      password: password,
    );
    result.fold(
      (failure) => setError(failure.toUserMessage()),
      (user) {},
    );
    setLoading(false);
  }
}
