import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String get welcome => 'مرحباً بك في بريك بوت';
  String get login => 'تسجيل الدخول';
  String get register => 'إنشاء حساب';
  String get email => 'البريد الإلكتروني';
  String get password => 'كلمة المرور';
  String get name => 'الاسم';
  String get fingerprint => 'بصمة الإصبع';
  String get habits => 'عاداتي';
  String get tasks => 'المهام';
  String get focus => 'التركيز';
  String get coach => 'المدرب الذكي';
  String get analytics => 'التقارير';
  String get gamification => 'التحفيز';
  String get notifications => 'الإشعارات';
  String get profile => 'الملف الشخصي';
  String get logout => 'تسجيل الخروج';
  String get checkIn => 'تسجيل الإنجاز';
  String get streak => 'سلسلة';
  String get xp => 'نقاط الخبرة';
  String get level => 'المستوى';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant _AppLocalizationsDelegate old) => false;
}
