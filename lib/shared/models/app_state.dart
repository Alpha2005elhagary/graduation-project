import 'package:breakbot/shared/models/user.dart';

class AppState {
  final User? user;
  final bool isAuthenticated;
  final bool isOnboardingCompleted;

  const AppState({
    this.user,
    this.isAuthenticated = false,
    this.isOnboardingCompleted = false,
  });

  AppState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isOnboardingCompleted,
  }) {
    return AppState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
    );
  }
}
