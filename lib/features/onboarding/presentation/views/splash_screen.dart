import 'package:breakbot/core/localisation/app_strings.dart';
import 'package:breakbot/core/theme/app_theme.dart';
import 'package:breakbot/shared/widgets/ds_widgets.dart';
import 'package:flutter/material.dart';

/// Splash / first paint of BreakBot, following the Stitch splash screen:
/// brand lockup, AI greeting, initialization progress and a single primary CTA.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.onStart});

  final VoidCallback? onStart;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _progress = Tween<double>(begin: 0.12, end: 0.84).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 1, curve: Curves.easeInOutCubic),
      ),
    );
    _controller.forward();
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
      body: Stack(
        children: [
          const _SplashBackdrop(),
          SafeArea(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fade.value,
                  child: Transform.scale(scale: _scale.value, child: child),
                );
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DsBrandLockup(
                                size: 34,
                                showName: false,
                              ),
                              DsPill(
                                label: t('الإصدار 2.4.0', 'v2.4.0'),
                                icon: Icons.lock_outline_rounded,
                                tone: DsTone.neutral,
                                compact: true,
                              ),
                            ],
                          ),
                          SizedBox(height: constraints.maxHeight > 760 ? 80 : 52),

                          // Logo mark with a soft energy ring.
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 148,
                                height: 148,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.primary.withValues(alpha: 0.16),
                                      AppColors.primary.withValues(alpha: 0),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: 108,
                                height: 108,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.16),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              DsBrandMark(size: 84, radius: 26, showGlow: true),
                              Positioned(
                                top: 20,
                                right: 20,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: AppColors.tertiaryFixedDim,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'BreakBot',
                            textAlign: TextAlign.center,
                            style: text.displayMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            t('عادات أفضل · حياة أفضل', 'Better Habits · Brighter You'),
                            textAlign: TextAlign.center,
                            style: text.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 34),

                          // AI companion card
                          DsCard(
                            radius: 26,
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const DsIconBadge(
                                      icon: Icons.smart_toy_rounded,
                                      size: 40,
                                      radius: 13,
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t('رفيقك الذكي', 'BreakBot AI'),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: text.titleMedium,
                                          ),
                                          Text(
                                            t('جاهز لبناء إيقاعك اليومي',
                                                'Ready to build your daily rhythm'),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: text.labelSmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    const DsPill(
                                      label: 'AI',
                                      tone: DsTone.secondary,
                                      compact: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  t(
                                    '«جاهز للتوقف، الترطيب، وإعادة ضبط تركيزك؟ سأرشدك خطوة بخطوة.»',
                                    '“Ready to pause, hydrate, and reset your workflow focus? I’ll guide every step.”',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.bodyLarge?.copyWith(
                                    color: AppColors.onSurface,
                                    height: 1.65,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          AnimatedBuilder(
                            animation: _progress,
                            builder: (context, _) {
                              final value = _progress.value;
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          t('جارٍ تهيئة إيقاعك الشخصي…',
                                              'Initializing your personalized rhythm…'),
                                          style: text.bodySmall,
                                        ),
                                      ),
                                      Text(
                                        '${(value * 100).round()}%',
                                        style: text.labelLarge?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      value: value,
                                      minHeight: 8,
                                      backgroundColor: AppColors.primaryFixed,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          DsPrimaryButton(
                            label: t('ابدأ جلسة اليوم', 'Start Daily Session'),
                            onPressed: widget.onStart,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shield_outlined,
                                  size: 14, color: AppColors.outline),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  t('خصوصية كاملة على جهازك',
                                      '100% client-side privacy'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.labelSmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            t('BreakBot • صُنع بعلم النفس السلوكي',
                                'BreakBot • Built with behavioral psychology'),
                            textAlign: TextAlign.center,
                            style: text.labelSmall
                                ?.copyWith(color: AppColors.outline),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashBackdrop extends StatelessWidget {
  const _SplashBackdrop();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F8FF), Color(0xFFFAF8FF), Color(0xFFEEF1FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -90,
              child: _Blob(
                size: 300,
                color: AppColors.primary.withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              bottom: -110,
              left: -110,
              child: _Blob(
                size: 320,
                color: AppColors.secondary.withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              top: 220,
              left: -140,
              child: _Blob(
                size: 220,
                color: AppColors.tertiaryFixedDim.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
