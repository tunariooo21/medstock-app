class IsciSetiri {
  final int userId;
  final String ad;
  final int? hesabatId;
  final String status; // yoxdur, qaralama, gonderildi, geri_qaytarildi, tesdiqlendi
  final int? cemi;

  const IsciSetiri({
    required this.userId,
    required this.ad,
    required this.hesabatId,
    required this.status,
    required this.cemi,
  });

  factory IsciSetiri.fromJson(Map<String, dynamic> j) => IsciSetiri(
        userId: j['user_id'] as int,
        ad: j['ad'] as String,
        hesabatId: j['hesabat_id'] as int?,
        status: j['status'] as String,
        cemi: j['cemi'] as int?,
      );
}

class DetalDerman {
  final int medicineId;
  final String ad;
  final int sira;
  final int cemi;

  const DetalDerman({
    required this.medicineId,
    required this.ad,
    required this.sira,
    required this.cemi,
  });

  factory DetalDerman.fromJson(Map<String, dynamic> j) => DetalDerman(
        medicineId: j['medicine_id'] as int,
        ad: j['ad'] as String,
        sira: j['sira'] as int,
        cemi: j['cemi'] as int,
      );
}

class DetalHekim {
  final int id;
  final String ad;
  final String? ixtisas;
  final String clinicAd;
  final int cemi;

  /// Açar: dərman id, dəyər: say
  final Map<int, int> say;

  const DetalHekim({
    required this.id,
    required this.ad,
    required this.ixtisas,
    required this.clinicAd,
    required this.cemi,
    required this.say,
  });

  factory DetalHekim.fromJson(Map<String, dynamic> j) {
    final say = <int, int>{};
    for (final e in (j['dermanlar'] as List)) {
      final m = e as Map<String, dynamic>;
      say[m['medicine_id'] as int] = m['say'] as int;
    }
    return DetalHekim(
      id: j['id'] as int,
      ad: j['ad'] as String,
      ixtisas: j['ixtisas'] as String?,
      clinicAd: j['clinic_ad'] as String,
      cemi: j['cemi'] as int,
      say: say,
    );
  }
}

class HesabatDetali {
  final int id;
  final String iscAd;
  final String ay;
  final String status;
  final String? serh;
  final int cemi;
  final List<DetalDerman> dermanlar;
  final List<DetalHekim> hekimler;

  const HesabatDetali({
    required this.id,
    required this.iscAd,
    required this.ay,
    required this.status,
    required this.serh,
    required this.cemi,
    required this.dermanlar,
    required this.hekimler,
  });

  factory HesabatDetali.fromJson(Map<String, dynamic> j) => HesabatDetali(
        id: j['id'] as int,
        iscAd: j['isci_ad'] as String,
        ay: j['ay'] as String,
        status: j['status'] as String,
        serh: j['menecer_serhi'] as String?,
        cemi: j['cemi'] as int,
        dermanlar: (j['dermanlar'] as List)
            .map((e) => DetalDerman.fromJson(e as Map<String, dynamic>))
            .toList(),
        hekimler: (j['hekimler'] as List)
            .map((e) => DetalHekim.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}