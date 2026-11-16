import 'l10n.dart' hide ayAdi;

import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  final void Function(Session) onLoggedIn;
  const RegisterScreen({super.key, required this.onLoggedIn});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _ad = TextEditingController();
  final _login = TextEditingController();
  final _email = TextEditingController();
  final _parol = TextEditingController();
  final _tekrar = TextEditingController();
  String? _xeta;
  bool _yuklenir = false;
  bool _parolGorunur = false;
  bool _tekrarGorunur = false;

  static final _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  void dispose() {
    _ad.dispose();
    _login.dispose();
    _email.dispose();
    _parol.dispose();
    _tekrar.dispose();
    super.dispose();
  }

  String? _yoxla() {
    final ad = _ad.text.trim();
    final login = _login.text.trim();
    final email = _email.text.trim();
    if (ad.length < 2) return t('Adınızı yaz');
    if (login.length < 3) return t('İstifadəçi adı ən azı 3 simvol olmalıdır');
    if (login.contains(' ')) return t('İstifadəçi adında boşluq olmamalıdır');
    if (!_emailRe.hasMatch(email)) return t('E-poçt ünvanı düzgün deyil');
    if (_parol.text.length < 8) return t('Şifrə ən azı 8 simvol olmalıdır');
    if (_parol.text != _tekrar.text) return t('Şifrələr eyni deyil');
    return null;
  }

  Future<void> _qeydiyyat() async {
    final xeta = _yoxla();
    if (xeta != null) {
      setState(() => _xeta = xeta);
      return;
    }
    setState(() {
      _yuklenir = true;
      _xeta = null;
    });
    try {
      final session = await AuthService.register(
        ad: _ad.text.trim(),
        login: _login.text.trim(),
        email: _email.text.trim().toLowerCase(),
        parol: _parol.text,
      );
      if (!mounted) return;
      Navigator.of(context).popUntil((r) => r.isFirst);
      widget.onLoggedIn(session);
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _xeta = e.mesaj);
      }
    } finally {
      if (mounted) setState(() => _yuklenir = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: const BackButton(),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AuthLogo(olcu: 30),
            SizedBox(width: 6),
            Text(
              'MedStock',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthBasliq(
                    basliq: t('Qeydiyyat'),
                    altYazi: t(
                      'Stok, satış və hesabatları bir yerdə idarə etmək üçün hesab yaradın.',
                    ),
                  ),
                  const SizedBox(height: 24),
                  AuthSahe(
                    controller: _ad,
                    etiket: t('İstifadəçi adınız'),
                    hint: t('Ad və soyad'),
                    ikon: Icons.person_outline_rounded,
                    boyukHerf: TextCapitalization.words,
                    hereket: TextInputAction.next,
                    avtoDoldurma: const [AutofillHints.name],
                  ),
                  const SizedBox(height: 16),
                  AuthSahe(
                    controller: _login,
                    etiket: t('Giriş adı'),
                    hint: t('məsələn: elvin.h'),
                    ikon: Icons.alternate_email_rounded,
                    hereket: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  AuthSahe(
                    controller: _email,
                    etiket: t('E-poçt ünvanınız'),
                    hint: t('nümunə@mail.com'),
                    ikon: Icons.mail_outline_rounded,
                    klaviatura: TextInputType.emailAddress,
                    hereket: TextInputAction.next,
                    avtoDoldurma: const [AutofillHints.email],
                  ),
                  const SizedBox(height: 16),
                  AuthSahe(
                    controller: _parol,
                    etiket: t('Şifrəniz'),
                    hint: t('Ən azı 8 simvol'),
                    ikon: Icons.lock_outline_rounded,
                    sirli: !_parolGorunur,
                    hereket: TextInputAction.next,
                    avtoDoldurma: const [AutofillHints.newPassword],
                    sonIkon: IconButton(
                      tooltip: _parolGorunur
                          ? t('Şifrəni gizlət')
                          : t('Şifrəni göstər'),
                      onPressed: () =>
                          setState(() => _parolGorunur = !_parolGorunur),
                      icon: Icon(
                        _parolGorunur
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
                    hint: t('Şifrəni təkrar yazın'),
                    ikon: Icons.lock_outline_rounded,
                    sirli: !_tekrarGorunur,
                    hereket: TextInputAction.done,
                    teleqraf: (_) => _qeydiyyat(),
                    sonIkon: IconButton(
                      tooltip: _tekrarGorunur
                          ? t('Şifrəni gizlət')
                          : t('Şifrəni göstər'),
                      onPressed: () =>
                          setState(() => _tekrarGorunur = !_tekrarGorunur),
                      icon: Icon(
                        _tekrarGorunur
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: const Color(0xFF8E9790),
                      ),
                    ),
                  ),
                  AuthXeta(mesaj: _xeta),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _yuklenir ? null : _qeydiyyat,
                      child: _yuklenir
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            )
                          : Text(t('Qeydiyyatdan keçin')),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: AltKecid(
                      sual: t('Artıq hesabınız var?'),
                      kecid: t('Daxil olun'),
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
