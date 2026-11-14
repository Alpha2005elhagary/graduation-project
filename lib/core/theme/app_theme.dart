import 'package:flutter/material.dart';

/// Stitch design tokens — BreakBot.
///
/// Extracted from the authoritative Stitch design system (Tailwind config in
/// `design_reference/stitch/*.html`). Primary blue, lavender-tinted surfaces
/// and generous 20–28px radii define the visual language.
class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF004AC6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF2563EB);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);
  static const Color primaryFixed = Color(0xFFDBE1FF);
  static const Color primaryFixedDim = Color(0xFFB4C5FF);
  static const Color onPrimaryFixed = Color(0xFF00174B);

  // Secondary (soft violet)
  static const Color secondary = Color(0xFF5B598C);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFC7C3FE);
  static const Color onSecondaryContainer = Color(0xFF1B1A47);
  static const Color secondaryFixed = Color(0xFFE3DFFF);
  static const Color secondaryFixedDim = Color(0xFFC7C3FE);

  // Tertiary (warm amber — warnings, risk and streaks)
  static const Color tertiary = Color(0xFF784B00);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFDDB8);
  static const Color onTertiaryContainer = Color(0xFF281900);
  static const Color tertiaryFixed = Color(0xFFFFDDB8);
  static const Color tertiaryFixedDim = Color(0xFFFFB95F);

  // Surfaces
  static const Color background = Color(0xFFFAF8FF);
  static const Color surface = Color(0xFFFAF8FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F3FF);
  static const Color surfaceContainer = Color(0xFFEAEDFF);
  static const Color surfaceContainerHigh = Color(0xFFE2E7FF);
  static const Color surfaceContainerHighest = Color(0xFFDAE2FD);

  // Text
  static const Color onSurface = Color(0xFF131B2E);
  static const Color onSurfaceVariant = Color(0xFF434655);
  static const Color outline = Color(0xFF737686);
  static const Color outlineVariant = Color(0xFFC3C6D7);

  // Semantic
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);

  static const Color success = Color(0xFF0F7B4F);
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color onSuccessContainer = Color(0xFF053B25);

  static const Color warning = Color(0xFFB45309);
  static const Color warningContainer = Color(0xFFFFEDD5);
  static const Color onWarningContainer = Color(0xFF4A2600);

  static const Color info = Color(0xFF2563EB);
  static const Color infoContainer = Color(0xFFDBE1FF);

  // Dark surfaces
  static const Color darkBackground = Color(0xFF0B1020);
  static const Color darkSurface = Color(0xFF131A2C);
  static const Color darkSurfaceHigh = Color(0xFF1B2438);
  static const Color darkOutline = Color(0xFF2A3550);
  static const Color darkOnSurface = Color(0xFFF1F3FF);
  static const Color darkOnSurfaceVariant = Color(0xFFA9B2CC);
}

class AppTheme {
  AppTheme._();

  /// Kept for backwards compatibility with the rest of the codebase.
  static const Color primary = AppColors.primary;
  static const Color primaryDark = Color(0xFF003EA8);
  static const Color primaryLight = AppColors.primaryFixed;
  static const Color accent = AppColors.secondary;
  static const Color surface = AppColors.background;
  static const Color surfaceDark = AppColors.darkBackground;
  static const Color cardDark = AppColors.darkSurface;
  static const Color error = AppColors.error;
  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;
  static const Color textPrimary = AppColors.onSurface;
  static const Color textSecondary = AppColors.onSurfaceVariant;

