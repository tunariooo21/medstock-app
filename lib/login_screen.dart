import 'l10n.dart' hide ayAdi;

import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  final void Function(Session) onLoggedIn;
  const LoginScreen({super.key, required this.onLoggedIn});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _login = TextEditingController();
  final _parol = TextEditingController();
  String? _xeta;
  bool _yuklenir = false;
  bool _parolGorunur = false;

  @override
  void dispose() {
    _login.dispose();
    _parol.dispose();
    super.dispose();
  }

  Future<void> _daxilOl() async {
    final login = _login.text.trim();
    final parol = _parol.text;
    if (login.isEmpty || parol.isEmpty) {
      setState(() => _xeta = t('E-poçt (və ya istifadəçi adı) və şifrəni yaz'));
      return;
    }
    setState(() {
      _yuklenir = true;
      _xeta = null;
    });
    try {
      final session = await AuthService.login(login, parol);
      if (mounted) widget.onLoggedIn(session);
    } on AuthException catch (e) {
      if (mounted) setState(() => _xeta = e.mesaj);
    } finally {
      if (mounted) setState(() => _yuklenir = false);
    }
  }

  void _qeydiyyataKec() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegisterScreen(onLoggedIn: widget.onLoggedIn),
      ),
    );
  }

  void _sifreniUnutdum() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, mehdudiyyet) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: mehdudiyyet.maxHeight - 52,
              ),
              child: IntrinsicHeight(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AuthLogo(),
                            const SizedBox(height: 26),
                            AuthBasliq(
                              basliq: t('Giriş'),
                              altYazi: t(
                                'Stok, satış və hesabatları idarə etmək üçün hesabınıza daxil olun.',
                              ),
                            ),
                            const SizedBox(height: 28),
                            AuthSahe(
                              controller: _login,
                              etiket: t('E-poçt və ya istifadəçi adı'),
                              hint: t('nümunə@mail.com'),
                              ikon: Icons.mail_outline_rounded,
                              klaviatura: TextInputType.emailAddress,
                              hereket: TextInputAction.next,
                              avtoDoldurma: const [
                                AutofillHints.username,
                                AutofillHints.email,
                              ],
                            ),
                            const SizedBox(height: 16),
                            AuthSahe(
                              controller: _parol,
                              etiket: t('Şifrəniz'),
                              hint: '••••••••',
                              ikon: Icons.lock_outline_rounded,
                              sirli: !_parolGorunur,
                              hereket: TextInputAction.done,
                              avtoDoldurma: const [AutofillHints.password],
                              teleqraf: (_) => _daxilOl(),
                              sonIkon: IconButton(
                                tooltip: _parolGorunur
                                    ? t('Şifrəni gizlət')
                                    : t('Şifrəni göstər'),
                                onPressed: () => setState(
                                  () => _parolGorunur = !_parolGorunur,
                                ),
                                icon: Icon(
                                  _parolGorunur
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: const Color(0xFF8E9790),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _yuklenir ? null : _sifreniUnutdum,
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 36),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  t('Şifrəni unutmusunuz?'),
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.kicik(context),
                                  ),
                                ),
                              ),
                            ),
                            AuthXeta(mesaj: _xeta),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _yuklenir ? null : _daxilOl,
                                child: _yuklenir
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      )
                                    : Text(t('Daxil olun')),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Center(
                            child: AltKecid(
                              sual: t('Hesabınız yoxdur?'),
                              kecid: t('Qeydiyyatdan keçin'),
                              onTap: _qeydiyyataKec,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
