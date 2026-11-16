import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medstock_app/app_state.dart';
import 'package:medstock_app/auth_service.dart';
import 'package:medstock_app/info_screens.dart';
import 'package:medstock_app/l10n.dart';
import 'package:medstock_app/settings_screen.dart';
import 'package:medstock_app/theme/app_theme.dart';
import 'package:medstock_app/widgets/auth_widgets.dart';
import 'package:medstock_app/widgets/state_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance();
  final y = b.computeLuminance();
  return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppState.instance.yukle();
  });

  test(
    'All literal translation calls resolve in English and Russian',
    () async {
      final keys = <String>{};
      final pattern = RegExp(r"\bt\('([^'\n]*)'\)");
      for (final file in Directory(
        'lib',
      ).listSync(recursive: true).whereType<File>()) {
        if (!file.path.endsWith('.dart')) continue;
        keys.addAll(
          pattern.allMatches(file.readAsStringSync()).map((m) => m[1]!),
        );
      }
      final missing = <String>[];
      for (final language in [Dil.en, Dil.ru]) {
        await AppState.instance.dilSec(language);
        for (final key in keys) {
          if (t(key) == key) missing.add('${language.name}: $key');
        }
      }
      expect(missing, isEmpty);
    },
  );

  test('Month labels and unknown messages', () async {
    await AppState.instance.dilSec(Dil.en);
    expect(ayAdi('2026-11'), 'November 2026');
    expect(L10n.qisaAyAdi('2026-11'), 'Nov');
    await AppState.instance.dilSec(Dil.ru);
    expect(ayAdi('2026-11'), 'ноябрь 2026');
    expect(L10n.qisaAyAdi('2026-11'), 'Ноя');
    expect(ayAdi('invalid'), 'invalid');
    expect(t('Unmapped external message'), 'Unmapped external message');
  });

  test('Language and dark mode survive reload', () async {
    await AppState.instance.dilSec(Dil.ru);
    await AppState.instance.qaranliqSec(true);
    AppState.instance.dil = Dil.az;
    AppState.instance.qaranliq = false;
    await AppState.instance.yukle();
    expect(AppState.instance.dil, Dil.ru);
    expect(AppState.instance.qaranliq, isTrue);
  });

  test('Theme preserves palette and readable foregrounds', () {
    expect(AppTheme.light().colorScheme.primary, const Color(0xFF0E7490));
    expect(AppTheme.light().scaffoldBackgroundColor, const Color(0xFFF6F9FA));
    expect(AppTheme.light().cardTheme.color, Colors.white);
    expect(AppTheme.dermanRengleri, const [
      Color(0xFF2979D6),
      Color(0xFFEF6A35),
      Color(0xFF17B07A),
      Color(0xFF8E5BD6),
      Color(0xFFD6A62B),
      Color(0xFFD65B8E),
    ]);
    expect(AppTheme.ugur, const Color(0xFF15803D));
    expect(AppTheme.azQalib, const Color(0xFFE8833A));
    expect(AppTheme.bitib, const Color(0xFFD32F2F));
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      final scheme = theme.colorScheme;
      expect(
        contrast(scheme.onSurface, scheme.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(scheme.onSurfaceVariant, scheme.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(scheme.onPrimary, scheme.primary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(scheme.onPrimaryContainer, scheme.primaryContainer),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  testWidgets('Settings switch language immediately and retain route', (
    tester,
  ) async {
    await tester.pumpWidget(
      AnimatedBuilder(
        animation: AppState.instance,
        builder: (context, _) => MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: AppState.instance.qaranliq
              ? ThemeMode.dark
              : ThemeMode.light,
          locale: Locale(AppState.instance.dil.name),
          supportedLocales: const [Locale('az'), Locale('en'), Locale('ru')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: SettingsScreen(
            session: Session(ad: 'Test', rol: 'representative'),
            onLogout: () {},
          ),
        ),
      ),
    );
    await tester.tap(find.text(t('dil')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t('en_dil')));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(AppState.instance.qaranliq, isTrue);
    expect(
      Theme.of(tester.element(find.byType(Switch))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('Selected dropdown labels update without changing month', (
    tester,
  ) async {
    const selectedMonth = '2026-11';
    await tester.pumpWidget(
      AnimatedBuilder(
        animation: AppState.instance,
        builder: (context, _) => MaterialApp(
          locale: Locale(AppState.instance.dil.name),
          supportedLocales: const [Locale('az'), Locale('en'), Locale('ru')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Builder(
            builder: (context) => Scaffold(
              body: DropdownMenu<String>(
                key: ValueKey('month-${Localizations.localeOf(context)}'),
                initialSelection: selectedMonth,
                dropdownMenuEntries: [
                  DropdownMenuEntry(
                    value: selectedMonth,
                    label: ayAdi(selectedMonth),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'noyabr 2026',
    );
    await AppState.instance.dilSec(Dil.ru);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'ноябрь 2026',
    );
    await AppState.instance.dilSec(Dil.en);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'November 2026',
    );
  });

  testWidgets('Terms, FAQ and defaults translate at render time', (
    tester,
  ) async {
    await AppState.instance.dilSec(Dil.en);
    await tester.pumpWidget(MaterialApp(home: const ShertlerEkrani()));
    expect(find.text('1. Use of the service'), findsOneWidget);
    await tester.pumpWidget(MaterialApp(home: const FaqEkrani()));
    expect(find.text('How do I recover my password?'), findsOneWidget);
    await tester.tap(find.text('How do I recover my password?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('6-digit code'), findsOneWidget);
    await tester.pumpWidget(MaterialApp(home: XetaHali(onYeniden: () {})));
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('Russian auth links fit narrow phone', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await AppState.instance.dilSec(Dil.ru);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: AltKecid(
              sual: t('Artıq hesabınız var?'),
              kecid: t('Daxil olun'),
              onTap: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
