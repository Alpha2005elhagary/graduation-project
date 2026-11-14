import 'package:breakbot/core/di/injection_container.dart';
import 'package:breakbot/core/localisation/app_strings.dart';
import 'package:breakbot/core/storage/local_storage_manager.dart';
import 'package:breakbot/core/theme/app_theme.dart';
import 'package:breakbot/features/analytics/presentation/views/analytics_screen.dart';
import 'package:breakbot/features/coach/presentation/views/coach_screen.dart';
import 'package:breakbot/features/habits/presentation/views/habits_screen.dart';
import 'package:breakbot/features/home/presentation/views/home_screen.dart';
import 'package:breakbot/features/notifications/presentation/views/notifications_screen.dart';
import 'package:breakbot/features/profile/presentation/views/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression guard for narrow Android phones: every tab must lay out without
/// a RenderFlex overflow at 360x800 logical pixels.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await configureDependencies();
    await getIt<LocalStorageManager>().seedDemoDataIfEmpty();
    AppLocale.setLanguage('ar');
  });

  Widget host(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme(languageCode: 'ar'),
      locale: const Locale('ar'),
      supportedLocales: AppLocale.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    );
  }

  final screens = <String, Widget>{
    'home': HomeScreen(onNavigateTab: (_) {}),
    'habits': const HabitsScreen(),
    'coach': const CoachScreen(),
    'analytics': const AnalyticsScreen(),
    'profile': const ProfileScreen(),
    'notifications': const NotificationsScreen(),
  };

  for (final entry in screens.entries) {
    testWidgets('${entry.key} fits 360x800', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(host(entry.value));
      await tester.pump(const Duration(milliseconds: 900));

      expect(tester.takeException(), isNull);
    });
  }
}
