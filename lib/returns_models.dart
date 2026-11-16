class QaytarmaDerman {
  final int medicineId;
  final String ad;
  final int cemi;
  const QaytarmaDerman({
    required this.medicineId,
    required this.ad,
    required this.cemi,
  });

  factory QaytarmaDerman.fromJson(Map<String, dynamic> j) => QaytarmaDerman(
    medicineId: j['medicine_id'] as int,
    ad: j['ad'] as String,
    cemi: j['cemi'] as int,
  );
}

class QaytarmaSetri {
  final int id;
  final String tarix; // YYYY-AA-GG
  final String derman;
  final String pointAd;
  final String pointNovu;
  final int say;
  final String? sebeb;
  final String isciAd;

  const QaytarmaSetri({
    required this.id,
    required this.tarix,
    required this.derman,
    required this.pointAd,
    required this.pointNovu,
    required this.say,
    required this.sebeb,
    required this.isciAd,
  });

  factory QaytarmaSetri.fromJson(Map<String, dynamic> j) => QaytarmaSetri(
    id: j['id'] as int,
    tarix: j['tarix'] as String,
    derman: j['derman'] as String,
    pointAd: j['point_ad'] as String,
    pointNovu: j['point_novu'] as String,
    say: j['say'] as int,
    sebeb: j['sebeb'] as String?,
    isciAd: j['isci_ad'] as String,
  );
}

class GeriQaytarmalar {
  final String ay;
  final int cemi;
  final List<QaytarmaDerman> dermanlar;
  final List<QaytarmaSetri> siyahi;

  const GeriQaytarmalar({
    required this.ay,
    required this.cemi,
    required this.dermanlar,
    required this.siyahi,
  });

  factory GeriQaytarmalar.fromJson(Map<String, dynamic> j) => GeriQaytarmalar(
    ay: j['ay'] as String,
    cemi: j['cemi'] as int,
    dermanlar: (j['dermanlar'] as List)
        .map((e) => QaytarmaDerman.fromJson(e as Map<String, dynamic>))
        .toList(),
    siyahi: (j['siyahi'] as List)
        .map((e) => QaytarmaSetri.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
