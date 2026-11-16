import 'l10n.dart' hide ayAdi;
import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

/// Hesabat statusu: həmişə rəng + ikon + mətn birlikdə.
class StatusNisani extends StatelessWidget {
  final String status;
  const StatusNisani({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (metn, ikon, reng) = switch (status) {
      'yoxdur' => (t('Doldurulmayıb'), Icons.hourglass_empty, scheme.outline),
      'qaralama' => (t('Qaralama'), Icons.edit_note, scheme.outline),
      'gonderildi' => (t('Göndərilib'), Icons.send, scheme.primary),
      'geri_qaytarildi' => (t('Geri qaytarılıb'), Icons.reply, AppTheme.azQalib),
      'tesdiqlendi' => (
        t('Təsdiqlənib'),
        Icons.check_circle,
        AppTheme.ugur,
      ),
      _ => (status, Icons.info_outline, scheme.outline),
    };
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(ikon, size: 18, color: reng),
      label: Text(metn),
    );
  }
}
