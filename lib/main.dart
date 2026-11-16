import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'app_state.dart';
import 'auth_service.dart';
import 'home_shell.dart';
import 'login_screen.dart';
import 'api_client.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.instance.yukle();
  runApp(const MedStockApp());
}

class MedStockApp extends StatelessWidget {
  const MedStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        final state = AppState.instance;
        return MaterialApp(
          title: 'MedStock',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: state.qaranliq ? ThemeMode.dark : ThemeMode.light,
          locale: Locale(state.dil.name),
          supportedLocales: const [Locale('az'), Locale('en'), Locale('ru')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          builder: (context, child) => Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: child,
            ),
          ),
          home: KokEkran(),
        );
      },
    );
  }
}

class KokEkran extends StatefulWidget {
  const KokEkran({super.key});

  @override
  State<KokEkran> createState() => _KokEkranState();
}

class _KokEkranState extends State<KokEkran> {
  Session? _session;
  bool _yoxlanir = true;

  @override
  void initState() {
    super.initState();
    // Token vaxtı bitəndə istənilən ekrandan giriş ekranına qayıt
    ApiClient.sessiyaBitdi = () {
      if (mounted) _cixis();
    };
    _baslat();
  }

  Future<void> _baslat() async {
    final s = await AuthService.restore();
    if (!mounted) return;
    setState(() {
      _session = s;
      _yoxlanir = false;
    });
  }

  Future<void> _cixis() async {
    await AuthService.logout();
    setState(() => _session = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_yoxlanir) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final s = _session;
    if (s == null) {
      return LoginScreen(onLoggedIn: (v) => setState(() => _session = v));
    }
    return HomeShell(
      session: s,
      onLogout: _cixis,
      onSessionChanged: (v) => setState(() => _session = v),
    );
  }
}
