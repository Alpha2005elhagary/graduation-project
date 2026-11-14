import 'package:flutter/material.dart';

/// App-wide language state.
///
/// BreakBot is Arabic-first: Arabic is the default language and English is a
/// first-class alternative. The selected locale is kept in a [ValueNotifier]
/// so that changing the language rebuilds the whole widget tree while keeping
/// the current navigation state intact.
class AppLocale {
  AppLocale._();

  static const Locale arabic = Locale('ar');
  static const Locale english = Locale('en');

  static const List<Locale> supportedLocales = [arabic, english];

  static final ValueNotifier<Locale> notifier =
      ValueNotifier<Locale>(arabic);

  static Locale get current => notifier.value;

  static bool get isArabic => current.languageCode == 'ar';

  static String get languageCode => current.languageCode;

  static void setLanguage(String languageCode) {
    final code = languageCode == 'en' ? 'en' : 'ar';
    if (notifier.value.languageCode == code) return;
    notifier.value = Locale(code);
  }

  static void toggle() => setLanguage(isArabic ? 'en' : 'ar');
}

/// Inline translation helper.
///
/// `t('عربي', 'English')` reads the current locale at build time. Because the
/// application is rebuilt when the locale changes, every screen picks up the
/// new language automatically.
String t(String ar, String en) => AppLocale.isArabic ? ar : en;

bool get isArabic => AppLocale.isArabic;

/// Shared UI strings used across several screens.
class AppStrings {
  AppStrings._();

  static String get appName => 'BreakBot';
  static String get tagline =>
      t('عادات أفضل · حياة أفضل', 'Better Habits · Brighter You');
  static String get today => t('اليوم', 'Today');
  static String get habits => t('العادات', 'Habits');
  static String get coach => t('المدرب', 'Coach');
  static String get analytics => t('التحليلات', 'Analytics');
  static String get profile => t('الملف', 'Profile');
  static String get settings => t('الإعدادات والملف', 'Settings & Profile');
  static String get save => t('حفظ', 'Save');
  static String get cancel => t('إلغاء', 'Cancel');
  static String get done => t('تم', 'Done');
  static String get skip => t('تخطي', 'Skip');
  static String get next => t('التالي', 'Next');
  static String get back => t('رجوع', 'Back');
  static String get viewAll => t('عرض الكل', 'View all');
  static String get start => t('ابدأ', 'Start');
  static String get days => t('يوم', 'days');
  static String get day => t('يوم', 'day');
  static String get minutes => t('دقائق', 'mins');
  static String get streak => t('السلسلة', 'Streak');
  static String get adherence => t('الالتزام', 'Adherence');
  static String get risk => t('الخطورة', 'Risk');
  static String get moderateRisk => t('خطورة متوسطة', 'Moderate Risk');
  static String get todayHabits => t('عادات اليوم', 'Today’s Habits');
  static String get addHabit => t('عادة جديدة', 'New Habit');
  static String get logout => t('تسجيل الخروج', 'Log Out');
  static String get language => t('اللغة / Language', 'Language');
  static String get english => 'English';
  static String get arabicLabel => 'العربية';
}
