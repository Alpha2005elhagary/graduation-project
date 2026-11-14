import 'package:breakbot/core/localisation/app_strings.dart';
import 'package:breakbot/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Shared design-system building blocks used by every screen.
///
/// Everything is deliberately thin and composable: cards, pills, badges,
/// buttons, section headers and progress rings. Screens stay declarative while
/// spacing, radii and colours remain consistent with the Stitch reference.

class DsSpace {
  DsSpace._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const EdgeInsets screen = EdgeInsets.fromLTRB(20, 0, 20, 28);
}

/// The signature BreakBot surface: white, 24px radius, hairline outline and a
/// very soft ambient shadow so it floats above the lavender background.
class DsCard extends StatelessWidget {
  const DsCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.color,
    this.gradient,
    this.borderColor,
    this.radius = 24,
    this.onTap,
    this.shadow = true,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final double radius;
  final VoidCallback? onTap;
  final bool shadow;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final themed = Theme.of(context);
    final surfaceColor = color ??
        (themed.brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.surfaceContainerLowest);
    final border = borderColor ??
        (themed.brightness == Brightness.dark
            ? AppColors.darkOutline
            : AppColors.outlineVariant.withValues(alpha: 0.55));

    final content = Container(
      decoration: BoxDecoration(
        color: gradient == null ? surfaceColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border, width: 1),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: AppColors.onSurface.withValues(
                    alpha: themed.brightness == Brightness.dark ? 0.3 : 0.035,
                  ),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return Container(margin: margin, child: content);

    return Container(
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: content,
        ),
      ),
    );
  }
}

class DsSectionHeader extends StatelessWidget {
  const DsSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.icon,
    this.padding = EdgeInsets.zero,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            DsIconBadge(icon: icon!, tone: DsTone.primary, size: 38),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: text.bodySmall),
                ],
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(actionLabel!),
                  const SizedBox(width: 3),
                  const Icon(Icons.arrow_forward_rounded, size: 15),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

enum DsTone { primary, secondary, tertiary, success, danger, neutral }

extension DsToneColors on DsTone {
  Color get foreground {
    switch (this) {
      case DsTone.primary:
        return AppColors.primary;
      case DsTone.secondary:
        return AppColors.secondary;
      case DsTone.tertiary:
        return AppColors.tertiary;
      case DsTone.success:
        return AppColors.success;
      case DsTone.danger:
        return AppColors.error;
      case DsTone.neutral:
        return AppColors.onSurfaceVariant;
    }
  }

  Color get background {
    switch (this) {
      case DsTone.primary:
        return AppColors.primaryFixed;
      case DsTone.secondary:
        return AppColors.secondaryFixed;
      case DsTone.tertiary:
        return AppColors.tertiaryContainer;
      case DsTone.success:
        return AppColors.successContainer;
      case DsTone.danger:
        return AppColors.errorContainer;
      case DsTone.neutral:
        return AppColors.surfaceContainer;
    }
  }
}

class DsIconBadge extends StatelessWidget {
  const DsIconBadge({
    super.key,
    required this.icon,
    this.tone = DsTone.primary,
    this.color,
    this.background,
    this.size = 44,
    this.radius = 14,
    this.border,
  });

  final IconData icon;
  final DsTone tone;
  final Color? color;
  final Color? background;
  final double size;
  final double radius;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? tone.background,
        borderRadius: BorderRadius.circular(radius),
        border: border,
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: color ?? tone.foreground,
      ),
    );
  }
}

class DsPill extends StatelessWidget {
  const DsPill({
    super.key,
    required this.label,
    this.icon,
    this.tone = DsTone.primary,
    this.color,
    this.background,
    this.borderColor,
    this.compact = false,
    this.bold = false,
  });

  final String label;
  final IconData? icon;
  final DsTone tone;
  final Color? color;
  final Color? background;
  final Color? borderColor;
  final bool compact;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? tone.foreground;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
        vertical: compact ? 4 : 7,
      ),
      decoration: BoxDecoration(
        color: background ?? tone.background,
        borderRadius: BorderRadius.circular(999),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 13 : 15, color: fg),
            SizedBox(width: compact ? 3 : 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: Theme.of(context).textTheme.bodySmall?.fontFamily,
              fontSize: compact ? 11 : 12,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: fg,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class DsPrimaryButton extends StatelessWidget {
  const DsPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = true,
    this.height = 54,
    this.color,
    this.foreground,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final double height;
  final Color? color;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          foregroundColor: foreground ?? Colors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 19),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class DsOutlinedButton extends StatelessWidget {
  const DsOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = true,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 19),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class DsProgressRing extends StatelessWidget {
  const DsProgressRing({
    super.key,
    required this.value,
    this.size = 92,
    this.strokeWidth = 9,
    this.color = AppColors.primary,
    this.trackColor,
    this.center,
  });

  final double value;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color? trackColor;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          value: value.clamp(0.0, 1.0),
          strokeWidth: strokeWidth,
          color: color,
          trackColor: trackColor ??
              (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkOutline
                  : AppColors.primaryFixed),
        ),
        child: Center(child: center),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.strokeWidth,
    required this.color,
    required this.trackColor,
  });

  final double value;
  final double strokeWidth;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - strokeWidth) / 2;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progress = Paint()
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0.75), color],
        startAngle: -1.5708,
        endAngle: 3.14159 * 1.5,
        transform: const GradientRotation(-1.5708),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);
    if (value > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -1.5708,
        6.28319 * value,
        false,
        progress,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class DsStatTile extends StatelessWidget {
  const DsStatTile({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.tone = DsTone.primary,
    this.trailing,
    this.caption,
  });

  final String value;
  final String label;
  final IconData? icon;
  final DsTone tone;
  final Widget? trailing;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DsCard(
      padding: const EdgeInsets.all(16),
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                DsIconBadge(icon: icon!, tone: tone, size: 32, radius: 10),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: tone == DsTone.neutral
                  ? AppColors.onSurface
                  : tone.foreground,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: text.bodySmall),
          if (caption != null) ...[
            const SizedBox(height: 2),
            Text(
              caption!,
              style: text.labelSmall?.copyWith(color: tone.foreground),
            ),
          ],
        ],
      ),
    );
  }
}

