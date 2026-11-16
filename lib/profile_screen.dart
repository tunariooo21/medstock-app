import 'dart:convert';

import 'l10n.dart' hide ayAdi;

import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'stock_request_service.dart';
import 'theme/app_theme.dart';

String rolAdi(String rol) {
  switch (rol) {
    case 'representative':
      return t('Tibbi nümayəndə');
    case 'manager':
      return t('Menecer');
    case 'admin':
      return t('Admin');
    default:
      return rol;
  }
}

class ProfilEkrani extends StatefulWidget {
  final Session session;
  final VoidCallback onLogout;
  final void Function(Session)? onSessionChanged;
  const ProfilEkrani({
    super.key,
    required this.session,
    required this.onLogout,
    this.onSessionChanged,
  });

  @override
  State<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends State<ProfilEkrani> {
  late Session _session = widget.session;
  late Future<Map<String, dynamic>> _menecer = StokTalebServisi.secimler();

  @override
  void didUpdateWidget(covariant ProfilEkrani oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.session != oldWidget.session) _session = widget.session;
  }

  Future<void> _redakte() async {
    final yeni = await Navigator.of(context).push<Session>(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          session: _session,
          onSessionChanged: (yeni) {
            setState(() => _session = yeni);
            widget.onSessionChanged?.call(yeni);
          },
        ),
      ),
    );
    if (yeni != null && mounted) {
      setState(() => _session = yeni);
      widget.onSessionChanged?.call(yeni);
    }
  }

  Future<void> _parametrler() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            SettingsScreen(session: _session, onLogout: widget.onLogout),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ad = _session.ad.trim();
    final herf = ad.isEmpty ? '?' : ad[0].toUpperCase();
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Container(
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.yumshagEsas(context),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x14112012),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: _session.photo == null
                        ? Text(
                            herf,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.esas(context),
                            ),
                          )
                        : ClipOval(
                            child: Image.memory(
                              base64Decode(_session.photo!.split(',').last),
                              width: 66,
                              height: 66,
                              fit: BoxFit.cover,
                              semanticLabel: t('profil_sekli'),
                            ),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          ad,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          rolAdi(_session.rol),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.esas(context),
                          ),
                        ),
                        if ((_session.email ?? '').isNotEmpty) ...[
                          SizedBox(height: 3),
                          Text(
                            _session.email!,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppTheme.kicik(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: t('Parametrlər'),
                    onPressed: _parametrler,
                    icon: Icon(
                      Icons.settings_outlined,
                      size: 22,
                      color: AppTheme.esas(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _redakte,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(t('Profili redaktə et')),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(64, 46),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ],
          ),
        ),
        if ((_session.email ?? '').isEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6E8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF3DFC0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: Color(0xFF8A5D17),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t(
                      'Hesaba e-poçt əlavə olunmayıb. Şifrə bərpası üçün adminlə əlaqə saxlayın.',
                    ),
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: Color(0xFF8A5D17),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 22),
        Padding(
          padding: EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(
            t('Hesab məlumatları'),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: AppTheme.kicik(context),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              _MelumatSati(
                ikon: Icons.alternate_email_rounded,
                etiket: t('Giriş adı'),
                deyer: _session.login.isEmpty ? '—' : _session.login,
              ),
              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              _MelumatSati(
                ikon: Icons.mail_outline_rounded,
                etiket: t('E-poçt'),
                deyer: (_session.email ?? '').isEmpty ? '—' : _session.email!,
              ),
              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              _MelumatSati(
                ikon: Icons.phone_outlined,
                etiket: t('Telefon'),
                deyer: (_session.telefon ?? '').isEmpty
                    ? '—'
                    : _session.telefon!,
              ),
              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              _MelumatSati(
                ikon: Icons.chat_outlined,
                etiket: 'WhatsApp',
                deyer: (_session.whatsapp ?? '').isEmpty
                    ? '—'
                    : _session.whatsapp!,
              ),
            ],
          ),
        ),
        if (_session.rol == 'representative') ...[
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(
              t('menecer'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Card(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _menecer,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          t(
                            'Məlumat yüklənmədi. Bir az sonra yenidən cəhd et.',
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            _menecer = StokTalebServisi.secimler();
                          }),
                          child: Text(t('Yenidən cəhd et')),
                        ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final data = snapshot.data!;
                return data['manager_ad'] == null
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(t('menecer_teyin_olunmayib')),
                      )
                    : Column(
                        children: [
                          _MelumatSati(
                            ikon: Icons.person_outline,
                            etiket: t('Ad və soyad'),
                            deyer: data['manager_ad'] as String,
                          ),
                          const Divider(height: 1),
                          _MelumatSati(
                            ikon: Icons.mail_outline,
                            etiket: t('E-poçt'),
                            deyer: 'manager@example.com',
                          ),
                          const Divider(height: 1),
                          _MelumatSati(
                            ikon: Icons.phone_outlined,
                            etiket: t('Telefon'),
                            deyer: '+994 XX XXX XX XX',
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                            child: Text(
                              t('menecer_elaqe_numune'),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.kicik(context)),
                            ),
                          ),
                        ],
                      );
              },
            ),
          ),
        ],
        const SizedBox(height: 22),
        Padding(
          padding: EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(
            t('Bağlı regionlar'),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: AppTheme.kicik(context),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: _session.regionlar.isEmpty
              ? Text(
                  t('Region təyin olunmayıb. Adminlə əlaqə saxlayın.'),
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppTheme.kicik(context),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final r in _session.regionlar) Chip(label: Text(r)),
                  ],
                ),
        ),
      ],
    );
  }
}

class _MelumatSati extends StatelessWidget {
  final IconData ikon;
  final String etiket;
  final String deyer;
  const _MelumatSati({
    required this.ikon,
    required this.etiket,
    required this.deyer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(ikon, size: 19, color: AppTheme.kicik(context)),
          SizedBox(width: 12),
          Text(
            etiket,
            style: TextStyle(fontSize: 13.5, color: AppTheme.kicik(context)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              deyer,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
