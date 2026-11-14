import 'package:flutter/material.dart';

class AppTheme {
  static const Color esasReng = Color(0xFF0B6E63);
  static const Color fon = Color(0xFFF3F7F6);
  static const Color yazi = Color(0xFF12302C);
  static const Color cizgi = Color(0xFFE1EAE8);

  static const List<Color> dermanRengleri = [
    Color(0xFF2979D6),
    Color(0xFFEF6A35),
    Color(0xFF17B07A),
    Color(0xFF8E5BD6),
    Color(0xFFD6A62B),
    Color(0xFFD65B8E),
  ];

  static Color dermanRengi(int sira) =>
      dermanRengleri[sira % dermanRengleri.length];

  static const Color azQalib = Color(0xFFE8833A);
  static const Color bitib = Color(0xFFD32F2F);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: esasReng,
      primary: esasReng,
      surface: Colors.white,
    ).copyWith(
      primaryContainer: esasReng,
      onPrimaryContainer: Colors.white,
      onSurface: yazi,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final tt = base.textTheme;
    final kicik = tt.copyWith(
      displaySmall: tt.displaySmall?.copyWith(fontSize: 30),
      headlineMedium: tt.headlineMedium?.copyWith(fontSize: 24),
      headlineSmall: tt.headlineSmall?.copyWith(fontSize: 22),
      titleLarge: tt.titleLarge?.copyWith(fontSize: 18),
      titleMedium: tt.titleMedium?.copyWith(fontSize: 15),
      titleSmall: tt.titleSmall?.copyWith(fontSize: 13),
      bodyLarge: tt.bodyLarge?.copyWith(fontSize: 14),
      bodyMedium: tt.bodyMedium?.copyWith(fontSize: 13),
      bodySmall: tt.bodySmall?.copyWith(fontSize: 11.5),
    );

    return base.copyWith(
      scaffoldBackgroundColor: fon,
      textTheme: kicik,
      appBarTheme: const AppBarTheme(
        backgroundColor: fon,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: yazi,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: cizgi),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF9FB5B1)),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: fon,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Color(0xFFD5EBE7),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}