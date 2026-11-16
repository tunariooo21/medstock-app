import 'package:flutter/material.dart';

import 'app_state.dart';
import 'auth_service.dart';
import 'info_screens.dart';
import 'l10n.dart';
import 'language_screen.dart';
import 'security_screen.dart';

class SettingsScreen extends StatelessWidget {
  final Session session;
  final VoidCallback onLogout;
  const SettingsScreen({
    super.key,
    required this.session,
    required this.onLogout,
  });

  Future<void> _cixis(BuildContext context) async {
    final tesdiq = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('cixis_suali')),
        content: Text(t('cixis_izah')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t('legv_et')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t('cixis')),
          ),
        ],
      ),
    );
    if (tesdiq == true && context.mounted) {
      Navigator.of(context).popUntil((r) => r.isFirst);
      onLogout();
    }
  }

  void _ac(BuildContext context, Widget sehife) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => sehife));
  }

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
        title: Text(t('parametrler')),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _BolmeBasligi(t('sexsi_parametrler')),
            _AyarKarti(
              children: [
                _AyarSati(
                  ikon: Icons.language_rounded,
                  ad: t('dil'),
                  alt: switch (AppState.instance.dil) {
                    Dil.az => t('az_dil'),
                    Dil.en => t('en_dil'),
                    Dil.ru => t('ru_dil'),
                  },
                  onTap: () => _ac(context, const LanguageScreen()),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _BolmeBasligi(t('umumi_parametrler')),
            _AyarKarti(
              children: [
                _AyarSati(
                  ikon: Icons.dark_mode_outlined,
                  ad: t('qaranliq_rejim'),
                  son: Switch(
                    value: AppState.instance.qaranliq,
                    onChanged: (v) => AppState.instance.qaranliqSec(v),
                  ),
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                _AyarSati(
                  ikon: Icons.shield_outlined,
                  ad: t('tehlukesizlik'),
                  onTap: () => _ac(context, const SecurityScreen()),
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                _AyarSati(
                  ikon: Icons.description_outlined,
                  ad: t('sertler_qaydalar'),
                  onTap: () => _ac(context, const ShertlerEkrani()),
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                _AyarSati(
                  ikon: Icons.help_outline_rounded,
                  ad: t('tez_tez_suallar'),
                  onTap: () => _ac(context, const FaqEkrani()),
                ),
              ],
            ),
            const SizedBox(height: 28),
            InkWell(
              onTap: () => _cixis(context),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 4,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      size: 22,
                      color: Color(0xFFD32F2F),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      t('cixis_et'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BolmeBasligi extends StatelessWidget {
  final String metn;
  const _BolmeBasligi(this.metn);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: Text(
        metn,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _AyarKarti extends StatelessWidget {
  final List<Widget> children;
  const _AyarKarti({required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: children),
      ),
    );
  }
}

class _AyarSati extends StatelessWidget {
  final IconData ikon;
  final String ad;
  final String? alt;
  final Widget? son;
  final VoidCallback? onTap;
  const _AyarSati({
    required this.ikon,
    required this.ad,
    this.alt,
    this.son,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(ikon, size: 21, color: scheme.onSurface),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                ad,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface,
                ),
              ),
            ),
            if (alt != null)
              Text(
                alt!,
                style: TextStyle(
                  fontSize: 12.5,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            if (alt != null) const SizedBox(width: 6),
            if (son != null)
              son!
            else if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: scheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
