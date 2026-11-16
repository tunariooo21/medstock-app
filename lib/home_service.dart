import 'api_client.dart';
import 'manager_service.dart';
import 'stock_models.dart';

String cariAy() {
  final d = DateTime.now();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}';
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

class DiqqetSiyahi {
  final String derman;
  final String pointAd;
  final String regionAd;
  final int qaliq;
  final String status; // az, sifir

  const DiqqetSiyahi({
    required this.derman,
    required this.pointAd,
    required this.regionAd,
    required this.qaliq,
    required this.status,
  });
}

class AnaMelumat {
  final String ay;
  final List<DermanCemi> dermanlar; // bütün regionlar birlikdə
  final List<RegionCemi> regionlar;
  final int? geriQaytarma; // yalnız menecer
  final List<DiqqetSiyahi> diqqet; // aşağı stoklar, yalnız nümayəndə

  const AnaMelumat({
    required this.ay,
    required this.dermanlar,
    required this.regionlar,
    required this.geriQaytarma,
    required this.diqqet,
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
    final diqqet = <DiqqetSiyahi>[];
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
      if (!menecer) {
        for (final p in n.noqteler) {
          for (final d in p.dermanlar) {
            if (d.status == 'normal') continue;
            diqqet.add(
              DiqqetSiyahi(
                derman: d.ad,
                pointAd: p.ad,
                regionAd: reg[i]['ad'] as String,
                qaliq: d.qaliq,
                status: d.status,
              ),
            );
          }
        }
      }
      regionlar.add(
        RegionCemi(ad: reg[i]['ad'] as String, qaliq: q, satilib: s, resept: r),
      );
    }
    diqqet.sort((a, b) {
      if (a.status != b.status) return a.status == 'sifir' ? -1 : 1;
      final ferq = a.qaliq.compareTo(b.qaliq);
      return ferq != 0 ? ferq : a.derman.compareTo(b.derman);
    });

    int? geri;
    if (menecer) {
      geri = (await MenecerServisi.geriQaytarmalar(ay)).cemi;
    }

    return AnaMelumat(
      ay: ay,
      dermanlar: birlesmis.values.toList()
        ..sort((a, b) => a.sira.compareTo(b.sira)),
      regionlar: regionlar,
      geriQaytarma: geri,
      diqqet: diqqet,
    );
  }
}