/// Brand lockup used on the splash, onboarding, auth and main headers.
class DsBrandMark extends StatelessWidget {
  const DsBrandMark({
    super.key,
    this.size = 42,
    this.radius = 14,
    this.showGlow = false,
  });

  final double size;
  final double radius;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.38),
                  blurRadius: 28,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Icon(
        Icons.smart_toy_rounded,
        color: Colors.white,
        size: size * 0.52,
      ),
    );
  }
}

class DsBrandLockup extends StatelessWidget {
  const DsBrandLockup({
    super.key,
    this.size = 36,
    this.showName = true,
    this.showTagline = false,
    this.onDark = false,
  });

  final double size;
  final bool showName;
  final bool showTagline;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final nameColor = onDark ? Colors.white : AppColors.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DsBrandMark(size: size, radius: size * 0.33),
        if (showName) ...[
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    style: text.titleLarge?.copyWith(
                      fontSize: size * 0.5,
                      fontWeight: FontWeight.w800,
                      color: nameColor,
                      letterSpacing: -0.3,
                    ),
                    children: [
                      const TextSpan(text: 'Break'),
                      TextSpan(
                        text: 'Bot',
                        style: TextStyle(
                          color: onDark
                              ? AppColors.primaryFixed
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showTagline)
                  Text(
                    t('عادات أفضل · حياة أفضل', 'Better habits · brighter you'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelSmall?.copyWith(
                      color: onDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class DsEmptyState extends StatelessWidget {
  const DsEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.auto_awesome_rounded,
    this.action,
  });

  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DsCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          DsIconBadge(icon: icon, size: 56, radius: 18),
          const SizedBox(height: 14),
          Text(title, style: text.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            message,
            style: text.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}

class DsHairline extends StatelessWidget {
  const DsHairline({super.key, this.vertical = 16});

  final double vertical;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical),
      child: Container(
        height: 1,
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkOutline
            : AppColors.outlineVariant.withValues(alpha: 0.45),
      ),
    );
  }
}

/// Consistent, localized snack feedback.
void showDsSnack(
  BuildContext context,
  String message, {
  bool success = false,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success
                  ? Icons.check_circle_rounded
                  : Icons.info_outline_rounded,
              color: success ? AppColors.tertiaryFixedDim : Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            success ? const Color(0xFF0F3D2E) : AppColors.onSurface,
        duration: const Duration(seconds: 3),
      ),
    );
}

/// Visual identity per habit, inferred from the habit name so that a habit
/// created by the user still looks at home in the design.
class HabitVisual {
  const HabitVisual(this.icon, this.foreground, this.background);

  final IconData icon;
  final Color foreground;
  final Color background;

  static HabitVisual forName(String name) {
    final n = name.toLowerCase();
    bool has(List<String> keys) => keys.any(n.contains);

    if (has(['ماء', 'مياه', 'شرب', 'hydration', 'water', 'سائل'])) {
      return const HabitVisual(
          Icons.water_drop_rounded, Color(0xFF1D4ED8), Color(0xFFDBE1FF));
    }
    if (has(['سكر', 'حلو', 'شهية', 'sugar', 'craving', 'snack', ' urge'])) {
      return const HabitVisual(
          Icons.cookie_rounded, Color(0xFFB45309), Color(0xFFFFDDB8));
    }
    if (has(['تنفس', 'تأمل', 'breath', 'medit', 'calm', 'استرخاء'])) {
      return const HabitVisual(
          Icons.self_improvement_rounded, Color(0xFF5B598C), Color(0xFFE3DFFF));
    }
    if (has(['شاشة', 'عين', 'screen', 'eye', '20-20', 'وقفة', 'break'])) {
      return const HabitVisual(
          Icons.visibility_rounded, Color(0xFF0F766E), Color(0xFFCCFBF1));
    }
    if (has(['شمس', 'صباح', 'sun', 'morning', 'مشي', 'walk'])) {
      return const HabitVisual(
          Icons.wb_sunny_rounded, Color(0xFFB45309), Color(0xFFFEF3C7));
    }
    if (has(['كتاب', 'قراءة', 'journal', 'write', 'كتابة', 'امتنان'])) {
      return const HabitVisual(
          Icons.menu_book_rounded, Color(0xFF15803D), Color(0xFFDCFCE7));
    }
    if (has(['رياضة', 'تمرين', 'exercise', 'workout', 'stretch'])) {
      return const HabitVisual(
          Icons.fitness_center_rounded, Color(0xFF9D174D), Color(0xFFFCE7F3));
    }
    return const HabitVisual(
        Icons.check_circle_rounded, AppColors.primary, AppColors.primaryFixed);
  }
}
