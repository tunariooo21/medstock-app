import 'l10n.dart' hide ayAdi;

import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'theme/app_theme.dart';
import 'widgets/auth_widgets.dart';

enum _Addim { email, kod, ugur }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _kod = TextEditingController();
  final _yeni = TextEditingController();
  final _tekrar = TextEditingController();

  _Addim _addim = _Addim.email;
  String? _xeta;
  String? _demoKod;
  String? _resetToken;
  bool _yuklenir = false;
  bool _yeniGorunur = false;

  static final _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  void dispose() {
    _email.dispose();
    _kod.dispose();
    _yeni.dispose();
    _tekrar.dispose();
    super.dispose();
  }

  Future<void> _kodGonder() async {
    final email = _email.text.trim().toLowerCase();
    if (!_emailRe.hasMatch(email)) {
      setState(() => _xeta = t('E-poçt ünvanı düzgün deyil'));
      return;
    }
    setState(() {
      _yuklenir = true;
      _xeta = null;
    });
    try {
      final netice = await AuthService.forgotPassword(email);
      if (!mounted) return;
      setState(() {
        _resetToken = null;
        _demoKod = netice.demo ? netice.kod : null;
        _addim = _Addim.kod;
        _kod.clear();
        _yeni.clear();
        _tekrar.clear();
      });
    } on AuthException catch (e) {
      if (mounted) setState(() => _xeta = e.mesaj);
    } finally {
      if (mounted) setState(() => _yuklenir = false);
    }
  }

  Future<void> _yaddaSaxla() async {
    final kod = _kod.text.trim();
    if (kod.length != 6) {
      setState(() => _xeta = t('6 rəqəmli təsdiq kodunu yaz'));
      return;
    }
    if (_yeni.text.length < 8) {
      setState(() => _xeta = t('Yeni şifrə ən azı 8 simvol olmalıdır'));
      return;
    }
    if (_yeni.text != _tekrar.text) {
      setState(() => _xeta = t('Şifrələr eyni deyil'));
      return;
    }
    setState(() {
      _yuklenir = true;
      _xeta = null;
    });
    try {
      final token = _resetToken ??= await AuthService.verifyCode(
        _email.text.trim().toLowerCase(),
        kod,
      );
      await AuthService.resetPassword(token, _yeni.text);
      if (!mounted) return;
      setState(() => _addim = _Addim.ugur);
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _xeta = e.mesaj;
          _resetToken = null;
        });
      }
    } finally {
      if (mounted) setState(() => _yuklenir = false);
    }
  }

  void _geri() {
    if (_addim == _Addim.kod) {
      setState(() {
        _addim = _Addim.email;
        _xeta = null;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ugur = _addim == _Addim.ugur;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: ugur
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: _yuklenir ? null : _geri,
              ),
        automaticallyImplyLeading: false,
        title: Text(t('Şifrə bərpası')),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: switch (_addim) {
                  _Addim.email => _emailAddimi(),
                  _Addim.kod => _kodAddimi(),
                  _Addim.ugur => _ugurAddimi(),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailAddimi() {
    return Column(
      key: const ValueKey('email'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthBasliq(
          basliq: t('Şifrəni yeniləyin'),
          altYazi: t(
            'E-poçt ünvanınızı daxil edin — təsdiq kodunu göndərək və yeni şifrə yaradın.',
          ),
        ),
        const SizedBox(height: 26),
        AuthSahe(
          controller: _email,
          etiket: t('E-poçt ünvanınız'),
          hint: t('nümunə@mail.com'),
          ikon: Icons.mail_outline_rounded,
          klaviatura: TextInputType.emailAddress,
          hereket: TextInputAction.done,
          teleqraf: (_) => _kodGonder(),
        ),
        AuthXeta(mesaj: _xeta),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _yuklenir ? null : _kodGonder,
            child: _yuklenir
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : Text(t('Kod göndərin')),
          ),
        ),
      ],
    );
  }

  Widget _kodAddimi() {
    return Column(
      key: const ValueKey('kod'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthBasliq(
          basliq: t('Yeni şifrə yaradın'),
          altYazi: t(
            'E-poçtunuza göndərilən 6 rəqəmli kodu və yeni şifrənizi yazın.',
          ),
        ),
        if (_demoKod != null) ...[
          const SizedBox(height: 18),
          MelumatZolagi(
            ikon: Icons.mark_email_read_outlined,
            mesaj:
                '${t('Demo rejimi (SMTP qurulmayıb). Təsdiq kodunuz')}: $_demoKod',
          ),
        ],
        const SizedBox(height: 22),
        AuthSahe(
          controller: _kod,
          etiket: t('Təsdiq kodu'),
          hint: t('6 rəqəmli kod'),
          ikon: Icons.password_rounded,
          klaviatura: TextInputType.number,
          hereket: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        AuthSahe(
          controller: _yeni,
          etiket: t('Yeni şifrə'),
          hint: t('Ən azı 8 simvol'),
          ikon: Icons.lock_outline_rounded,
          sirli: !_yeniGorunur,
          hereket: TextInputAction.next,
          sonIkon: IconButton(
            tooltip: _yeniGorunur ? t('Şifrəni gizlət') : t('Şifrəni göstər'),
            onPressed: () => setState(() => _yeniGorunur = !_yeniGorunur),
            icon: Icon(
              _yeniGorunur
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: const Color(0xFF8E9790),
            ),
          ),
        ),
        const SizedBox(height: 16),
        AuthSahe(
          controller: _tekrar,
          etiket: t('Yenidən şifrəniz'),
          hint: t('Yeni şifrəni təkrar yazın'),
          ikon: Icons.lock_outline_rounded,
          sirli: true,
          hereket: TextInputAction.done,
          teleqraf: (_) => _yaddaSaxla(),
        ),
        AuthXeta(mesaj: _xeta),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _yuklenir ? null : _yaddaSaxla,
            child: _yuklenir
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : Text(t('Yadda saxlayın')),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: _yuklenir ? null : _kodGonder,
            child: Text(t('Kodu yenidən göndər')),
          ),
        ),
      ],
    );
  }

  Widget _ugurAddimi() {
    return Column(
      key: ValueKey('ugur'),
      children: [
        SizedBox(height: 72),
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            color: AppTheme.yumshagEsas(context),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.shield_outlined,
            size: 54,
            color: AppTheme.esas(context),
          ),
        ),
        SizedBox(height: 28),
        Text(
          t('Şifrəniz uğurla yeniləndi!'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 10),
        Text(
          t(
            'Şifrəniz uğurla yeniləndi. Daxil olma prosesinə davam edə bilərsiniz.',
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: AppTheme.kicik(context),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t('Davam edin')),
          ),
        ),
      ],
    );
  }
}
