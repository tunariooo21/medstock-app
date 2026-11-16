import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'api_client.dart';
import 'auth_service.dart';
import 'l10n.dart' hide ayAdi;
import 'theme/app_theme.dart';
import 'widgets/auth_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  final Session session;
  final void Function(Session)? onSessionChanged;
  const EditProfileScreen({
    super.key,
    required this.session,
    this.onSessionChanged,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _ad = TextEditingController(
    text: widget.session.ad,
  );
  late final TextEditingController _telefon = TextEditingController(
    text: widget.session.telefon ?? '',
  );
  late final TextEditingController _whatsapp = TextEditingController(
    text: widget.session.whatsapp ?? '',
  );
  late Session _session = widget.session;
  String? _xeta;
  bool _yuklenir = false;
  bool _sekilMesgul = false;

  Future<void> _sekil({bool sil = false}) async {
    if (_sekilMesgul || _yuklenir) return;
    setState(() => _sekilMesgul = true);
    try {
      dynamic data;
      if (sil) {
        data = await ApiClient.delete('/me/photo');
      } else {
        final file = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 85,
        );
        if (file == null || !mounted) return;
        final bytes = await file.readAsBytes();
        if (bytes.length > 2 * 1024 * 1024 || bytes.length < 8) {
          throw ApiException(t('sekil_olcusu'));
        }
        final mime = bytes[0] == 0xFF && bytes[1] == 0xD8
            ? 'image/jpeg'
            : bytes[0] == 0x89 &&
                  bytes[1] == 0x50 &&
                  bytes[2] == 0x4E &&
                  bytes[3] == 0x47
            ? 'image/png'
            : null;
        if (mime == null) throw ApiException(t('sekil_olcusu'));
        data = await ApiClient.put('/me/photo', {
          'data': 'data:$mime;base64,${base64Encode(bytes)}',
        });
      }
      if (!mounted) return;
      final yeni = Session.fromJson(data as Map<String, dynamic>);
      setState(() => _session = yeni);
      widget.onSessionChanged?.call(yeni);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.mesaj)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t('sekil_yuklenmedi'))));
      }
    } finally {
      if (mounted) setState(() => _sekilMesgul = false);
    }
  }

  @override
  void dispose() {
    _ad.dispose();
    _telefon.dispose();
    _whatsapp.dispose();
    super.dispose();
  }

  Future<void> _saxla() async {
    if (_yuklenir || _sekilMesgul) return;
    if (_ad.text.trim().length < 2) {
      setState(() => _xeta = t('Adınızı yaz'));
      return;
    }
    setState(() {
      _yuklenir = true;
      _xeta = null;
    });
    try {
      final session = await AuthService.updateProfile(
        ad: _ad.text.trim(),
        telefon: _telefon.text.trim().isEmpty ? null : _telefon.text.trim(),
        whatsapp: _whatsapp.text.trim().isEmpty ? null : _whatsapp.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(session);
    } on AuthException catch (e) {
      if (mounted) setState(() => _xeta = e.mesaj);
    } finally {
      if (mounted) setState(() => _yuklenir = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppTheme.yumshagEsas(context),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 232,
                child: Stack(
                  children: [
                    Positioned(
                      left: 8,
                      top: 4,
                      child: IconButton(
                        tooltip: t('legv_et'),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: scheme.onSurface,
                        ),
                        onPressed: _sekilMesgul || _yuklenir
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Tooltip(
                            message: t('profil_sekli'),
                            child: InkWell(
                              onTap: _sekilMesgul || _yuklenir
                                  ? null
                                  : () => _sekil(),
                              customBorder: const CircleBorder(),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 106,
                                    height: 106,
                                    decoration: BoxDecoration(
                                      color: scheme.surface,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: scheme.surface,
                                        width: 4,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x14112012),
                                          blurRadius: 18,
                                          offset: Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: _session.photo == null
                                        ? Icon(
                                            Icons.person_rounded,
                                            size: 54,
                                            color: AppTheme.esas(context),
                                          )
                                        : ClipOval(
                                            child: Image.memory(
                                              base64Decode(
                                                _session.photo!.split(',').last,
                                              ),
                                              width: 106,
                                              height: 106,
                                              fit: BoxFit.cover,
                                              semanticLabel: t('profil_sekli'),
                                            ),
                                          ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppTheme.esas(context),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: scheme.surface,
                                          width: 2.5,
                                        ),
                                      ),
                                      child: _sekilMesgul
                                          ? Padding(
                                              padding: const EdgeInsets.all(6),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: scheme.onPrimary,
                                              ),
                                            )
                                          : Icon(
                                              Icons.edit_rounded,
                                              size: 15,
                                              color: scheme.onPrimary,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _session.login.isEmpty
                                ? _session.ad
                                : '@${_session.login}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.esas(context),
                            ),
                          ),
                          if (_session.photo != null)
                            TextButton.icon(
                              onPressed: _sekilMesgul || _yuklenir
                                  ? null
                                  : () => _sekil(sil: true),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: Text(t('sekli_sil')),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('Profili redaktə et'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),
                      AuthSahe(
                        controller: _ad,
                        etiket: t('İstifadəçi adınız'),
                        hint: t('Ad və soyad'),
                        ikon: Icons.person_outline_rounded,
                        boyukHerf: TextCapitalization.words,
                        hereket: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      AuthSahe(
                        controller: _telefon,
                        etiket: t('Əlaqə nömrəniz'),
                        hint: '+994 50 000 00 00',
                        ikon: Icons.phone_outlined,
                        klaviatura: TextInputType.phone,
                        hereket: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      AuthSahe(
                        controller: _whatsapp,
                        etiket: t('WhatsApp nömrəniz'),
                        hint: '+994 50 000 00 00',
                        ikon: Icons.chat_outlined,
                        klaviatura: TextInputType.phone,
                        hereket: TextInputAction.done,
                        teleqraf: (_) => _saxla(),
                      ),
                      AuthXeta(mesaj: _xeta),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _yuklenir || _sekilMesgul
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              child: Text(t('Ləğv et')),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: _yuklenir || _sekilMesgul
                                  ? null
                                  : _saxla,
                              child: _yuklenir
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: scheme.onPrimary,
                                      ),
                                    )
                                  : Text(t('Yadda saxla')),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
