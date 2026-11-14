import 'package:breakbot/core/di/injection_container.dart';
import 'package:breakbot/core/localisation/app_strings.dart';
import 'package:breakbot/core/storage/local_storage_manager.dart';
import 'package:breakbot/core/theme/app_theme.dart';
import 'package:breakbot/features/habits/domain/entities/habit.dart';
import 'package:breakbot/shared/widgets/ds_widgets.dart';
import 'package:flutter/material.dart';

/// Settings & profile, grouped exactly like the Stitch reference: identity and
/// outcome stats, wearable integration, AI risk engine, habit configuration,
/// privacy and account preferences.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.onLogout, this.onNavigateTab});

  final VoidCallback? onLogout;
  final Function(int)? onNavigateTab;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final storage = getIt<LocalStorageManager>();

  bool _biometricSync = true;
  bool _predictiveAlerts = true;
  bool _localAudio = true;
  String _sensitivity = 'balanced';

  bool _isDoneToday(Habit habit) {
    final last = habit.lastCheckin;
    if (last == null) return false;
    final now = DateTime.now();
    return now.year == last.year &&
        now.month == last.month &&
        now.day == last.day;
  }

  Future<void> _setLanguage(String code) async {
    AppLocale.setLanguage(code);
    await storage.setLanguage(code);
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('تسجيل الخروج', 'Log out')),
        content: Text(t(
          'هل ترغب في تسجيل الخروج من BreakBot؟ ستبقى بياناتك محفوظة على جهازك.',
          'Log out of BreakBot? Your habits stay saved on this device.',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('إلغاء', 'Cancel')),
          ),
          FilledButton(
            onPressed: () {
              storage.clearAuth();
              Navigator.pop(context);
              if (widget.onLogout != null) {
                widget.onLogout!();
              } else {
                showDsSnack(context, t('تم تسجيل الخروج', 'Logged out'));
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(t('خروج', 'Log out')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: LocalStorageManager.revision,
      builder: (context, _, _) {
        final user = storage.getUser();
        final habits = storage.getHabits();
        final active = habits.where((h) => h.isActive).toList();
        final done = active.where(_isDoneToday).length;
        final maxStreak = habits.fold<int>(
            0, (max, h) => h.streak > max ? h.streak : max);
        final adherence = active.isEmpty
            ? 84
            : ((done / active.length) * 100).round().clamp(0, 100);
        final name = (user?.name.trim().isNotEmpty ?? false)
            ? user!.name.trim()
            : t('أليكس ستيرلينج', 'Alex Sterling');
        final email = (user?.email.trim().isNotEmpty ?? false)
            ? user!.email.trim()
            : 'alex.sterling@habitlife.io';

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              physics: const BouncingScrollPhysics(),
              children: [
                _Header(streak: maxStreak),
                const SizedBox(height: 18),
                Text(t('الإعدادات والملف', 'Settings & Profile'),
                    style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 4),
                Text(
                  t('تحكم في روتينك وبياناتك الصحية بخصوصية كاملة.',
                      'Control your routine and health data with full privacy.'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _ProfileCard(
                  name: name,
                  email: email,
                  streak: maxStreak,
                  adherence: adherence,
                ),
                const SizedBox(height: 22),
                _SectionTitle(
                  icon: Icons.watch_rounded,
                  title: t('التكامل القابل للارتداء والبيومترية',
                      'Wearable & Biometric Integration'),
                  subtitle: t('تعطيل عادات فسيولوجية في الوقت الحقيقي',
                      'Real-time physiological habit disruption'),
                ),
                const SizedBox(height: 10),
                DsCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _ToggleRow(
                        icon: Icons.favorite_rounded,
                        tone: DsTone.danger,
                        title: t('Apple HealthKit و Oura Ring',
                            'Apple HealthKit & Oura Ring'),
                        subtitle: t('تمت المزامنة قبل دقيقتين',
                            'Synced 2m ago'),
                        value: _biometricSync,
                        onChanged: (value) =>
                            setState(() => _biometricSync = value),
                        trailingWhenOn:
                            DsPill(
                              label: t('نشط', 'Active'),
                              tone: DsTone.success,
                              compact: true,
                            ),
                      ),
                      const DsHairline(vertical: 0),
                      _ToggleRow(
                        icon: Icons.monitor_heart_rounded,
                        tone: DsTone.primary,
                        title: t('رصد الرغبة في الوقت الحقيقي',
                            'Real-time Craving Detection'),
                        subtitle: t(
                          'معدل ضربات القلب و HRV يشغلان إشارات إعادة ضبط لطيفة قبل ارتفاع الإنهاك',
                          'Heart Rate and HRV trigger gentle micro-reset prompts before burnout spikes',
                        ),
                        value: true,
                        onChanged: (_) {},
                      ),
                      _LinkRow(
                        label: t('اعرض منحنى الرغبة الحيوية في التحليلات',
                            'View Live Biometric Craving Curve in Analytics'),
                        onTap: () => widget.onNavigateTab?.call(3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(
                  icon: Icons.psychology_rounded,
                  title: t('محرك المخاطر والتنبيهات',
                      'AI Risk Engine & Notification Pacing'),
                  subtitle: t('نماذج تعلم تنبؤية مضبوطة على يومك',
                      'Predictive models tuned to your day'),
                ),
                const SizedBox(height: 10),
                DsCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _ToggleRow(
                        icon: Icons.notifications_active_rounded,
                        tone: DsTone.primary,
                        title: t('تنبيهات الانتكاس التنبؤية',
                            'Predictive Relapse Alerts'),
                        subtitle: t(
                          'تدخل مبكر عندما يتجاوز إجهاد الشاشة خط الأساس',
                          'Intervene early when screen strain exceeds your baseline',
                        ),
                        value: _predictiveAlerts,
                        onChanged: (value) =>
                            setState(() => _predictiveAlerts = value),
                      ),
                      const DsHairline(vertical: 0),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const DsIconBadge(
                                  icon: Icons.tune_rounded,
                                  tone: DsTone.secondary,
                                  size: 34,
                                  radius: 10,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    t('حساسية الرغبة',
                                        'Urge Sensitivity Mode'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _SensitivitySelector(
                              selected: _sensitivity,
                              onChanged: (value) =>
                                  setState(() => _sensitivity = value),
                            ),
                          ],
                        ),
                      ),
                      const DsHairline(vertical: 0),
                      _InfoRow(
                        icon: Icons.music_note_rounded,
                        tone: DsTone.secondary,
                        title: t('نغمة التدخل الصوتي',
                            'Intervention Audio Chime'),
                        trailing: t('وعاء غنائي لطيف',
                            'Gentle Singing Bowl'),
                      ),
                      const DsHairline(vertical: 0),
                      _InfoRow(
                        icon: Icons.bedtime_rounded,
                        tone: DsTone.neutral,
                        title: t('ساعات الهدوء (DND)',
                            'Quiet Hours (DND)'),
                        subtitle: t('يكتم التذكيرات غير الحرجة',
                            'Mutes non-critical reminders'),
                        trailing: t('10:00 م – 7:00 ص',
                            '10:00 PM – 7:00 AM'),
                      ),
                      _LinkRow(
                        label: t('اختبر الحساسية في استوديو صوت المدرب',
                            'Test Sensitivity in AI Coach Voice Studio'),
                        onTap: () => widget.onNavigateTab?.call(2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(
                  icon: Icons.checklist_rounded,
                  title: t('إعداد العادات والبروتوكولات',
                      'Habits & Protocols Config'),
                  subtitle: t('حلقات عادات نشطة وتدخلات آلية',
                      'Active habit loops and automated interventions'),
                ),
                const SizedBox(height: 10),
                DsCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.layers_rounded,
                        tone: DsTone.primary,
                        title: t('${active.length} بروتوكول عادة نشط',
                            '${active.length} Active Habit Protocols'),
                        subtitle: t(
                          'وقفة الجلسة، قاعدة 20-20-20، تنفس صندوقي والمزيد',
                          'Posture Reset, 20-20-20 Rule, Box Breathing & more',
                        ),
                        trailing: t('آلي', 'Automated'),
                      ),
                      _LinkRow(
                        label: t('أدر ${active.length} بروتوكولات في منشئ العادات',
                            'Manage ${active.length} Active Protocols in Habit Builder'),
                        onTap: () => widget.onNavigateTab?.call(1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(
                  icon: Icons.shield_rounded,
                  title: t('الخصوصية وأمان البيانات',
                      'Privacy & Data Security'),
                  subtitle: t('بنية صحية بمعرفة صفرية',
                      'Zero-knowledge health architecture'),
                ),
                const SizedBox(height: 10),
                DsCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.verified_user_rounded,
                        tone: DsTone.success,
                        title: t('ضمان عدم بيع البيانات',
                            'Zero-Data-Selling Guarantee'),
                        subtitle: t(
                          'خصوصية 100% على الجهاز. تبقى مؤشراتك الحيوية وعاداتك مشفرة هنا.',
                          '100% client-side privacy. Your biological metrics and habits stay encrypted on this device.',
                        ),
                      ),
                      const DsHairline(vertical: 0),
                      _ToggleRow(
                        icon: Icons.graphic_eq_rounded,
                        tone: DsTone.secondary,
                        title: t('معالجة صوتية محلية',
                            'Local Audio Processing'),
                        subtitle: t(
                          'نسخ تأملاتك الصوتية عبر شريحة عصبية على الجهاز',
                          'Transcribe voice break reflections using on-device neural silicon',
                        ),
                        value: _localAudio,
                        onChanged: (value) =>
                            setState(() => _localAudio = value),
                      ),
                      _LinkRow(
                        label: t('صدّر ملف PDF الصحي وملف العادات',
                            'Export Wellness PDF & Habit Dossier'),
                        onTap: () => showDsSnack(
                          context,
                          t('تم تجهيز ملفك الصحي (تجريبي).',
                              'Your wellness dossier is ready (demo).'),
                          success: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(
                  icon: Icons.tune_rounded,
                  title: t('تفضيلات التطبيق والحساب',
                      'App Preferences & Account'),
                  subtitle: t('توطين اللغة وإدارة الجلسة',
                      'Language localization and session controls'),
                ),
                const SizedBox(height: 10),
                DsCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          children: [
                            const DsIconBadge(
                              icon: Icons.translate_rounded,
                              tone: DsTone.primary,
                              size: 34,
                              radius: 10,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t('اللغة / Language', 'Language / اللغة'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall),
                                  Text(
                                    t('العربية افتراضي · دعم كامل للإنجليزية',
                                        'Arabic default · full English support'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _LanguageSelector(
                        selected: AppLocale.languageCode,
                        onChanged: _setLanguage,
                      ),
                      const DsHairline(vertical: 10),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const DsIconBadge(
                          icon: Icons.logout_rounded,
                          tone: DsTone.danger,
                          size: 34,
                          radius: 10,
                        ),
                        title: Text(
                          t('تسجيل الخروج من BreakBot', 'Log Out of BreakBot'),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: AppColors.error),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded,
                            size: 18, color: AppColors.error),
                        onTap: _confirmLogout,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Center(
                  child: Text(
                    t('الإصدار 2.4.0 • صُنع بعلم النفس السلوكي',
                        'v2.4.0 • Built with Behavioral Psychology AI'),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: DsBrandLockup(size: 34, showTagline: true),
          ),
        ),
        DsPill(
          label: '$streak 🔥',
          tone: DsTone.tertiary,
          compact: true,
          bold: true,
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.email,
    required this.streak,
    required this.adherence,
  });

  final String name;
  final String email;
  final int streak;
  final num adherence;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'A';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DsCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: const BoxDecoration(
                      gradient: AppTheme.heroGradient,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initials,
                      style: text.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surfaceContainerLowest,
                          width: 2,
                        ),
                      ),
                      child: const Icon(Icons.check_rounded,
                          size: 11, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.titleLarge),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded,
                            size: 16, color: AppColors.primary),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall),
                    const SizedBox(height: 6),
                    const DsPill(
                      label: 'Pro Member',
                      icon: Icons.workspace_premium_rounded,
                      tone: DsTone.tertiary,
                      compact: true,
                      bold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              t('التركيز السلوكي: بيئة المكتب وتخفيف التوتر',
                  'Behavioral Focus: Desk Ergonomics & Stress Relief'),
              style: text.bodySmall,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ProfileStat(
                    value: '${streak}d',
                    label: t('سلسلة', 'Streak'),
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.tertiary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
                Expanded(
                  child: _ProfileStat(
                    value: '$adherence%',
                    label: t('التزام', 'Adherence'),
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
                Expanded(
                  child: _ProfileStat(
                    value: '23',
                    label: t('رغبة مُحبطة', 'Urges Defused'),
                    icon: Icons.shield_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(value,
                style: text.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                )),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: text.labelSmall?.copyWith(fontSize: 10)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DsIconBadge(icon: icon, tone: DsTone.primary, size: 34, radius: 10),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: text.titleSmall),
              Text(subtitle, style: text.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.trailingWhenOn,
  });

  final IconData icon;
  final DsTone tone;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? trailingWhenOn;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DsIconBadge(icon: icon, tone: tone, size: 34, radius: 10),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleSmall),
                const SizedBox(height: 2),
                Text(subtitle, style: text.bodySmall),
                if (value && trailingWhenOn != null) ...[
                  const SizedBox(height: 6),
                  trailingWhenOn!,
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.tone,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final DsTone tone;
  final String title;
  final String? subtitle;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DsIconBadge(icon: icon, tone: tone, size: 34, radius: 10),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleSmall),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: text.bodySmall),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Text(
              trailing!,
              style: text.labelSmall?.copyWith(color: tone.foreground),
            ),
          ],
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const Icon(Icons.arrow_forward_rounded,
                size: 15, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _SensitivitySelector extends StatelessWidget {
  const _SensitivitySelector({
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = [
      ('conservative', t('متحفظ', 'Conservative')),
      ('balanced', t('متوازن', 'Balanced')),
      ('preventative', t('وقائي', 'Preventative')),
    ];
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(options[i].$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: selected == options[i].$1
                      ? AppColors.primary
                      : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected == options[i].$1
                        ? AppColors.primary
                        : AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  options[i].$2,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: selected == options[i].$1
                            ? Colors.white
                            : AppColors.onSurfaceVariant,
                        fontWeight: selected == options[i].$1
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _LanguageOption(
            label: 'English',
            flag: 'EN',
            selected: selected == 'en',
            onTap: () => onChanged('en'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _LanguageOption(
            label: 'العربية',
            flag: 'ع',
            selected: selected == 'ar',
            onTap: () => onChanged('ar'),
          ),
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String flag;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryFixed
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.outlineVariant.withValues(alpha: 0.4),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                flag,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected ? Colors.white : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selected
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