  // Legacy aliases
  static const Color primaryColor = primary;
  static const Color accentColor = accent;
  static const Color surfaceColor = surface;
  static const Color dangerColor = error;
  static const Color errorColor = error;
  static const Color successColor = success;
  static const Color warningColor = warning;
  static const Color textPrimaryColor = textPrimary;
  static const Color textSecondaryColor = textSecondary;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primaryContainer, AppColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF004AC6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softGradient = LinearGradient(
    colors: [Color(0xFFF2F3FF), Color(0xFFFAF8FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Latin copy uses Plus Jakarta Sans; Arabic uses Cairo.
  static String fontFamilyFor(String languageCode) =>
      languageCode == 'en' ? 'PlusJakartaSans' : 'Cairo';

  static TextTheme _textTheme(String languageCode) {
    final family = fontFamilyFor(languageCode);
    const fallback = <String>['Noto Sans', 'Arial'];
    TextStyle style({
      required double size,
      required FontWeight weight,
      required Color color,
      double height = 1.4,
      double? spacing,
    }) {
      return TextStyle(
        fontFamily: family,
        fontFamilyFallback: fallback,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: spacing,
      );
    }

    return TextTheme(
      displayLarge: style(
          size: 44, weight: FontWeight.w800, color: AppColors.onSurface, height: 1.15, spacing: -1),
      displayMedium: style(
          size: 36, weight: FontWeight.w800, color: AppColors.onSurface, height: 1.18, spacing: -0.7),
      displaySmall: style(
          size: 30, weight: FontWeight.w800, color: AppColors.onSurface, height: 1.2, spacing: -0.4),
      headlineLarge: style(
          size: 28, weight: FontWeight.w800, color: AppColors.onSurface, height: 1.25, spacing: -0.3),
      headlineMedium: style(
          size: 24, weight: FontWeight.w700, color: AppColors.onSurface, height: 1.3),
      headlineSmall: style(
          size: 21, weight: FontWeight.w700, color: AppColors.onSurface, height: 1.3),
      titleLarge: style(
          size: 19, weight: FontWeight.w700, color: AppColors.onSurface, height: 1.35),
      titleMedium: style(
          size: 16, weight: FontWeight.w600, color: AppColors.onSurface, height: 1.4),
      titleSmall: style(
          size: 14, weight: FontWeight.w600, color: AppColors.onSurface, height: 1.4),
      bodyLarge: style(
          size: 15, weight: FontWeight.w400, color: AppColors.onSurfaceVariant, height: 1.6),
      bodyMedium: style(
          size: 13, weight: FontWeight.w400, color: AppColors.onSurfaceVariant, height: 1.6),
      bodySmall: style(
          size: 12, weight: FontWeight.w400, color: AppColors.onSurfaceVariant, height: 1.55),
      labelLarge: style(
          size: 14, weight: FontWeight.w700, color: AppColors.onSurface, height: 1.3),
      labelMedium: style(
          size: 12, weight: FontWeight.w600, color: AppColors.onSurfaceVariant, height: 1.3),
      labelSmall: style(
          size: 11,
          weight: FontWeight.w600,
          color: AppColors.onSurfaceVariant,
          height: 1.3,
          spacing: 0.4),
    );
  }

  static ThemeData lightTheme({String languageCode = 'ar'}) {
    final family = fontFamilyFor(languageCode);
    final textTheme = _textTheme(languageCode);
    const scheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryFixed,
      onPrimaryContainer: AppColors.onPrimaryFixed,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryFixed,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: family,
      brightness: Brightness.light,
      colorScheme: scheme,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
      textTheme: textTheme,
      dividerColor: AppColors.outlineVariant.withValues(alpha: 0.55),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.55)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.outlineVariant,
          elevation: 0,
          minimumSize: const Size(0, 54),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge?.copyWith(
            color: AppColors.onPrimary,
            fontFamily: family,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge?.copyWith(
            color: AppColors.onPrimary,
            fontFamily: family,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.9)),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge?.copyWith(
            color: AppColors.primary,
            fontFamily: family,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          textStyle: textTheme.labelLarge?.copyWith(
            color: AppColors.primary,
            fontFamily: family,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.onSurfaceVariant,
          highlightColor: AppColors.primaryFixed,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.outline),
        labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
        floatingLabelStyle:
            textTheme.labelMedium?.copyWith(color: AppColors.primary),
        prefixIconColor: AppColors.onSurfaceVariant,
        suffixIconColor: AppColors.onSurfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.6),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.onSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontFamily: family,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.outlineVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.surfaceContainer,
        side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        labelStyle: textTheme.labelMedium ?? const TextStyle(),
        secondaryLabelStyle:
            textTheme.labelMedium?.copyWith(color: Colors.white),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.surfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return AppColors.outlineVariant;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.primaryFixed,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.12),
        trackHeight: 6,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryFixed,
        circularTrackColor: AppColors.primaryFixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        height: 72,
        indicatorColor: AppColors.primaryFixed,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
            size: 24,
          );
        }),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        iconColor: AppColors.onSurfaceVariant,
        textColor: AppColors.onSurface,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: textTheme.bodyMedium?.copyWith(color: AppColors.onSurface),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.onSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: Colors.white),
      ),
    );
  }

  static ThemeData darkTheme({String languageCode = 'ar'}) {
    final family = fontFamilyFor(languageCode);
    final light = _textTheme(languageCode);
    final textTheme = light.copyWith(
      displayLarge: light.displayLarge?.copyWith(color: AppColors.darkOnSurface),
      displayMedium: light.displayMedium?.copyWith(color: AppColors.darkOnSurface),
      displaySmall: light.displaySmall?.copyWith(color: AppColors.darkOnSurface),
      headlineLarge: light.headlineLarge?.copyWith(color: AppColors.darkOnSurface),
      headlineMedium:
          light.headlineMedium?.copyWith(color: AppColors.darkOnSurface),
      headlineSmall: light.headlineSmall?.copyWith(color: AppColors.darkOnSurface),
      titleLarge: light.titleLarge?.copyWith(color: AppColors.darkOnSurface),
      titleMedium: light.titleMedium?.copyWith(color: AppColors.darkOnSurface),
      titleSmall: light.titleSmall?.copyWith(color: AppColors.darkOnSurface),
      bodyLarge:
          light.bodyLarge?.copyWith(color: AppColors.darkOnSurfaceVariant),
      bodyMedium:
          light.bodyMedium?.copyWith(color: AppColors.darkOnSurfaceVariant),
      bodySmall:
          light.bodySmall?.copyWith(color: AppColors.darkOnSurfaceVariant),
      labelLarge: light.labelLarge?.copyWith(color: AppColors.darkOnSurface),
      labelMedium:
          light.labelMedium?.copyWith(color: AppColors.darkOnSurfaceVariant),
      labelSmall:
          light.labelSmall?.copyWith(color: AppColors.darkOnSurfaceVariant),
    );

    const scheme = ColorScheme.dark(
      primary: Color(0xFFB4C5FF),
      onPrimary: Color(0xFF00174B),
      primaryContainer: Color(0xFF003EA8),
      onPrimaryContainer: Color(0xFFDBE1FF),
      secondary: Color(0xFFC7C3FE),
      onSecondary: Color(0xFF2C2A5A),
      secondaryContainer: Color(0xFF434174),
      onSecondaryContainer: Color(0xFFE3DFFF),
      tertiary: Color(0xFFFFB95F),
      onTertiary: Color(0xFF412D00),
      tertiaryContainer: Color(0xFF5E3C00),
      onTertiaryContainer: Color(0xFFFFDDB8),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkOnSurface,
      onSurfaceVariant: AppColors.darkOnSurfaceVariant,
      outline: Color(0xFF8D96AF),
      outlineVariant: AppColors.darkOutline,
      surfaceContainerLowest: Color(0xFF070C18),
      surfaceContainerLow: AppColors.darkSurface,
      surfaceContainer: AppColors.darkSurfaceHigh,
      surfaceContainerHigh: Color(0xFF222D44),
      surfaceContainerHighest: Color(0xFF2A3550),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: family,
      brightness: Brightness.dark,
      colorScheme: scheme,
      primaryColor: scheme.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      canvasColor: AppColors.darkBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.darkOnSurface),
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.darkOutline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(0, 54),
          elevation: 0,
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge?.copyWith(
            color: scheme.onPrimary,
            fontFamily: family,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceHigh,
        hintStyle: textTheme.bodyMedium?.copyWith(color: const Color(0xFF8D96AF)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkSurfaceHigh,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: AppColors.darkOnSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        height: 72,
        indicatorColor: const Color(0xFF003EA8),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? scheme.primary : AppColors.darkOnSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.primary : AppColors.darkOnSurfaceVariant,
            size: 24,
          );
        }),
      ),
      dividerColor: AppColors.darkOutline,
    );
  }
}
