class AppConstants {
  AppConstants._();

  static const String appName = 'BreakBot';
  static const String appVersion = '1.0.0';

  static String get apiBaseUrl => const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://api.breakbot.local/api/v1',
      );

  static const Duration defaultTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;

  // Habit check-in
  static const int relapseRiskThresholdPercent = 70;

  // Focus
  static const int defaultPomodoroMinutes = 25;
  static const int defaultShortBreakMinutes = 5;
  static const int defaultLongBreakMinutes = 15;
}
