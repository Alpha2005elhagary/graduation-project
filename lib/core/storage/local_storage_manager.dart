import 'dart:convert';

import 'package:breakbot/shared/models/user.dart';
import 'package:breakbot/features/habits/domain/entities/habit.dart';
import 'package:breakbot/features/tasks/domain/entities/task.dart';
import 'package:breakbot/features/focus/domain/entities/focus_session.dart';
import 'package:breakbot/features/coach/domain/entities/coach_message.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageManager {
  static const String _userKey = 'user';
  static const String _habitsKey = 'habits';
  static const String _tasksKey = 'tasks';
  static const String _focusSessionsKey = 'focus_sessions';
  static const String _coachMessagesKey = 'coach_messages';
  static const String _isAuthenticatedKey = 'is_authenticated';
  static const String _fingerprintEnabledKey = 'fingerprint_enabled';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _languageKey = 'app_language';

  late final SharedPreferences _prefs;

  LocalStorageManager(this._prefs);

  /// Bumped whenever persisted data changes so screens can refresh.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  void _touch() {
    revision.value = revision.value + 1;
  }

  // User
  Future<void> saveUser(User user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
    _touch();
  }

  User? getUser() {
    final data = _prefs.getString(_userKey);
    if (data == null) return null;
    return User.fromJson(jsonDecode(data));
  }

  Future<void> saveAuthToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  String? getAuthToken() {
    return _prefs.getString('auth_token');
  }

  Future<void> clearAuth() async {
    await _prefs.remove(_userKey);
    await _prefs.remove('auth_token');
    await _prefs.remove(_isAuthenticatedKey);
    _touch();
  }

  bool get isAuthenticated {
    return _prefs.getBool(_isAuthenticatedKey) ?? false;
  }

  Future<void> setAuthenticated(bool value) async {
    await _prefs.setBool(_isAuthenticatedKey, value);
    _touch();
  }

  // Habits
  Future<void> saveHabits(List<Habit> habits) async {
    final list = habits.map((h) => h.toJson()).toList();
    await _prefs.setString(_habitsKey, jsonEncode(list));
    _touch();
  }

  List<Habit> getHabits() {
    final data = _prefs.getString(_habitsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Habit.fromJson(e)).toList();
  }

  // Tasks
  Future<void> saveTasks(List<Task> tasks) async {
    final list = tasks.map((t) => t.toJson()).toList();
    await _prefs.setString(_tasksKey, jsonEncode(list));
  }

  List<Task> getTasks() {
    final data = _prefs.getString(_tasksKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Task.fromJson(e)).toList();
  }

  // Focus Sessions
  Future<void> saveFocusSessions(List<FocusSession> sessions) async {
    final list = sessions.map((s) => s.toJson()).toList();
    await _prefs.setString(_focusSessionsKey, jsonEncode(list));
  }

  List<FocusSession> getFocusSessions() {
    final data = _prefs.getString(_focusSessionsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => FocusSession.fromJson(e)).toList();
  }

  // Coach Messages
  Future<void> saveCoachMessages(List<CoachMessage> messages) async {
    final list = messages.map((m) => m.toJson()).toList();
    await _prefs.setString(_coachMessagesKey, jsonEncode(list));
  }

  List<CoachMessage> getCoachMessages() {
    final data = _prefs.getString(_coachMessagesKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => CoachMessage.fromJson(e)).toList();
  }

  // Fingerprint
  Future<void> setFingerprintEnabled(bool enabled) async {
    await _prefs.setBool(_fingerprintEnabledKey, enabled);
  }

  bool isFingerprintEnabled() {
    return _prefs.getBool(_fingerprintEnabledKey) ?? false;
  }

  // Onboarding
  bool get isOnboardingCompleted {
    return _prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool(_onboardingCompletedKey, value);
  }

  // Language
  String getLanguage() {
    return _prefs.getString(_languageKey) ?? 'ar';
  }

  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(
      _languageKey,
      languageCode == 'en' ? 'en' : 'ar',
    );
    _touch();
  }

  // Demo data
  /// Seeds a small, realistic set of protocols the first time the app runs so
  /// the dashboard, coach and analytics screens have something to show.
  Future<void> seedDemoDataIfEmpty() async {
    if (getHabits().isNotEmpty) return;
    final now = DateTime.now();
    DateTime at(int hour, int minute) =>
        DateTime(now.year, now.month, now.day, hour, minute);
    DateTime? doneToday(int index, int doneCount) {
      // 4 of the 6 seeded habits are already complete today, matching the
      // 67% daily overview in the design reference.
      return index < doneCount ? now : null;
    }

    final habits = <Habit>[
      Habit(
        id: 'demo_morning_walk',
        name: 'مشي الصباح والترطيب',
        description: 'اشرب 500 مل ماء + 5 دقائق شمس',
        targetTime: at(7, 30),
        streak: 14,
        lastCheckin: doneToday(0, 4),
        createdAt: now,
      ),
      Habit(
        id: 'demo_sugar_delay',
        name: 'تأخير الرغبة في السكر',
        description: 'تمرين تأخير 5 دقائق + شاي أعشاب',
        targetTime: at(20, 0),
        streak: 9,
        lastCheckin: null,
        createdAt: now,
      ),
      Habit(
        id: 'demo_breathwork',
        name: 'تنفس عميق مسائي',
        description: 'إعادة ضبط الجهاز العصبي · 10 دقائق',
        targetTime: at(20, 30),
        streak: 7,
        lastCheckin: doneToday(2, 4),
        createdAt: now,
      ),
      Habit(
        id: 'demo_screen_break',
        name: 'وقفة شاشة 20-20-20',
        description: 'كل 90 دقيقة · راحة عين وتمدد',
        targetTime: at(13, 0),
        streak: 11,
        lastCheckin: doneToday(1, 4),
        createdAt: now,
      ),
      Habit(
        id: 'demo_sunlight',
        name: 'تعرض لأشعة الشمس',
        description: '13 دقيقة قبل الظهر',
        targetTime: at(11, 0),
        streak: 5,
        lastCheckin: doneToday(3, 4),
        createdAt: now,
      ),
      Habit(
        id: 'demo_journal',
        name: 'تدوين الامتنان',
        description: 'اكتب 3 أشياء أنت ممتن لها',
        targetTime: at(22, 0),
        streak: 4,
        lastCheckin: doneToday(4, 4),
        createdAt: now,
      ),
    ];
    await saveHabits(habits);
  }
}
