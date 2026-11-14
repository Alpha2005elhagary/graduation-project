import 'package:breakbot/core/di/injection_container.dart';
import 'package:breakbot/core/localisation/app_strings.dart';
import 'package:breakbot/core/storage/local_storage_manager.dart';
import 'package:breakbot/core/theme/app_theme.dart';
import 'package:breakbot/features/habits/domain/entities/habit.dart';
import 'package:breakbot/shared/widgets/ds_widgets.dart';
import 'package:flutter/material.dart';

/// Analytics — AI-modelled insights, craving curve, adherence breakdown and the
/// relapse-prevention dossier from the Stitch reference.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final storage = getIt<LocalStorageManager>();
  String _range = '7';

  bool _isDoneToday(Habit habit) {
    final last = habit.lastCheckin;
    if (last == null) return false;
    final now = DateTime.now();
    return now.year == last.year &&
        now.month == last.month &&
        now.day == last.day;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: LocalStorageManager.revision,
      builder: (context, _, _) {
        final habits = storage.getHabits();
        final active = habits.where((h) => h.isActive).toList();
        final done = active.where(_isDoneToday).length;
        final maxStreak = habits.fold<int>(
            0, (max, h) => h.streak > max ? h.streak : max);
        final adherence = active.isEmpty
            ? 87
            : ((done / active.length) * 100).round().clamp(0, 100);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              physics: const BouncingScrollPhysics(),
              children: [
                _Header(
                  range: _range,
                  onRange: (value) => setState(() => _range = value),
                ),
                const SizedBox(height: 20),
                Text(t('رؤى العادات', 'Habit Insights'),
                    style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 4),
                Text(
                  t(
                    'نمذجة عصبية للتعافي وبناء المرونة — بياناتك تبقى على جهازك.',
                    'AI-modeled neuroplasticity & recovery — your data stays on-device.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                _SynthesisCard(range: _range),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DsStatTile(
                        value: '-48%',
                        label: t('اندفاع الرغبة', 'Craving Surge'),
                        icon: Icons.trending_down_rounded,
                        tone: DsTone.success,
                        caption: t('▼ 12% عن الشهر الماضي',
                            '▼ 12% vs last mo'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DsStatTile(
                        value: '$adherence%',
                        label: t('الالتزام', 'Adherence'),
                        icon: Icons.check_circle_outline_rounded,
                        tone: DsTone.primary,
                        caption: t('مرونة مثالية', 'Optimal resilience'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DsStatTile(
                        value: '$maxStreak',
                        label: t('السلسلة الحالية', 'Current Streak'),
                        icon: Icons.local_fire_department_rounded,
                        tone: DsTone.tertiary,
                        caption: t('أفضل رقم شخصي 🎉', 'Personal best 🎉'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DsStatTile(
                        value: t('7:30 – 9:00 م', '7:30 – 9:00 PM'),
                        label: t('نافذة الخطورة', 'Risk Window'),
                        icon: Icons.schedule_rounded,
                        tone: DsTone.secondary,
                        caption: t('هبوط الكورتيزول المسائي',
                            'Evening cortisol drop'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const _CravingCurveCard(),
                const SizedBox(height: 14),
                const _CategoryBreakdownCard(),
                const SizedBox(height: 14),
                _DossierCard(
                  onExport: () => showDsSnack(
                    context,
                    t('تم تجهيز ملف PDF الصحي على جهازك (تجريبي).',
                        'Your wellness PDF dossier is ready on-device (demo).'),
                    success: true,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          size: 12, color: AppColors.outline),
                      const SizedBox(width: 5),
                      Text(
                        t('تحليلات محلية · صفر بيع بيانات',
                            'On-device analytics · zero data selling'),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
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
  const _Header({required this.range, required this.onRange});

  final String range;
  final ValueChanged<String> onRange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const DsBrandLockup(size: 34, showName: false),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            t('التحليلات', 'Analytics'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        _RangeChip(
          label: t('7 أيام', '7 Days'),
          selected: range == '7',
          onTap: () => onRange('7'),
        ),
        const SizedBox(width: 6),
        _RangeChip(
          label: t('30 يوم', '30 Days'),
          selected: range == '30',
          onTap: () => onRange('30'),
        ),
      ],
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? Colors.white : AppColors.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _SynthesisCard extends StatelessWidget {
  const _SynthesisCard({required this.range});

  final String range;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DsCard(
      radius: 26,
      padding: const EdgeInsets.all(20),
      gradient: AppTheme.heroGradient,
      borderColor: Colors.transparent,
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.psychology_rounded,
                    color: Colors.white, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t('خلاصة BreakBot', 'BreakBot Synthesis'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleSmall?.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  range == '7' ? t('7 أيام', '7 Days') : t('30 يوم', '30 Days'),
                  style: text.labelSmall?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text.rich(
            TextSpan(
              style: text.bodyLarge?.copyWith(
                color: Colors.white,
                height: 1.65,
              ),
              children: [
                TextSpan(
                  text: t('«هبوط الدوبامين المسائي بدأ يتوازن! ',
                      '“Evening dopamine dips are leveling out! '),
                ),
                TextSpan(
                  text: t('تحسنت عتبة رغبتك بنسبة 22%',
                      'your craving threshold improved by 22%'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(
                  text: t(
                    ' منذ اعتماد تمارين التمدد لمدة 3 دقائق.»',
                    ' since adopting 3-min stretch rituals.”',
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

class _CravingCurveCard extends StatelessWidget {
  const _CravingCurveCard();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DsCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('منحنى الرغبة التنبؤي',
                        'Predictive Craving Curve'),
                        style: text.titleMedium),
                    Text(
                      t('الذروة الأساسية مقابل تهدئة BreakBot',
                          'Baseline spike vs Post-BreakBot calming'),
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              const DsPill(
                label: 'Real-time',
                icon: Icons.bolt_rounded,
                tone: DsTone.success,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _Legend(
                color: AppColors.outlineVariant,
                label: t('الرغبة الأساسية', 'Baseline Urge'),
              ),
              _Legend(
                color: AppColors.primary,
                label: t('حاجز التدخل', 'Intervention Buffer'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 168,
            width: double.infinity,
            child: CustomPaint(
              painter: _CravingCurvePainter(),
            ),
          ),
          const SizedBox(height: 8),
          const Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _AxisLabel('12 PM'),
                _AxisLabel('4 PM'),
                _AxisLabel('8 PM', peak: true),
                _AxisLabel('11 PM'),
              ],
            ),
          ),
          const DsHairline(vertical: 14),
          Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  label: t('زمن التدخل', 'Intervention latency'),
                  value: t('45 ثانية', '45s avg'),
                ),
              ),
              Container(
                width: 1,
                height: 34,
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
              ),
              Expanded(
                child: _MiniMetric(
                  label: t('انخفاض السعة', 'Amplitude'),
                  value: '-54%',
                  valueColor: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _AxisLabel extends StatelessWidget {
  const _AxisLabel(this.text, {this.peak = false});

  final String text;
  final bool peak;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    if (!peak) return Text(text, style: style);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$text (Peak)',
        style: style?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          value,
          style: text.titleMedium?.copyWith(
            color: valueColor ?? AppColors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: text.labelSmall, textAlign: TextAlign.center),
      ],
    );
  }
}

class _CravingCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.28)
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // Baseline curve: calm morning, sharp evening spike, late decline.
    final baselinePoints = <Offset>[
      Offset(0, size.height * 0.74),
      Offset(size.width * 0.16, size.height * 0.66),
      Offset(size.width * 0.33, size.height * 0.56),
      Offset(size.width * 0.48, size.height * 0.47),
      Offset(size.width * 0.62, size.height * 0.26),
      Offset(size.width * 0.72, size.height * 0.12),
      Offset(size.width * 0.82, size.height * 0.38),
      Offset(size.width, size.height * 0.58),
    ];

    // Intervention curve stays meaningfully lower around the evening peak.
    final interventionPoints = <Offset>[
      Offset(0, size.height * 0.78),
      Offset(size.width * 0.16, size.height * 0.70),
      Offset(size.width * 0.33, size.height * 0.62),
      Offset(size.width * 0.48, size.height * 0.56),
      Offset(size.width * 0.62, size.height * 0.47),
      Offset(size.width * 0.72, size.height * 0.40),
      Offset(size.width * 0.82, size.height * 0.50),
      Offset(size.width, size.height * 0.62),
    ];

    final baselinePath = _smoothPath(baselinePoints);
    final interventionPath = _smoothPath(interventionPoints);

    // Filled buffer between the two curves.
    final buffer = Path()..addPath(interventionPath, Offset.zero);
    for (final point in baselinePoints.reversed) {
      buffer.lineTo(point.dx, point.dy);
    }
    buffer.close();
    canvas.drawPath(
      buffer,
      Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.16),
            AppColors.primary.withValues(alpha: 0.03),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      baselinePath,
      Paint()
        ..color = AppColors.outlineVariant
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawPath(
      interventionPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.primaryContainer, AppColors.primary],
        ).createShader(Offset.zero & size)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Peak marker.
    final peak = baselinePoints[5];
    canvas.drawCircle(
      peak,
      5,
      Paint()..color = AppColors.surfaceContainerLowest,
    );
    canvas.drawCircle(peak, 3.2, Paint()..color = AppColors.tertiary);

    // Intervention point marker.
    final low = interventionPoints[5];
    canvas.drawCircle(
      low,
      5,
      Paint()..color = AppColors.surfaceContainerLowest,
    );
    canvas.drawCircle(low, 3.2, Paint()..color = AppColors.primary);
  }

  Path _smoothPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final midX = (current.dx + next.dx) / 2;
      path.cubicTo(midX, current.dy, midX, next.dy, next.dx, next.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CategoryBreakdownCard extends StatelessWidget {
  const _CategoryBreakdownCard();

  static const _items = <(String, String, double, Color)>[
    ('الإيقاعات الذهنية', 'Mindful Breaks', 0.94, AppColors.primary),
    ('فواصل الترطيب', 'Hydration Intervals', 0.88, Color(0xFF2563EB)),
    ('تأخير الرغبة (5 دقائق)', 'Craving Delays (5-Min Delay)', 0.82,
        AppColors.secondary),
    ('تهدئة الليل', 'Night Routine Wind-down', 0.76, AppColors.tertiary),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DsCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const DsIconBadge(
                icon: Icons.donut_large_rounded,
                tone: DsTone.primary,
                size: 38,
                radius: 12,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('تفصيل فئات العادات',
                        'Habit Category Breakdown'),
                        style: text.titleMedium),
                    Text(t('درجة الالتزام',
                        'Adherence compliance score'),
                        style: text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final item in _items) ...[
            Row(
              children: [
                Expanded(
                  child: Text(t(item.$1, item.$2),
                      style: text.bodySmall
                          ?.copyWith(color: AppColors.onSurface)),
                ),
                Text(
                  '${(item.$3 * 100).round()}%',
                  style: text.labelMedium?.copyWith(
                    color: item.$4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: item.$3,
                minHeight: 7,
                backgroundColor: AppColors.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation<Color>(item.$4),
              ),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _DossierCard extends StatelessWidget {
  const _DossierCard({required this.onExport});

  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DsCard(
      padding: const EdgeInsets.all(18),
      radius: 24,
      gradient: const LinearGradient(
        colors: [Color(0xFFEAF8F1), Color(0xFFF7FCFA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: AppColors.successContainer,
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const DsIconBadge(
                icon: Icons.verified_rounded,
                tone: DsTone.success,
                size: 40,
                radius: 13,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('الفعالية السريرية', 'Clinical Efficacy'),
                        style: text.labelSmall
                            ?.copyWith(color: AppColors.success)),
                    Text(t('ملف الوقاية من الانتكاس',
                        'Relapse Prevention Dossier'),
                        style: text.titleMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            t(
              'اكتشف BreakBot تلقائيًا المحفزات عالية الخطورة وخففها قبل حدوث الانتكاس السلوكي.',
              'BreakBot autonomously detected and mitigated high-risk triggers before behavioral relapse.',
            ),
            style: text.bodySmall,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.16),
              ),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('23',
                        style: text.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        )),
                    Text(t('رغبة تم اعتراضها', 'urges prevented'),
                        style: text.labelSmall),
                  ],
                ),
                const Spacer(),
                DsPill(
                  label: t('91.3% آمن', '91.3% Safe'),
                  tone: DsTone.success,
                  compact: true,
                  bold: true,
                  icon: Icons.shield_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 46,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onExport,
              icon: const Icon(Icons.file_download_outlined, size: 18),
              label: Text(t('تصدير ملف PDF الصحي',
                  'Export Wellness PDF')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.success,
                side: BorderSide(
                  color: AppColors.success.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
