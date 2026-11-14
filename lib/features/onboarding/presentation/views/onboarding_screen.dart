import 'package:breakbot/core/localisation/app_strings.dart';
import 'package:breakbot/core/theme/app_theme.dart';
import 'package:breakbot/shared/widgets/ds_widgets.dart';
import 'package:flutter/material.dart';

/// Onboarding introduces the product promise and the four signature
/// mechanisms from the Stitch reference: urge guard, AI coach, voice journal
/// and habit stacking. It is a single, scrollable page with one primary CTA.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              physics: const BouncingScrollPhysics(),
              children: [
                Row(
                  children: [
                    const DsBrandLockup(size: 34),
                    const Spacer(),
                    TextButton(
                      onPressed: widget.onComplete,
                      child: Text(t('تخطي', 'Skip')),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                const DsPill(
                  label: 'Behavioral Psychology · Smart Telemetry',
                  icon: Icons.verified_rounded,
                  tone: DsTone.secondary,
                  compact: true,
                ),
                const SizedBox(height: 16),
                Text(
                  t(
                    'اكسر الحلقة.\nوابنِ حياة أفضل.',
                    'Break the loop.\nBuild a brighter life.',
                  ),
                  style: text.displayMedium?.copyWith(
                    fontSize: 34,
                    height: 1.18,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  t(
                    'BreakBot يتوقع الرغبات قبل أن تتحول إلى انتكاسة، ويرشدك إلى وقفات صغيرة تعيد ضبط تركيزك — بلطف وبدون حكم.',
                    'BreakBot anticipates urges before they become relapse loops and guides gentle micro-breaks that reset your focus — no judgement, ever.',
                  ),
                  style: text.bodyLarge,
                ),
                const SizedBox(height: 20),
                _StreakPreview(text: text),
                const SizedBox(height: 20),
                _FeatureCard(
                  icon: Icons.psychology_rounded,
                  tone: DsTone.primary,
                  title: t('حارس الرغبة 98%', 'Urge Guard 98%'),
                  subtitle: t('اعتراض انتكاسي تنبؤي',
                      'Predictive relapse interception'),
                  description: t(
                    'BreakBot يرصد إشارات الرغبة قبل تشكّل حلقة الانتكاس، عبر تقييم مباشر للخطورة وإشارات لطيفة.',
                    'BreakBot anticipates urges before relapse loops form with real-time risk scoring and gentle micro-cues.',
                  ),
                  trailing: const DsPill(
                    label: '98%',
                    tone: DsTone.success,
                    compact: true,
                    bold: true,
                  ),
                ),
                const SizedBox(height: 12),
                _FeatureCard(
                  icon: Icons.smart_toy_rounded,
                  tone: DsTone.secondary,
                  title: t('مدرب العادات الذكي', 'AI Habit Coach & Coping Nudges'),
                  subtitle: t('توجيه شخصي على مدار اليوم',
                      'Personal guidance all day long'),
                  description: t(
                    'محادثات قصيرة تحوّل الرغبة إلى خطوة صغيرة قابلة للتنفيذ، مع مكافآت خبرة فورية.',
                    'Short conversations turn a craving into one tiny, doable step — with instant XP rewards.',
                  ),
                ),
                const SizedBox(height: 12),
                _FeatureCard(
                  icon: Icons.mic_rounded,
                  tone: DsTone.tertiary,
                  title: t('مذكرات صوتية', 'Voice Stream Journaling'),
                  subtitle: t('موجة جسدية نشطة لمدة دقيقتين',
                      '2-Min Somatic Wave Active'),
                  description: t(
                    'تحدث بحرية. يحلل BreakBot مؤشرات التوتر العاطفي ويعيد لك تمرينًا هادئًا في دقيقتين.',
                    'Speak freely. BreakBot analyzes emotional stress markers and returns a grounded 2-minute somatic reset.',
                  ),
                ),
                const SizedBox(height: 12),
                _FeatureCard(
                  icon: Icons.layers_rounded,
                  tone: DsTone.success,
                  title: t('تكديس العادات الذكي', 'Intelligent Habit Stacking'),
                  subtitle: t('سلسلة دقيقة لمدة 14 يومًا',
                      '14-Day Micro Stack Streak'),
                  description: t(
                    'اربط روتينًا صحيًا صغيرًا بعادة يومية موجودة، وستتحول الاستمرارية إلى زخم تلقائي.',
                    'Anchor healthy micro-routines to existing daily cues and turn consistency into automatic momentum.',
                  ),
                  trailing: const DsPill(
                    label: '14 🔥',
                    tone: DsTone.tertiary,
                    compact: true,
                    bold: true,
                  ),
                ),
                const SizedBox(height: 24),
                DsPrimaryButton(
                  label: t('ابدأ الآن (إنشاء حساب)',
                      'Get Started (Register)'),
                  onPressed: widget.onComplete,
                ),
                const SizedBox(height: 10),
                DsOutlinedButton(
                  label: t('لدي حساب بالفعل · تسجيل الدخول',
                      'I already have an account · Log In'),
                  onPressed: widget.onComplete,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(t('أو تابع باستخدام', 'or continue with'),
                          style: text.labelSmall),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SocialButton(
                        icon: Icons.g_mobiledata_rounded,
                        label: 'Google',
                        onTap: widget.onComplete,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SocialButton(
                        icon: Icons.apple_rounded,
                        label: 'Apple',
                        onTap: widget.onComplete,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.security_rounded,
                        size: 14, color: AppColors.outline),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        t('خصوصية كاملة على الجهاز · بدون بيع بيانات',
                            '100% client-side privacy · zero data selling'),
                        textAlign: TextAlign.center,
                        style: text.labelSmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StreakPreview extends StatelessWidget {
  const _StreakPreview({required this.text});

  final TextTheme text;

  @override
  Widget build(BuildContext context) {
    return DsCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t('سلسلة العادات الدقيقة', 'Micro-habit streak'),
                  style: text.titleMedium,
                ),
              ),
              const DsPill(
                label: '14',
                icon: Icons.local_fire_department_rounded,
                tone: DsTone.tertiary,
                compact: true,
                bold: true,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            t('آخر 14 يومًا · استمرارية 86%',
                'Last 14 days · 86% consistency'),
            style: text.bodySmall,
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(14, (index) {
              final active = index < 12;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index == 13 ? 0 : 4),
                  height: 26,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary
                        : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: active && index >= 10
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14)
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.description,
    this.trailing,
  });

  final IconData icon;
  final DsTone tone;
  final String title;
  final String subtitle;
  final String description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DsCard(
      padding: const EdgeInsets.all(18),
      radius: 22,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DsIconBadge(icon: icon, tone: tone, size: 48, radius: 15),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title, style: text.titleMedium),
                    ),
                    ?trailing,
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: text.labelSmall?.copyWith(color: tone.foreground),
                ),
                const SizedBox(height: 8),
                Text(description, style: text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 24),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.8)),
        ),
      ),
    );
  }
}
