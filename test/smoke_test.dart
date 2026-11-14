import 'package:breakbot/core/di/injection_container.dart';
import 'package:breakbot/core/localisation/app_strings.dart';
import 'package:breakbot/core/storage/local_storage_manager.dart';
import 'package:breakbot/core/theme/app_theme.dart';
import 'package:breakbot/features/analytics/presentation/views/analytics_screen.dart';
import 'package:breakbot/features/auth/presentation/views/auth_screens.dart';
import 'package:breakbot/features/coach/presentation/views/coach_screen.dart';
import 'package:breakbot/features/habits/presentation/views/habits_screen.dart';
import 'package:breakbot/features/home/presentation/views/home_screen.dart';
import 'package:breakbot/features/notifications/presentation/views/notifications_screen.dart';
import 'package:breakbot/features/onboarding/presentation/views/onboarding_screen.dart';
import 'package:breakbot/features/onboarding/presentation/views/splash_screen.dart';
import 'package:breakbot/features/profile/presentation/views/profile_screen.dart';
import 'package:breakbot/main.dart';
import 'package:breakbot/shared/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(languageCode: AppLocale.languageCode),
      locale: AppLocale.current,
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
    'splash': const SplashScreen(),
    'onboarding': OnboardingScreen(onComplete: () {}),
    'login': LoginScreen(onComplete: () {}, onToggle: () {}),
    'register': RegisterScreen(onComplete: () {}, onToggle: () {}),
  };

  for (final entry in screens.entries) {
    testWidgets('${entry.key} screen renders in Arabic', (tester) async {
      await tester.pumpWidget(host(entry.value));
      await tester.pump(const Duration(milliseconds: 900));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('English locale renders the dashboard LTR', (tester) async {
    AppLocale.setLanguage('en');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(languageCode: 'en'),
        locale: AppLocale.current,
        supportedLocales: AppLocale.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: HomeScreen(onNavigateTab: (_) {}),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Ready to dismantle friction and lock in healthy micro-breaks?'),
        findsWidgets);
    expect(Directionality.of(tester.element(find.byType(HomeScreen))),
        TextDirection.ltr);
    expect(tester.takeException(), isNull);

    AppLocale.setLanguage('ar');
  });

  testWidgets('shell enters home, opens profile and switches language live',
      (tester) async {
    final storage = getIt<LocalStorageManager>();
    await storage.setOnboardingCompleted(true);
    await storage.setAuthenticated(true);
    await storage.saveUser(
      const User(
        id: 'u_test',
        name: 'Alex',
        email: 'alex@breakbot.app',
      ),
    );

    await tester.pumpWidget(const BreakBotApp());
    // Splash timer + AnimatedSwitcher transition into the shell.
    await tester.pump(const Duration(milliseconds: 2700));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('Alex'), findsWidgets);
    expect(find.text('اليوم'), findsWidgets);

    await tester.tap(find.text('الملف').last);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('الإعدادات والملف'), findsWidgets);

    AppLocale.setLanguage('en');
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Settings & Profile'), findsWidgets);
    expect(
      Directionality.of(tester.element(find.text('Settings & Profile').first)),
      TextDirection.ltr,
    );
    expect(tester.takeException(), isNull);

    AppLocale.setLanguage('ar');
  });
}
