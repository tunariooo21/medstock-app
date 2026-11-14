import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'theme/app_theme.dart';

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

  Future<void> _daxilOl() async {
    final login = _login.text.trim();
    final parol = _parol.text;
    if (login.isEmpty || parol.isEmpty) {
      setState(() => _xeta = 'Login və şifrəni yaz');
      return;
    }
    setState(() {
      _yuklenir = true;
      _xeta = null;
    });
    try {
      final session = await AuthService.login(login, parol);
      widget.onLoggedIn(session);
    } on AuthException catch (e) {
      setState(() => _xeta = e.mesaj);
    } finally {
      if (mounted) setState(() => _yuklenir = false);
    }
  }

  @override
  void dispose() {
    _login.dispose();
    _parol.dispose();
    super.dispose();
  }

  Widget _etiket(String metn) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(metn,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tema = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppTheme.esasReng,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 38),
                  ),
                  const SizedBox(height: 18),
                  Text('MedStock',
                      style: tema.headlineMedium?.copyWith(
                          fontSize: 34, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Stok, satış və aylıq hesabat bir yerdə',
                      style: tema.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 36),
                  _etiket('Login'),
                  TextField(
                    controller: _login,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                  ),
                  const SizedBox(height: 16),
                  _etiket('Şifrə'),
                  TextField(
                    controller: _parol,
                    obscureText: true,
                    onSubmitted: (_) => _daxilOl(),
                  ),
                  if (_xeta != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_xeta!,
                          style: TextStyle(color: scheme.onErrorContainer)),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _yuklenir ? null : _daxilOl,
                      child: _yuklenir
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Daxil ol'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text('Giriş məlumatlarını admin verir',
                        style: tema.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
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