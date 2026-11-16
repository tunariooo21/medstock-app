class Hekim {
  final int id;
  final String ad;
  final String? ixtisas;
  final int clinicId;
  final String clinicAd;

  Hekim.fromJson(Map<String, dynamic> j)
    : id = j['id'] as int,
      ad = j['ad'] as String,
      ixtisas = j['ixtisas'] as String?,
      clinicId = j['clinic_id'] as int,
      clinicAd = j['clinic_ad'] as String;
}

class Derman {
  final int id;
  final String ad;
  final int sira;

  Derman.fromJson(Map<String, dynamic> j)
    : id = j['id'] as int,
      ad = j['ad'] as String,
      sira = j['sira'] as int;
}

class Hesabat {
  final int id;
  final String ay; // "2026-11"
  final String status;
  final String? serh;
  final bool redakteOlunaBiler;

  /// Açar: "həkimId:dərmanId", dəyər: say
  final Map<String, int> say;

  Hesabat.fromJson(Map<String, dynamic> j)
    : id = j['id'] as int,
      ay = j['ay'] as String,
      status = j['status'] as String,
      serh = j['menecer_serhi'] as String?,
      redakteOlunaBiler = j['redakte_oluna_biler'] as bool,
      say = {
        for (final s in (j['setirler'] as List))
          '${s['doctor_id']}:${s['medicine_id']}': s['say'] as int,
      };
}

class HesabatMelumati {
  final Hesabat hesabat;
  final List<Hekim> hekimler;
  final List<Derman> dermanlar;

  HesabatMelumati({
    required this.hesabat,
    required this.hekimler,
    required this.dermanlar,
  });
}
