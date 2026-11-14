class ApiEndpoints {
  ApiEndpoints._();

  static const String register = '/auth/register/';
  static const String login = '/auth/login/';
  static const String refresh = '/auth/token/refresh/';
  static const String logout = '/auth/logout/';
  static const String me = '/users/me/';

  // Habits
  static const String habitsToday = '/habits/today/';
  static const String habits = '/habits/';
  static String habitDetail(String id) => '/habits/$id/';
  static const String habitCheckin = '/habits/checkin/';
  static const String habitVerifyPhoto = '/habits/verify/';

  // Tasks
  static const String tasks = '/tasks/';
  static String taskDetail(String id) => '/tasks/$id/';
  static const String suggestSlot = '/tasks/suggest-slot/';

  // Focus
  static const String focusSessions = '/focus/sessions/';

  // Coach
  static const String coachChat = '/coach/chat/';
  static const String coachMood = '/coach/mood/';

  // Analytics
  static const String analyticsStreaks = '/analytics/streaks/';
  static const String analyticsTriggers = '/analytics/triggers/';
  static const String analyticsWeekly = '/analytics/weekly/';

  // Gamification
  static const String gamificationXp = '/gamification/xp/';
  static const String gamificationBadges = '/gamification/badges/';
  static const String gamificationLeaderboard = '/gamification/leaderboard/';
  static const String gamificationChallenges = '/gamification/challenges/';

  // Notifications
  static const String notifications = '/notifications/';
}
