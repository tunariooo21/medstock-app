import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Əsas palitra (petrol) — istifadəçinin seçimi:
  // əsas rəng #0E7490, fon #F6F9FA, kartlar ağ.
  static const Color esasReng = Color(0xFF0E7490);
  static const Color esasRengTund = Color(0xFF0A5568);
  static const Color esasYumshag = Color(0xFFE3F1F5);
  static const Color fon = Color(0xFFF6F9FA);
  static const Color yazi = Color(0xFF0F172A);
  static const Color cizgi = Color(0xFFE2E8F0);
  static const Color kicikYazi = Color(0xFF475569);

  // Qaranlıq rejim
  static const Color fonDark = Color(0xFF0F1A20);
  static const Color kartDark = Color(0xFF182830);
  static const Color yaziDark = Color(0xFFE6EEF2);
  static const Color kicikYaziDark = Color(0xFF8FA3AD);
  static const Color cizgiDark = Color(0xFF2A3D47);
  static const Color esasRengDark = Color(0xFF2AA8C7);

  // Status rəngləri — hər iki rejimdə eyni, mənası sabitdir
  static const Color ugur = Color(0xFF15803D);
  static const Color xeta = Color(0xFFD32F2F);
  static const Color azQalib = Color(0xFFE8833A);
  static const Color bitib = Color(0xFFD32F2F);

  // Dərman rəngləri — sabit, heç vaxt dəyişmir
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

  // Rejim-əsaslı rənglər — qaranlıq rejimdə düzgün dəyər verir.
  // Yalnız build() və ya context-in olduğu yerdə istifadə edin.
  static Color kicik(BuildContext c) =>
      Theme.of(c).colorScheme.onSurfaceVariant;

  static Color esas(BuildContext c) => Theme.of(c).colorScheme.primary;

  static Color yumshagEsas(BuildContext c) =>
      Theme.of(c).colorScheme.primary.withValues(alpha: 0.12);

  static ThemeData light() => _qur(
    qaranliq: false,
    esas: esasReng,
    fonReng: fon,
    kart: Colors.white,
    yaziReng: yazi,
    kicik: kicikYazi,
    xett: cizgi,
    snackbar: const Color(0xFF132A33),
  );

  static ThemeData dark() => _qur(
    qaranliq: true,
    esas: esasRengDark,
    fonReng: fonDark,
    kart: kartDark,
    yaziReng: yaziDark,
    kicik: kicikYaziDark,
    xett: cizgiDark,
    snackbar: const Color(0xFF1C323D),
  );

  static ThemeData _qur({
    required bool qaranliq,
    required Color esas,
    required Color fonReng,
    required Color kart,
    required Color yaziReng,
    required Color kicik,
    required Color xett,
    required Color snackbar,
  }) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: esas,
          primary: esas,
          surface: kart,
          brightness: qaranliq ? Brightness.dark : Brightness.light,
        ).copyWith(
          onPrimary: qaranliq ? fonDark : Colors.white,
          primaryContainer: esas,
          onPrimaryContainer: qaranliq ? fonDark : Colors.white,
          onSurface: yaziReng,
          onSurfaceVariant: kicik,
          outline: kicik,
          outlineVariant: xett,
        );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final tt = base.textTheme;
    final text = tt.copyWith(
      displaySmall: tt.displaySmall?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: yaziReng,
      ),
      headlineMedium: tt.headlineMedium?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: yaziReng,
      ),
      headlineSmall: tt.headlineSmall?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        color: yaziReng,
      ),
      titleLarge: tt.titleLarge?.copyWith(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: yaziReng,
      ),
      titleMedium: tt.titleMedium?.copyWith(
        fontSize: 15.5,
        fontWeight: FontWeight.w700,
        color: yaziReng,
      ),
      titleSmall: tt.titleSmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: kicik,
      ),
      bodyLarge: tt.bodyLarge?.copyWith(fontSize: 15, color: yaziReng),
      bodyMedium: tt.bodyMedium?.copyWith(fontSize: 14, color: yaziReng),
      bodySmall: tt.bodySmall?.copyWith(fontSize: 12.5, color: kicik),
      labelLarge: tt.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: xett),
    );

    return base.copyWith(
      scaffoldBackgroundColor: fonReng,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: kart,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: yaziReng),
        systemOverlayStyle: qaranliq
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color: yaziReng,
        ),
      ),
      cardTheme: CardThemeData(
        color: kart,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: xett),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kart,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        hintStyle: TextStyle(fontSize: 14, color: kicik),
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: yaziReng,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: esas, width: 1.6),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: xeta),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: xeta, width: 1.6),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: kart,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: xett,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: kart,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: yaziReng,
        ),
        contentTextStyle: TextStyle(fontSize: 14.5, color: yaziReng),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: kart,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: qaranliq ? esas.withValues(alpha: 0.18) : esasYumshag,
        indicatorShape: const StadiumBorder(),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected) ? esas : kicik,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
            color: states.contains(WidgetState.selected) ? esas : kicik,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          elevation: 0,
          backgroundColor: kart,
          foregroundColor: yaziReng,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          side: BorderSide(color: xett),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: esas,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: qaranliq ? kart : const Color(0xFFEDF3F5),
        surfaceTintColor: Colors.transparent,
        side: BorderSide.none,
        labelStyle: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: yaziReng,
        ),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      dividerTheme: DividerThemeData(color: xett, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: snackbar,
        contentTextStyle: const TextStyle(fontSize: 14, color: Colors.white),
        elevation: 2,
        insetPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: esas,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        focusElevation: 2,
        highlightElevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: esas),
      listTileTheme: ListTileThemeData(iconColor: kicik),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(fontSize: 14.5, color: yaziReng),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(kart),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: xett),
            ),
          ),
        ),
      ),
    );
  }
}
