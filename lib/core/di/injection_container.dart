import 'package:get_it/get_it.dart';

import 'package:breakbot/core/storage/local_storage_manager.dart';
import 'package:breakbot/features/auth/data/repositories/auth_module.dart';
import 'package:breakbot/features/habits/data/repositories/habits_module.dart';
import 'package:breakbot/features/tasks/data/repositories/tasks_module.dart';
import 'package:breakbot/features/focus/data/repositories/focus_module.dart';
import 'package:breakbot/features/coach/data/repositories/coach_module.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Core - Local Storage
  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<LocalStorageManager>(() => LocalStorageManager(prefs));

  // Feature dependencies
  configureAuthDependencies();
  configureHabitsDependencies();
  configureTasksDependencies();
  configureFocusDependencies();
  configureCoachDependencies();
}
