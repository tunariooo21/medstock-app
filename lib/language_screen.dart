import 'package:flutter/material.dart';

import 'app_state.dart';
import 'l10n.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const _diller = [
    (Dil.az, 'az_dil'),
    (Dil.en, 'en_dil'),
    (Dil.ru, 'ru_dil'),
  ];

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: AppState.instance,
    builder: (context, _) => _qur(context),
  );

  Widget _qur(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(t('dil')),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                t('dil_seçimi_izah'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: scheme.outlineVariant),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  for (var i = 0; i < _diller.length; i++) ...[
                    _DilSati(
                      ad: t(_diller[i].$2),
                      secili: AppState.instance.dil == _diller[i].$1,
                      onTap: () => AppState.instance.dilSec(_diller[i].$1),
                    ),
                    if (i != _diller.length - 1)
                      Divider(height: 1, color: scheme.outlineVariant),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DilSati extends StatelessWidget {
  final String ad;
  final bool secili;
  final VoidCallback onTap;
  const _DilSati({required this.ad, required this.secili, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                ad,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: secili ? FontWeight.w700 : FontWeight.w500,
                  color: scheme.onSurface,
                ),
              ),
            ),
            Icon(
              secili ? Icons.check_circle : Icons.circle_outlined,
              size: 22,
              color: secili ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
