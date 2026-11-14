List<T> _siyahi<T>(dynamic l, T Function(Map<String, dynamic> j) f) =>
    (l as List).map((e) => f(e as Map<String, dynamic>)).toList();

class RegionItem {
  final int id;
  final String ad;
  const RegionItem({required this.id, required this.ad});

  factory RegionItem.fromJson(Map<String, dynamic> j) =>
      RegionItem(id: j['id'] as int, ad: j['ad'] as String);
}

class AdCemi {
  final int id;
  final String ad;
  final int cemi;
  const AdCemi({required this.id, required this.ad, required this.cemi});

  factory AdCemi.fromJson(Map<String, dynamic> j) => AdCemi(
        id: j['id'] as int,
        ad: j['ad'] as String,
        cemi: j['cemi'] as int,
      );
}

class AyCemi {
  final String ay;
  final int cemi;
  const AyCemi({required this.ay, required this.cemi});

  factory AyCemi.fromJson(Map<String, dynamic> j) =>
      AyCemi(ay: j['ay'] as String, cemi: j['cemi'] as int);
}

class DermanXulase {
  final int id;
  final String ad;
  final int sira;
  final int cemi;
  final int evvelkiAy;
  final double? ferqFaiz;

  const DermanXulase({
    required this.id,
    required this.ad,
    required this.sira,
    required this.cemi,
    required this.evvelkiAy,
    required this.ferqFaiz,
  });

  factory DermanXulase.fromJson(Map<String, dynamic> j) => DermanXulase(
        id: j['id'] as int,
        ad: j['ad'] as String,
        sira: j['sira'] as int,
        cemi: j['cemi'] as int,
        evvelkiAy: j['evvelki_ay'] as int,
        ferqFaiz: (j['ferq_faiz'] as num?)?.toDouble(),
      );
}

class HekimXulase {
  final int id;
  final String ad;
  final int cemi;

  /// Açar: dərman id, dəyər: say
  final Map<int, int> dermanlar;

  const HekimXulase({
    required this.id,
    required this.ad,
    required this.cemi,
    required this.dermanlar,
  });

  factory HekimXulase.fromJson(Map<String, dynamic> j) {
    final dermanlar = <int, int>{};
    for (final e in (j['dermanlar'] as List)) {
      final m = e as Map<String, dynamic>;
      dermanlar[m['medicine_id'] as int] = m['say'] as int;
    }
    return HekimXulase(
      id: j['id'] as int,
      ad: j['ad'] as String,
      cemi: j['cemi'] as int,
      dermanlar: dermanlar,
    );
  }
}

class Xulase {
  final String ay;
  final int cemi;
  final int evvelkiCemi;
  final List<DermanXulase> dermanlar;
  final List<HekimXulase> hekimler;
  final List<AyCemi> son6Ay;
  final List<AdCemi>? iscilar; // yalnız menecerdə
  final List<AdCemi>? regionlar; // yalnız menecerdə

  const Xulase({
    required this.ay,
    required this.cemi,
    required this.evvelkiCemi,
    required this.dermanlar,
    required this.hekimler,
    required this.son6Ay,
    this.iscilar,
    this.regionlar,
  });

  factory Xulase.fromJson(Map<String, dynamic> j) => Xulase(
        ay: j['ay'] as String,
        cemi: j['cemi'] as int,
        evvelkiCemi: j['evvelki_cemi'] as int,
        dermanlar: _siyahi(j['dermanlar'], DermanXulase.fromJson),
        hekimler: _siyahi(j['hekimler'], HekimXulase.fromJson),
        son6Ay: _siyahi(j['son_6_ay'], AyCemi.fromJson),
        iscilar: j['iscilar'] == null
            ? null
            : _siyahi(j['iscilar'], AdCemi.fromJson),
        regionlar: j['regionlar'] == null
            ? null
            : _siyahi(j['regionlar'], AdCemi.fromJson),
      );

  bool get hecNeYoxdur =>
      cemi == 0 && evvelkiCemi == 0 && son6Ay.every((c) => c.cemi == 0);
}