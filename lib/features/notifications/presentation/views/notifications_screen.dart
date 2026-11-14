import 'package:breakbot/core/localisation/app_strings.dart';
import 'package:breakbot/core/theme/app_theme.dart';
import 'package:breakbot/shared/widgets/ds_widgets.dart';
import 'package:flutter/material.dart';

/// Notification and sharing preferences, restyled to the Stitch system.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _dailyReminders = true;
  bool _gentleNudges = true;
  bool _quietHours = false;
  bool _focusReminders = true;
  bool _weeklyReport = true;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(),
        title: Text(t('الإشعارات', 'Notifications')),
        actions: const [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 16),
            child: Center(
              child: DsPill(
                label: 'AI',
                icon: Icons.auto_awesome_rounded,
                tone: DsTone.secondary,
                compact: true,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            DsCard(
              gradient: AppTheme.primaryGradient,
              borderColor: Colors.transparent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('درع التنبيهات الذكي',
                              'Your smart alert shield'),
                          style: text.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t(
                            'نُنبّهك في اللحظة المناسبة فقط — قبل الرغبة، لا بعدها.',
                            'We nudge you at the right moment — before the urge, not after.',
                          ),
                          style: text.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            DsSectionHeader(
              title: t('التنبيهات', 'Alerts'),
              subtitle: t('تحكم في إيقاع تذكيراتك',
                  'Tune the rhythm of your reminders'),
            ),
            const SizedBox(height: 12),
            DsCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  _SettingRow(
                    icon: Icons.event_available_rounded,
                    title: t('التنبيهات اليومية للعادات',
                        'Daily habit reminders'),
                    subtitle: t('تذكيرك بعاداتك في الوقت المحدد',
                        'Reminders timed to your protocols'),
                    value: _dailyReminders,
                    onChanged: (v) => setState(() => _dailyReminders = v),
                  ),
                  const DsHairline(),
                  _SettingRow(
                    icon: Icons.smart_toy_rounded,
                    title: t('التنبيهات اللطيفة', 'Gentle nudges'),
                    subtitle: t('رسائل تشجيعية خلال اليوم',
                        'Encouraging check-ins during the day'),
                    value: _gentleNudges,
                    onChanged: (v) => setState(() => _gentleNudges = v),
                  ),
                  const DsHairline(),
                  _SettingRow(
                    icon: Icons.bedtime_rounded,
                    title: t('أوضاع الهدوء', 'Quiet hours'),
                    subtitle: t('عدم الإزعاج أثناء النوم',
                        'Do not disturb while you sleep'),
                    value: _quietHours,
                    onChanged: (v) => setState(() => _quietHours = v),
                  ),
                  const DsHairline(),
                  _SettingRow(
                    icon: Icons.timer_rounded,
                    title: t('إشعارات التركيز', 'Focus reminders'),
                    subtitle: t('تذكير بجلسات التركيز القصيرة',
                        'Prompts for short deep-focus sessions'),
                    value: _focusReminders,
                    onChanged: (v) => setState(() => _focusReminders = v),
                  ),
                  const DsHairline(),
                  _SettingRow(
                    icon: Icons.insights_rounded,
                    title: t('التقرير الأسبوعي', 'Weekly report'),
                    subtitle: t('ملخص الالتزام والرغبات كل أحد',
                        'Your adherence and urge summary every Sunday'),
                    value: _weeklyReport,
                    onChanged: (v) => setState(() => _weeklyReport = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            DsSectionHeader(
              title: t('التصدير والمشاركة', 'Export & share'),
              subtitle: t('بياناتك ملكك وحدك', 'Your data stays yours'),
            ),
            const SizedBox(height: 12),
            DsCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ActionRow(
                    icon: Icons.download_rounded,
                    title: t('تصدير البيانات', 'Export your data'),
                    subtitle: t('احفظ بياناتك كملف PDF',
                        'Download your wellness dossier as a PDF'),
                    onTap: () => showDsSnack(
                      context,
                      t('جارٍ تجهيز ملفك الصحي…', 'Preparing your dossier…'),
                      success: true,
                    ),
                  ),
                  const DsHairline(),
                  _ActionRow(
                    icon: Icons.share_rounded,
                    title: t('مشاركة التقدم', 'Share your progress'),
                    subtitle: t('شارك إنجازاتك مع من تحب',
                        'Share your streak with someone you trust'),
                    onTap: () => showDsSnack(
                      context,
                      t('رابط المشاركة جاهز في الحافظة',
                          'Share link copied to clipboard'),
                      success: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      type: MaterialType.transparency,
      child: SwitchListTile.adaptive(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        secondary: DsIconBadge(icon: icon, size: 38),
        title: Text(
          title,
          style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle, style: text.bodySmall),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: DsIconBadge(icon: icon, tone: DsTone.secondary, size: 38),
        title: Text(
          title,
          style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle, style: text.bodySmall),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.outline,
        ),
      ),
    );
  }
}
