import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medstock_app/edit_profile_screen.dart';
import 'package:medstock_app/home_shell.dart';
import 'package:medstock_app/manager_reports_screen.dart';
import 'package:medstock_app/notifications_screen.dart';
import 'package:medstock_app/profile_screen.dart';
import 'package:medstock_app/returns_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medstock_app/app_state.dart';
import 'package:medstock_app/auth_service.dart';
import 'package:medstock_app/l10n.dart';
import 'package:medstock_app/stock_request_screen.dart';
import 'package:medstock_app/stock_request_service.dart';
import 'package:medstock_app/stock_screen.dart';
import 'package:medstock_app/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppState.instance.yukle();
  });

  testWidgets('Manager home opens returns directly and summary is compact', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    final now = DateTime.now();
    final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final returns = {
      'ay': month,
      'cemi': 7,
      'dermanlar': [
        {'medicine_id': 1, 'ad': 'Summary medicine', 'cemi': 7},
      ],
      'siyahi': [
        {
          'id': 1,
          'tarix': '$month-01',
          'derman': 'Returned medicine',
          'point_ad': 'Pharmacy',
          'point_novu': 'aptek',
          'say': 7,
          'sebeb': 'Reason',
          'isci_ad': 'Rep',
        },
      ],
    };
    final client = MockClient((request) async {
      final data = switch (request.url.path) {
        '/regions' => [
          {'id': 1, 'ad': 'Region'},
        ],
        '/stock' => {
          'ay': month,
          'cari_ay': true,
          'asagi_hedd': 20,
          'cemi': [
            {
              'medicine_id': 1,
              'ad': 'Medicine',
              'sira': 0,
              'qaliq': 35,
              'satilib': 0,
              'resept': 0,
            },
          ],
          'noqteler': [],
        },
        '/manager/returns' => returns,
        '/notifications' => {'unread': 0, 'items': []},
        '/manager/reports' => {'iscilar': []},
        '/stock-requests' => [],
        '/reports/summary' => {
          'ay': month,
          'cemi': 0,
          'evvelki_cemi': 0,
          'dermanlar': [],
          'hekimler': [],
          'son_6_ay': [],
        },
        '/prices' => {'dermanlar': []},
        '/medicines' => [],
        _ => throw StateError('Unexpected request: ${request.url.path}'),
      };
      return http.Response(jsonEncode(data), 200);
    });
    await http.runWithClient(() async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: HomeShell(
            session: Session(ad: 'Manager', rol: 'manager'),
            onLogout: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      final monthText = ayAdi(month);
      expect(
        find.text('${monthText[0].toUpperCase()}${monthText.substring(1)}'),
        findsOneWidget,
      );
      expect(find.textContaining('icmalı'), findsNothing);
      await tester.tap(find.text(t('geri_qaytarma')));
      await tester.pumpAndSettle();
      expect(find.byType(GeriQaytarmalarEkrani), findsOneWidget);
      expect(
        tester
            .widget<MenecerHesabatlarEkrani>(
              find.byType(MenecerHesabatlarEkrani),
            )
            .controller
            .index,
        2,
      );
      expect(find.text(t('stok_telebi')), findsOneWidget);
      expect(find.byIcon(Icons.priority_high), findsNothing);
      expect(find.text('Summary medicine'), findsNothing);
      expect(find.text('Returned medicine · Pharmacy'), findsOneWidget);
      final summary = find.byWidgetPredicate(
        (w) =>
            w is Card &&
            w.color == AppTheme.light().colorScheme.primaryContainer,
      );
      expect(
        find.descendant(of: summary, matching: find.text('7')),
        findsOneWidget,
      );
      tester
              .widget<MenecerHesabatlarEkrani>(
                find.byType(MenecerHesabatlarEkrani),
              )
              .controller
              .index =
          1;
      await tester.pumpAndSettle();
      await tester.tap(find.text(t('ana_sehife')));
      await tester.pumpAndSettle();
      returns['cemi'] = 9;
      await tester.tap(find.text(t('geri_qaytarma')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<MenecerHesabatlarEkrani>(
              find.byType(MenecerHesabatlarEkrani),
            )
            .controller
            .index,
        2,
      );
      expect(
        find.descendant(of: summary, matching: find.text('9')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }, () => client);
  });

  testWidgets(
    'Read notifications disappear; a failed detail fetch leaves them unread',
    (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      var read = false;
      var allowDetail = false;
      var reads = 0;
      final client = MockClient((request) async {
        if (request.url.path == '/notifications') {
          return http.Response(
            jsonEncode({
              'unread': read ? 0 : 1,
              'items': [
                {
                  'id': 1,
                  'request_id': 1,
                  'kind': 'submitted',
                  'read': read,
                  'user_ad': 'Unread Rep',
                },
                {
                  'id': 2,
                  'request_id': 2,
                  'kind': 'submitted',
                  'read': true,
                  'user_ad': 'Already read Rep',
                },
              ],
            }),
            200,
          );
        }
        if (request.url.path == '/stock-requests/1') {
          if (!allowDetail) {
            return http.Response('{"detail":"Stok tələbi tapılmadı"}', 404);
          }
          return http.Response(
            jsonEncode({
              'id': 1,
              'user_ad': 'Unread Rep',
              'status': 'gonderildi',
              'menecer_serhi': null,
              'created_at': '2026-11-16',
              'setirler': [],
            }),
            200,
          );
        }
        if (request.url.path == '/notifications/1/read' &&
            request.method == 'POST') {
          read = true;
          reads++;
          return http.Response('{}', 200);
        }
        throw StateError('Unexpected request: ${request.url.path}');
      });
      await http.runWithClient(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: const BildirislerEkrani(menecer: true),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.textContaining('Already read Rep'), findsNothing);
        await tester.tap(find.byType(ListTile));
        await tester.pumpAndSettle();
        expect(reads, 0);
        expect(find.byType(ListTile), findsOneWidget);
        allowDetail = true;
        await tester.tap(find.byType(ListTile));
        await tester.pumpAndSettle();
        expect(reads, 1);
        expect(find.byType(StokTalebDetali), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byType(ListTile), findsNothing);
        expect(find.text(t('bildiris_yoxdur')), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }, () => client);
    },
  );

  testWidgets(
    'Representative profile shows assigned manager and photo editing stays in edit profile',
    (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      const png =
          'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAEklEQVR4nGPkK5nAwMDAxAAGAAyAARbzUYiSAAAAAElFTkSuQmCC';
      late Directory folder;
      late String photoPath;
      await tester.runAsync(() async {
        folder = await Directory.systemTemp.createTemp('medstock-photo-test-');
        photoPath = '${folder.path}/photo.png';
        await File(photoPath).writeAsBytes(base64Decode(png));
      });
      addTearDown(() => folder.delete(recursive: true));
      const pickerChannel = MethodChannel('plugins.flutter.io/image_picker');
      String? selectedPath = photoPath;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        pickerChannel,
        (_) async => selectedPath,
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          pickerChannel,
          null,
        ),
      );
      String? photo;
      var uploads = 0;
      Session? changed;
      final client = MockClient((request) async {
        if (request.url.path == '/stock-requests/options') {
          return http.Response('{"manager_ad":"Manager Example"}', 200);
        }
        if (request.url.path == '/me/photo') {
          if (request.method == 'PUT') {
            uploads++;
            photo = (jsonDecode(request.body) as Map)['data'] as String;
          } else if (request.method == 'DELETE') {
            photo = null;
          } else {
            throw StateError('Unexpected photo method');
          }
          return http.Response(
            jsonEncode({
              'ad': 'Rep',
              'rol': 'representative',
              'login': 'rep',
              'email': 'rep@example.com',
              'photo': photo,
            }),
            200,
          );
        }
        throw StateError('Unexpected request: ${request.url.path}');
      });
      await http.runWithClient(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: ProfilEkrani(
                session: Session(
                  ad: 'Rep',
                  rol: 'representative',
                  login: 'rep',
                  email: 'rep@example.com',
                ),
                onLogout: () {},
                onSessionChanged: (session) => changed = session,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(TextButton), findsNothing);
        await tester.ensureVisible(find.text('Manager Example'));
        await tester.pumpAndSettle();
        expect(find.text('manager@example.com'), findsOneWidget);
        expect(find.text('+994 XX XXX XX XX'), findsOneWidget);
        expect(find.text(t('menecer_elaqe_numune')), findsOneWidget);
        await tester.ensureVisible(find.text(t('Profili redaktə et')));
        await tester.pumpAndSettle();
        await tester.tap(find.text(t('Profili redaktə et')));
        await tester.pumpAndSettle();
        expect(find.byType(EditProfileScreen), findsOneWidget);
        await tester.runAsync(() async {
          await tester.tap(find.byIcon(Icons.edit_rounded));
          await Future<void>.delayed(const Duration(milliseconds: 200));
        });
        await tester.pumpAndSettle();
        expect(uploads, 1);
        expect(changed?.photo, isNotNull);
        expect(find.byType(Image), findsOneWidget);
        await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
        await tester.pumpAndSettle();
        expect(find.byType(Image), findsOneWidget);
        await tester.tap(find.text(t('Profili redaktə et')));
        await tester.pumpAndSettle();
        selectedPath = null;
        await tester.tap(find.byIcon(Icons.edit_rounded));
        await tester.pumpAndSettle();
        expect(uploads, 1);
        await tester.tap(find.text(t('sekli_sil')));
        await tester.pumpAndSettle();
        expect(changed?.photo, isNull);
        expect(find.byType(Image), findsNothing);
        await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
        await tester.pumpAndSettle();
        expect(find.byType(Image), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }, () => client);
    },
  );

  testWidgets(
    'Missing manager is explicit and profile remains usable after lookup failure',
    (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      var fail = true;
      final client = MockClient(
        (request) async => fail
            ? http.Response('{"detail":"Unavailable"}', 503)
            : http.Response('{"manager_ad":null}', 200),
      );
      await http.runWithClient(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: ProfilEkrani(
                session: Session(
                  ad: 'Rep',
                  rol: 'representative',
                  login: 'rep',
                ),
                onLogout: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(t('Yenidən cəhd et')));
        fail = false;
        await tester.tap(find.text(t('Yenidən cəhd et')));
        await tester.pumpAndSettle();
        expect(find.text(t('menecer_teyin_olunmayib')), findsOneWidget);
        expect(find.text('manager@example.com'), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }, () => client);
    },
  );

  testWidgets('Stock refreshes on approval, polling, tab return and resume', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    var qaliq = 5;
    var sorgular = 0;
    Completer<http.Response>? pending;
    Map<String, dynamic> stockData() => {
      'ay': '2026-11',
      'cari_ay': true,
      'asagi_hedd': 20,
      'cemi': [
        {
          'medicine_id': 1,
          'ad': 'Medicine',
          'sira': 0,
          'qaliq': qaliq,
          'satilib': 0,
          'resept': 0,
        },
      ],
      'noqteler': [
        {
          'id': 1,
          'ad': 'Pharmacy',
          'novu': 'aptek',
          'dermanlar': [
            {
              'medicine_id': 1,
              'ad': 'Medicine',
              'sira': 0,
              'qaliq': qaliq,
              'daxilolma': qaliq,
              'satilib': 0,
              'resept': 0,
              'status': qaliq < 20 ? 'az' : 'normal',
            },
          ],
        },
      ],
    };
    final client = MockClient((request) async {
      switch (request.url.path) {
        case '/regions':
          return http.Response('[{"id":1,"ad":"Region"}]', 200);
        case '/medicines':
          return http.Response('[{"id":1,"ad":"Medicine","sira":0}]', 200);
        case '/stock':
          sorgular++;
          return pending?.future ?? http.Response(jsonEncode(stockData()), 200);
        default:
          throw StateError('Unexpected request: ${request.url.path}');
      }
    });
    await http.runWithClient(() async {
      Widget app(bool aktiv) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: StokEkrani(aktiv: aktiv)),
      );
      await tester.pumpWidget(app(true));
      await tester.pumpAndSettle();
      expect(find.text('5'), findsNWidgets(2));
      qaliq = 35;
      StokTalebServisi.deyisdi.value++;
      await tester.pumpAndSettle();
      expect(find.text('35'), findsNWidgets(2));
      qaliq = 45;
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();
      expect(find.text('45'), findsNWidgets(2));
      await tester.pumpWidget(app(false));
      final beforeHidden = sorgular;
      await tester.pump(const Duration(seconds: 30));
      expect(sorgular, beforeHidden);
      qaliq = 55;
      await tester.pumpWidget(app(true));
      await tester.pumpAndSettle();
      expect(find.text('55'), findsNWidgets(2));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      final beforePaused = sorgular;
      await tester.pump(const Duration(seconds: 30));
      expect(sorgular, beforePaused);
      qaliq = 65;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('65'), findsNWidgets(2));
      pending = Completer<http.Response>();
      final beforePending = sorgular;
      StokTalebServisi.deyisdi.value++;
      await tester.pump();
      await tester.pump(const Duration(seconds: 30));
      expect(sorgular, beforePending + 1);
      qaliq = 75;
      pending!.complete(http.Response(jsonEncode(stockData()), 200));
      pending = null;
      await tester.pumpAndSettle();
      expect(find.text('75'), findsNWidgets(2));
      await tester.pumpWidget(const SizedBox.shrink());
      final beforeDispose = sorgular;
      await tester.pump(const Duration(seconds: 30));
      expect(sorgular, beforeDispose);
      expect(tester.takeException(), isNull);
    }, () => client);
  });

  test('Request rows and profile photo deserialize', () {
    final request = StokTalebi.fromJson({
      'id': 7,
      'user_ad': 'Rep',
      'status': 'gozleyir',
      'menecer_serhi': 'Tomorrow',
      'created_at': '2026-11-16',
      'setirler': [
        {
          'point_id': 2,
          'point_ad': 'Pharmacy',
          'medicine_id': 3,
          'medicine_ad': 'Medicine',
          'sira': 2,
          'say': 45,
        },
      ],
    });
    expect(request.setirler.single.say, 45);
    expect(request.serh, 'Tomorrow');
    expect(
      Session.fromJson({
        'ad': 'Rep',
        'rol': 'representative',
        'photo': 'data:image/jpeg;base64,AA==',
      }).photo,
      isNotNull,
    );
  });

  testWidgets(
    'Held request shows approval but not duplicate hold action on a narrow Russian dark screen',
    (tester) async {
      await AppState.instance.dilSec(Dil.ru);
      tester.view.physicalSize = const Size(320, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          locale: const Locale('ru'),
          supportedLocales: const [Locale('az'), Locale('en'), Locale('ru')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: const StokTalebDetali(
            taleb: StokTalebi(
              id: 1,
              userAd: 'Rep',
              status: 'gozleyir',
              serh: 'Tomorrow',
              tarix: '2026-11-16',
              setirler: [
                TalebSetri(
                  pointId: 1,
                  pointAd: 'Pharmacy',
                  medicineId: 1,
                  medicineAd: 'Medicine',
                  sira: 0,
                  say: 50,
                ),
              ],
            ),
            menecer: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(t('taleb_gozleyir')), findsOneWidget);
      expect(find.text(t('telebi_gozlet')), findsNothing);
      expect(find.text(t('telebi_tesdiqle')), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Approval and hold confirmations explain their stock effects', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const StokTalebDetali(
          taleb: StokTalebi(
            id: 1,
            userAd: 'Rep',
            status: 'gonderildi',
            serh: null,
            tarix: '2026-11-16',
            setirler: [],
          ),
          menecer: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(t('telebi_gozlet')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text(t('gozlet_stoku_deyismir')),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text(t('legv_et')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t('telebi_tesdiqle')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text(t('tesdiq_mal_daxilolmasi')),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text(t('legv_et')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Approved representative detail has no manager actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const StokTalebDetali(
          taleb: StokTalebi(
            id: 1,
            userAd: 'Rep',
            status: 'tesdiqlendi',
            serh: null,
            tarix: '2026-11-16',
            setirler: [],
          ),
          menecer: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(t('taleb_tesdiqlendi')), findsOneWidget);
    expect(find.text(t('telebi_tesdiqle')), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
  });
}
