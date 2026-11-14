import 'dart:async';

import 'package:breakbot/core/di/injection_container.dart';
import 'package:breakbot/core/localisation/app_strings.dart';
import 'package:breakbot/core/storage/local_storage_manager.dart';
import 'package:breakbot/core/theme/app_theme.dart';
import 'package:breakbot/features/analytics/presentation/views/analytics_screen.dart';
import 'package:breakbot/features/auth/presentation/views/auth_screens.dart';
import 'package:breakbot/features/coach/presentation/views/coach_screen.dart';
import 'package:breakbot/features/habits/presentation/views/habits_screen.dart';
import 'package:breakbot/features/home/presentation/views/home_screen.dart';
import 'package:breakbot/features/onboarding/presentation/views/onboarding_screen.dart';
import 'package:breakbot/features/onboarding/presentation/views/splash_screen.dart';
import 'package:breakbot/features/profile/presentation/views/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  final storage = getIt<LocalStorageManager>();
  AppLocale.setLanguage(storage.getLanguage());
  await storage.seedDemoDataIfEmpty();

  runApp(const BreakBotApp());
}

/// Root of the application.
///
/// The locale lives in [AppLocale.notifier]; rebuilding [MaterialApp] here
/// updates directionality, typography (Cairo vs. Plus Jakarta Sans) and every
/// localised string in one pass.
class BreakBotApp extends StatelessWidget {
  const BreakBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocale.notifier,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'BreakBot',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(languageCode: locale.languageCode),
          darkTheme: AppTheme.darkTheme(languageCode: locale.languageCode),
          themeMode: ThemeMode.light,
          locale: locale,
          supportedLocales: AppLocale.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const AppEntry(),
        );
      },
    );
  }
}

enum _EntryStage { splash, onboarding, auth, home }

/// Splash → onboarding → auth → shell, driven by persisted flags.
class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  final storage = getIt<LocalStorageManager>();

  _EntryStage _stage = _EntryStage.splash;
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(
      const Duration(milliseconds: 2600),
      _continueFromSplash,
    );
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  void _continueFromSplash() {
    if (!mounted || _stage != _EntryStage.splash) return;
    _splashTimer?.cancel();

    setState(() {
      if (!storage.isOnboardingCompleted) {
        _stage = _EntryStage.onboarding;
      } else if (storage.getUser() == null) {
        _stage = _EntryStage.auth;
      } else {
        _stage = _EntryStage.home;
      }
    });
  }

  Future<void> _finishOnboarding() async {
    await storage.setOnboardingCompleted(true);
    if (!mounted) return;
    setState(() {
      _stage = storage.getUser() == null ? _EntryStage.auth : _EntryStage.home;
    });
  }

  void _finishAuth() {
    if (!mounted) return;
    setState(() => _stage = _EntryStage.home);
  }

  Future<void> _logout() async {
    await storage.clearAuth();
    if (!mounted) return;
    setState(() => _stage = _EntryStage.auth);
  }

  Widget _stageChild() {
    switch (_stage) {
      case _EntryStage.splash:
        return SplashScreen(
          key: const ValueKey('splash'),
          onStart: _continueFromSplash,
        );
      case _EntryStage.onboarding:
        return OnboardingScreen(
          key: const ValueKey('onboarding'),
          onComplete: _finishOnboarding,
        );
      case _EntryStage.auth:
        return _AuthFlow(
          key: const ValueKey('auth'),
          onComplete: _finishAuth,
        );
      case _EntryStage.home:
        return BreakBotHome(
          key: const ValueKey('home'),
          onLogout: _logout,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _stageChild(),
    );
  }
}

/// Login ⇄ register toggle, kept as one entry stage.
class _AuthFlow extends StatefulWidget {
  const _AuthFlow({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<_AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<_AuthFlow> {
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      child: _showLogin
          ? LoginScreen(
              key: const ValueKey('login'),
              onComplete: widget.onComplete,
              onToggle: () => setState(() => _showLogin = false),
            )
          : RegisterScreen(
              key: const ValueKey('register'),
              onComplete: widget.onComplete,
              onToggle: () => setState(() => _showLogin = true),
            ),
    );
  }
}

/// Five-tab shell: Today · Habits · Coach · Analytics · Profile.
///
/// The screens are rebuilt from [build] so that changing the app language
/// refreshes every string immediately while each tab keeps its own state.
class BreakBotHome extends StatefulWidget {
  const BreakBotHome({super.key, this.onLogout});

  final VoidCallback? onLogout;

  @override
  State<BreakBotHome> createState() => _BreakBotHomeState();
}

class _BreakBotHomeState extends State<BreakBotHome> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    AppLocale.notifier.addListener(_handleLocaleChange);
  }

  @override
  void dispose() {
    AppLocale.notifier.removeListener(_handleLocaleChange);
    super.dispose();
  }

  void _handleLocaleChange() {
    if (mounted) setState(() {});
  }

  void _select(int index) {
    final target = index.clamp(0, 4);
    if (target == _selectedIndex) return;
    setState(() => _selectedIndex = target);
  }

  Widget _screenFor(int index) {
    switch (index) {
      case 0:
        return HomeScreen(
          onNavigateTab: _select,
          onAddHabit: () => _select(1),
        );
      case 1:
        return HabitsScreen(onAddRequested: () => _select(1));
      case 2:
        return CoachScreen(onNavigateTab: _select);
      case 3:
        return const AnalyticsScreen();
      default:
        return ProfileScreen(
          onLogout: widget.onLogout,
          onNavigateTab: _select,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(5, _screenFor),
      ),
      bottomNavigationBar: _AppBottomNav(
        index: _selectedIndex,
        onSelect: _select,
      ),
    );
  }
}

/// Floating bottom navigation, matching the Stitch reference: a translucent
/// white rounded bar, a soft `secondary-fixed` pill for the active tab and
/// primary-coloured icon + label.
class _AppBottomNav extends StatelessWidget {
  const _AppBottomNav({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  static const List<_NavItem> _items = [
    _NavItem(
      icon: Icons.check_circle_outline_rounded,
      selectedIcon: Icons.check_circle_rounded,
      labelAr: 'اليوم',
      labelEn: 'Today',
    ),
    _NavItem(
      icon: Icons.sync_alt_rounded,
      selectedIcon: Icons.sync_alt_rounded,
      labelAr: 'العادات',
      labelEn: 'Habits',
    ),
    _NavItem(
      icon: Icons.smart_toy_outlined,
      selectedIcon: Icons.smart_toy_rounded,
      labelAr: 'المدرب',
      labelEn: 'Coach',
    ),
    _NavItem(
      icon: Icons.auto_graph_outlined,
      selectedIcon: Icons.auto_graph_rounded,
      labelAr: 'التحليلات',
      labelEn: 'Analytics',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      labelAr: 'الملف',
      labelEn: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.onSurface.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Row(
                  children: [
                    for (var i = 0; i < _items.length; i++)
                      Expanded(
                        child: _NavButton(
                          item: _items[i],
                          selected: i == index,
                          onTap: () => onSelect(i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.labelAr,
    required this.labelEn,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String labelAr;
  final String labelEn;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = t(item.labelAr, item.labelEn);
    final color = selected ? AppColors.primary : AppColors.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.secondaryFixed.withValues(alpha: 0.55)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                size: 22,
                color: color,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.25,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
