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
      'yoxdur' => ('Doldurulmayıb', Icons.hourglass_empty, scheme.outline),
      'qaralama' => ('Qaralama', Icons.edit_note, scheme.outline),
      'gonderildi' => ('Göndərilib', Icons.send, scheme.primary),
      'geri_qaytarildi' => ('Geri qaytarılıb', Icons.reply, AppTheme.azQalib),
      'tesdiqlendi' =>
        ('Təsdiqlənib', Icons.check_circle, Colors.green.shade700),
      _ => (status, Icons.info_outline, scheme.outline),
    };
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(ikon, size: 18, color: reng),
      label: Text(metn),
    );
  }
}