import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'auth_service.dart';
import 'home_shell.dart';
import 'login_screen.dart';
import 'api_client.dart';

import 'package:flutter_localizations/flutter_localizations.dart';


void main() => runApp(const MedStockApp());

class MedStockApp extends StatelessWidget {
  const MedStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedStock',
      theme: AppTheme.light(),
      locale: const Locale('az'),
      supportedLocales: const [Locale('az')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => Container(
        color: const Color(0xFFE1EAE8),
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: child,
        ),
      ),
      home: const KokEkran(),
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
    return HomeShell(session: s, onLogout: _cixis);
  }
}