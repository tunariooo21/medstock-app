import 'l10n.dart' hide ayAdi;

import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'theme/app_theme.dart';
import 'widgets/auth_widgets.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _kohne = TextEditingController();
  final _yeni = TextEditingController();
  final _tekrar = TextEditingController();
  String? _xeta;
  bool _yuklenir = false;
  bool _kohneGorunur = false;
  bool _yeniGorunur = false;

  @override
  void dispose() {
    _kohne.dispose();
    _yeni.dispose();
    _tekrar.dispose();
    super.dispose();
  }

  Future<void> _saxla() async {
    if (_kohne.text.isEmpty || _yeni.text.isEmpty || _tekrar.text.isEmpty) {
      setState(() => _xeta = t('Bütün xanaları doldur'));
      return;
    }
    if (_yeni.text.length < 8) {
      setState(() => _xeta = t('Yeni şifrə ən azı 8 simvol olmalıdır'));
      return;
    }
    if (_yeni.text != _tekrar.text) {
      setState(() => _xeta = t('Yeni şifrələr eyni deyil'));
      return;
    }
    setState(() {
      _yuklenir = true;
      _xeta = null;
    });
    try {
      await AuthService.changePassword(_kohne.text, _yeni.text);
      if (!mounted) return;
      _kohne.clear();
      _yeni.clear();
      _tekrar.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t('Şifrə uğurla dəyişdirildi'))));
    } on AuthException catch (e) {
      if (mounted) setState(() => _xeta = e.mesaj);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(t('Təhlükəsizlik')),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('Şifrəni dəyişdirin'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    t(
                      'Hesabınızın təhlükəsizliyi üçün şifrəni müntəzəm yeniləyin.',
                    ),
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: AppTheme.kicik(context),
                    ),
                  ),
                  const SizedBox(height: 22),
                  AuthSahe(
                    controller: _kohne,
                    etiket: t('Cari şifrə'),
                    hint: t('Mövcud şifrəniz'),
                    ikon: Icons.lock_outline_rounded,
                    sirli: !_kohneGorunur,
                    hereket: TextInputAction.next,
                    sonIkon: IconButton(
                      tooltip: _kohneGorunur
                          ? t('Şifrəni gizlət')
                          : t('Şifrəni göstər'),
                      onPressed: () =>
                          setState(() => _kohneGorunur = !_kohneGorunur),
                      icon: Icon(
                        _kohneGorunur
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: const Color(0xFF8E9790),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AuthSahe(
                    controller: _yeni,
                    etiket: t('Yeni şifrə'),
                    hint: t('Ən azı 8 simvol'),
                    ikon: Icons.lock_reset_rounded,
                    sirli: !_yeniGorunur,
                    hereket: TextInputAction.next,
                    sonIkon: IconButton(
                      tooltip: _yeniGorunur
                          ? t('Şifrəni gizlət')
                          : t('Şifrəni göstər'),
                      onPressed: () =>
                          setState(() => _yeniGorunur = !_yeniGorunur),
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
                    etiket: t('Yeni şifrəni təkrarla'),
                    hint: t('Yeni şifrəni təkrar yazın'),
                    ikon: Icons.lock_outline_rounded,
                    sirli: true,
                    hereket: TextInputAction.done,
                    teleqraf: (_) => _saxla(),
                  ),
                  AuthXeta(mesaj: _xeta),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _yuklenir ? null : _saxla,
                      child: _yuklenir
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            )
                          : Text(t('Yadda saxla')),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppTheme.kicik(context),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t(
                              'Şifrənizi unutmusunuzsa, giriş ekranındakı “Şifrəni unutmusunuz?” keçidindən istifadə edin. E-poçtunuza təsdiq kodu göndəriləcək.',
                            ),
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.45,
                              color: AppTheme.kicik(context),
                            ),
                          ),
                        ),
                      ],
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
