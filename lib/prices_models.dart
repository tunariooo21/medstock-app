/// "2026-11-05" → "05.11.2026"
String tarixGoster(String iso) {
  final p = iso.split('-');
  return '${p[2]}.${p[1]}.${p[0]}';
}

class QiymetSetri {
  final int id;
  final double qiymet;
  final String baslamaTarixi;
  final String? kim;

  const QiymetSetri({
    required this.id,
    required this.qiymet,
    required this.baslamaTarixi,
    required this.kim,
  });

  factory QiymetSetri.fromJson(Map<String, dynamic> j) => QiymetSetri(
        id: j['id'] as int,
        qiymet: (j['qiymet'] as num).toDouble(),
        baslamaTarixi: j['baslama_tarixi'] as String,
        kim: j['kim'] as String?,
      );
}

class DermanQiymeti {
  final int medicineId;
  final String ad;
  final int sira;
  final QiymetSetri? cari;
  final List<QiymetSetri> tarixce;

  const DermanQiymeti({
    required this.medicineId,
    required this.ad,
    required this.sira,
    required this.cari,
    required this.tarixce,
  });
}