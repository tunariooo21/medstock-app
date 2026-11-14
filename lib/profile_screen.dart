import 'package:flutter/material.dart';

import 'auth_service.dart';

String rolAdi(String rol) {
  switch (rol) {
    case 'representative':
      return 'Nümayəndə';
    case 'manager':
      return 'Menecer';
    default:    
      return rol;
  }
}

class ProfilEkrani extends StatelessWidget {
  final Session session;
  final VoidCallback onLogout;
  const ProfilEkrani({super.key, required this.session, required this.onLogout});

  Future<void> _parolDeyis(BuildContext context) async {
    final ugurlu = await showDialog<bool>(
      context: context,
      builder: (_) => const _ParolDialog(),
    );
    if (ugurlu == true && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Şifrə dəyişdirildi')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 8),
        const Center(
          child: CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
        ),
        const SizedBox(height: 16),
        Center(child: Text(session.ad, style: textTheme.headlineSmall)),
        const SizedBox(height: 4),
        Center(child: Text(rolAdi(session.rol))),
        const SizedBox(height: 24),
        Text('Bağlı regionlar', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        if (session.regionlar.isEmpty)
          const Text('Region təyin olunmayıb')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in session.regionlar) Chip(label: Text(r)),
            ],
          ),
        const SizedBox(height: 32),
        OutlinedButton.icon(
          onPressed: () => _parolDeyis(context),
          icon: const Icon(Icons.lock_outline),
          label: const Text('Şifrəni dəyiş'),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Çıxış'),
        ),
      ],
    );
  }
}

class _ParolDialog extends StatefulWidget {
  const _ParolDialog();

  @override
  State<_ParolDialog> createState() => _ParolDialogState();
}

class _ParolDialogState extends State<_ParolDialog> {
  final _kohne = TextEditingController();
  final _yeni = TextEditingController();
  final _tekrar = TextEditingController();
  String? _xeta;
  bool _yuklenir = false;

  @override
  void dispose() {
    _kohne.dispose();
    _yeni.dispose();
    _tekrar.dispose();
    super.dispose();
  }

  Future<void> _saxla() async {
    if (_kohne.text.isEmpty || _yeni.text.isEmpty || _tekrar.text.isEmpty) {
      setState(() => _xeta = 'Bütün xanaları doldur');
      return;
    }
    if (_yeni.text.length < 8) {
      setState(() => _xeta = 'Yeni şifrə ən azı 8 simvol olmalıdır');
      return;
    }
    if (_yeni.text != _tekrar.text) {
      setState(() => _xeta = 'Yeni şifrələr eyni deyil');
      return;
    }
    setState(() {
      _yuklenir = true;
      _xeta = null;
    });
    try {
      await AuthService.changePassword(_kohne.text, _yeni.text);
      if (mounted) Navigator.pop(context, true);
    } on AuthException catch (e) {
      if (mounted) setState(() => _xeta = e.mesaj);
    } finally {
      if (mounted) setState(() => _yuklenir = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Şifrəni dəyiş'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _kohne,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Köhnə şifrə'),
            ),
            TextField(
              controller: _yeni,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Yeni şifrə'),
            ),
            TextField(
              controller: _tekrar,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Yeni şifrəni təkrarla'),
            ),
            if (_xeta != null) ...[
              const SizedBox(height: 12),
              Text(_xeta!, style: TextStyle(color: scheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _yuklenir ? null : () => Navigator.pop(context, false),
          child: const Text('Ləğv et'),
        ),
        FilledButton(
          onPressed: _yuklenir ? null : _saxla,
          child: const Text('Saxla'),
        ),
      ],
    );
  }
}