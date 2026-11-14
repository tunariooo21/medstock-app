class NoqteDerman {
  final int medicineId;
  final String ad;
  final int sira;
  final int qaliq;
  final int daxilolma;
  final int satilib;
  final int resept;
  final String status; // normal, az, sifir

  const NoqteDerman({
    required this.medicineId,
    required this.ad,
    required this.sira,
    required this.qaliq,
    required this.daxilolma,
    required this.satilib,
    required this.resept,
    required this.status,
  });

  factory NoqteDerman.fromJson(Map<String, dynamic> j) => NoqteDerman(
        medicineId: j['medicine_id'] as int,
        ad: j['ad'] as String,
        sira: j['sira'] as int,
        qaliq: j['qaliq'] as int,
        daxilolma: j['daxilolma'] as int,
        satilib: j['satilib'] as int,
        resept: j['resept'] as int,
        status: j['status'] as String,
      );
}

class StokNoqte {
  final int id;
  final String ad;
  final String novu; // aptek və ya depo
  final String? unvan;
  final List<NoqteDerman> dermanlar;

  const StokNoqte({
    required this.id,
    required this.ad,
    required this.novu,
    required this.unvan,
    required this.dermanlar,
  });

  factory StokNoqte.fromJson(Map<String, dynamic> j) => StokNoqte(
        id: j['id'] as int,
        ad: j['ad'] as String,
        novu: j['novu'] as String,
        unvan: j['unvan'] as String?,
        dermanlar: (j['dermanlar'] as List)
            .map((e) => NoqteDerman.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class DermanCemi {
  final int medicineId;
  final String ad;
  final int sira;
  final int qaliq;
  final int satilib;
  final int resept;

  const DermanCemi({
    required this.medicineId,
    required this.ad,
    required this.sira,
    required this.qaliq,
    required this.satilib,
    required this.resept,
  });

  factory DermanCemi.fromJson(Map<String, dynamic> j) => DermanCemi(
        medicineId: j['medicine_id'] as int,
        ad: j['ad'] as String,
        sira: j['sira'] as int,
        qaliq: j['qaliq'] as int,
        satilib: j['satilib'] as int,
        resept: j['resept'] as int,
      );
}

class StokNeticesi {
  final String ay; // "2026-11"
  final bool cariAy;
  final int asagiHedd;
  final List<DermanCemi> cemi;
  final List<StokNoqte> noqteler;

  const StokNeticesi({
    required this.ay,
    required this.cariAy,
    required this.asagiHedd,
    required this.cemi,
    required this.noqteler,
  });

  factory StokNeticesi.fromJson(Map<String, dynamic> j) => StokNeticesi(
        ay: j['ay'] as String,
        cariAy: j['cari_ay'] as bool,
        asagiHedd: j['asagi_hedd'] as int,
        cemi: (j['cemi'] as List)
            .map((e) => DermanCemi.fromJson(e as Map<String, dynamic>))
            .toList(),
        noqteler: (j['noqteler'] as List)
            .map((e) => StokNoqte.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}