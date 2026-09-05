import 'package:flutter/material.dart';

class AppTheme {
  // Dark palette
  static const dBg = Color(0xFF0C0C0E);
  static const dBg2 = Color(0xFF141418);
  static const dPanel = Color(0xFF1A1A1F);
  static const dPanel2 = Color(0xFF222228);
  static const dLine = Color(0xFF2E2E36);
  static const dLineSoft = Color(0xFF25252C);
  static const dFg = Color(0xFFE8E6E3);
  static const dMuted = Color(0xFF8A8790);
  static const dSubtle = Color(0xFF5C5A63);

  // Light palette
  static const lBg = Color(0xFFF4F1EC);
  static const lBg2 = Color(0xFFECE7DF);
  static const lPanel = Color(0xFFFFFCF8);
  static const lPanel2 = Color(0xFFF0EBE3);
  static const lLine = Color(0xFFD4CFC6);
  static const lLineSoft = Color(0xFFE0D9D0);
  static const lFg = Color(0xFF1C1A18);
  static const lMuted = Color(0xFF6B6660);
  static const lSubtle = Color(0xFF9A948C);

  // Shared
  static const accent = Color(0xFFC45C26);
  static const accentDim = Color(0xFF8B3D18);
  static const ok = Color(0xFF3D8B5C);
  static const okDim = Color(0xFF2A5C3D);
  static const danger = Color(0xFFC43C2E);

  static TextStyle pixelTitle({Color? color, double size = 11}) => TextStyle(
        fontFamily: 'monospace',
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        height: 1.4,
        color: color,
      );

  static TextStyle pixelSmall({Color? color, double size = 9}) => TextStyle(
        fontFamily: 'monospace',
        fontSize: size,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        height: 1.5,
        color: color,
      );

  static TextStyle body({Color? color, double size = 14, FontWeight? weight}) =>
      TextStyle(
        fontFamily: 'monospace',
        fontSize: size,
        fontWeight: weight ?? FontWeight.w400,
        height: 1.45,
        color: color,
      );

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lBg,
      colorScheme: const ColorScheme.light(
        surface: lPanel,
        primary: accent,
        onPrimary: Colors.white,
        secondary: accentDim,
        onSurface: lFg,
        error: danger,
        outline: lLine,
      ),
    );
    return _finish(base, dark: false);
  }

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: dBg,
      colorScheme: const ColorScheme.dark(
        surface: dPanel,
        primary: accent,
        onPrimary: dFg,
        secondary: accentDim,
        onSurface: dFg,
        error: danger,
        outline: dLine,
      ),
    );
    return _finish(base, dark: true);
  }

  static ThemeData _finish(ThemeData base, {required bool dark}) {
    final bg2 = dark ? dBg2 : lBg2;
    final panel = dark ? dPanel : lPanel;
    final line = dark ? dLine : lLine;
    final fg = dark ? dFg : lFg;
    final muted = dark ? dMuted : lMuted;
    final subtle = dark ? dSubtle : lSubtle;
    final chipBg = dark ? const Color(0xFF241810) : const Color(0xFFF5E6D8);
    final shadowColor = dark ? Colors.black : const Color(0x33000000);

    return base.copyWith(
      textTheme: base.textTheme.apply(bodyColor: fg, displayColor: fg),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: bg2,
        foregroundColor: fg,
        titleTextStyle: pixelTitle(color: fg, size: 11),
        shape: Border(bottom: BorderSide(color: line, width: 2)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: panel,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: line, width: 2),
        ),
      ),
      dividerColor: line,
      chipTheme: ChipThemeData(
        backgroundColor: panel,
        selectedColor: chipBg,
        side: BorderSide(color: line, width: 2),
        labelStyle: pixelSmall(color: subtle),
        secondaryLabelStyle: pixelSmall(color: fg),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: dark ? const Color(0xFF1A100C) : const Color(0xFFF5E6D8),
        foregroundColor: dark ? const Color(0xFFF0C9A8) : accentDim,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: accentDim, width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bg2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: line, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: line, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: accentDim, width: 2),
        ),
        labelStyle: body(color: muted, size: 13),
        hintStyle: body(color: subtle, size: 13),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: line, width: 2),
        ),
        titleTextStyle: pixelTitle(color: fg, size: 10),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: bg2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: line, width: 2),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: accent,
        unselectedLabelColor: subtle,
        indicatorColor: accent,
        labelStyle: pixelSmall(color: accent, size: 8),
        unselectedLabelStyle: pixelSmall(color: subtle, size: 8),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: body(size: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: dark ? const Color(0xFF1F140E) : const Color(0xFFF5E6D8),
          foregroundColor: dark ? const Color(0xFFE8B896) : accentDim,
          side: const BorderSide(color: accentDim, width: 2),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      canvasColor: shadowColor,
    );
  }
}

extension PixelCtx on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get pxBg => isDark ? AppTheme.dBg : AppTheme.lBg;
  Color get pxBg2 => isDark ? AppTheme.dBg2 : AppTheme.lBg2;
  Color get pxPanel => isDark ? AppTheme.dPanel : AppTheme.lPanel;
  Color get pxPanel2 => isDark ? AppTheme.dPanel2 : AppTheme.lPanel2;
  Color get pxLine => isDark ? AppTheme.dLine : AppTheme.lLine;
  Color get pxLineSoft => isDark ? AppTheme.dLineSoft : AppTheme.lLineSoft;
  Color get pxFg => isDark ? AppTheme.dFg : AppTheme.lFg;
  Color get pxMuted => isDark ? AppTheme.dMuted : AppTheme.lMuted;
  Color get pxSubtle => isDark ? AppTheme.dSubtle : AppTheme.lSubtle;
  Color get pxChipSelected =>
      isDark ? const Color(0xFF241810) : const Color(0xFFF5E6D8);
}