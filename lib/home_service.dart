import 'api_client.dart';
import 'manager_service.dart';
import 'stock_models.dart';

String cariAy() {
  final d = DateTime.now();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}';
}

class SonQeyd {
  final String novu; // satis, geri_qaytarma, resept
  final String derman;
  final String pointAd;
  final int say;
  final String tarix;

  const SonQeyd({
    required this.novu,
    required this.derman,
    required this.pointAd,
    required this.say,
    required this.tarix,
  });

  factory SonQeyd.fromJson(Map<String, dynamic> j) => SonQeyd(
        novu: j['novu'] as String,
        derman: j['derman'] as String,
        pointAd: j['point_ad'] as String,
        say: j['say'] as int,
        tarix: j['tarix'] as String,
      );
}

class RegionCemi {
  final String ad;
  final int qaliq;
  final int satilib;
  final int resept;
  const RegionCemi({
    required this.ad,
    required this.qaliq,
    required this.satilib,
    required this.resept,
  });
}

class AnaMelumat {
  final String ay;
  final List<DermanCemi> dermanlar; // bütün regionlar birlikdə
  final List<RegionCemi> regionlar;
  final int? geriQaytarma; // yalnız menecer
  final List<SonQeyd> sonQeydler; // yalnız nümayəndə

  const AnaMelumat({
    required this.ay,
    required this.dermanlar,
    required this.regionlar,
    required this.geriQaytarma,
    required this.sonQeydler,
  });

  int get qaliq => regionlar.fold(0, (a, r) => a + r.qaliq);
  int get satilib => regionlar.fold(0, (a, r) => a + r.satilib);
  int get resept => regionlar.fold(0, (a, r) => a + r.resept);
}

class AnaServisi {
  static Future<AnaMelumat> yukle({required bool menecer}) async {
    final ay = cariAy();
    final reg = ((await ApiClient.get('/regions')) as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();

    final stoklar = await Future.wait([
      for (final r in reg) ApiClient.get('/stock?region=${r['id']}&month=$ay'),
    ]);

    final birlesmis = <int, DermanCemi>{};
    final regionlar = <RegionCemi>[];
    for (var i = 0; i < reg.length; i++) {
      final n = StokNeticesi.fromJson(stoklar[i] as Map<String, dynamic>);
      var q = 0, s = 0, r = 0;
      for (final d in n.cemi) {
        q += d.qaliq;
        s += d.satilib;
        r += d.resept;
        final b = birlesmis[d.medicineId];
        birlesmis[d.medicineId] = DermanCemi(
          medicineId: d.medicineId,
          ad: d.ad,
          sira: d.sira,
          qaliq: (b?.qaliq ?? 0) + d.qaliq,
          satilib: (b?.satilib ?? 0) + d.satilib,
          resept: (b?.resept ?? 0) + d.resept,
        );
      }
      regionlar.add(RegionCemi(
        ad: reg[i]['ad'] as String,
        qaliq: q,
        satilib: s,
        resept: r,
      ));
    }

    int? geri;
    var son = <SonQeyd>[];
    if (menecer) {
      geri = (await MenecerServisi.geriQaytarmalar(ay)).cemi;
    } else {
      son = ((await ApiClient.get('/me/recent')) as List)
          .map((e) => SonQeyd.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return AnaMelumat(
      ay: ay,
      dermanlar: birlesmis.values.toList()
        ..sort((a, b) => a.sira.compareTo(b.sira)),
      regionlar: regionlar,
      geriQaytarma: geri,
      sonQeydler: son,
    );
  }
}