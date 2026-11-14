import 'api_client.dart';
import 'manager_models.dart';
import 'prices_models.dart';
import 'returns_models.dart';

class MenecerServisi {
  static Future<List<IsciSetiri>> isciler(String ay) async {
    final cavab = await ApiClient.get('/manager/reports?month=$ay');
    return ((cavab as Map<String, dynamic>)['iscilar'] as List)
        .map((e) => IsciSetiri.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<HesabatDetali> detal(int id) async {
    final cavab = await ApiClient.get('/manager/reports/$id');
    return HesabatDetali.fromJson(cavab as Map<String, dynamic>);
  }

  static Future<void> tesdiqle(int id) async {
    await ApiClient.post('/manager/reports/$id/approve');
  }

  static Future<void> geriQaytar(int id, String serh) async {
    await ApiClient.post('/manager/reports/$id/return', {'serh': serh});
  }

  // ---------- 5.2 ----------

  static Future<GeriQaytarmalar> geriQaytarmalar(String ay) async {
    final cavab = await ApiClient.get('/manager/returns?month=$ay');
    return GeriQaytarmalar.fromJson(cavab as Map<String, dynamic>);
  }

  /// Qiymətlər + dərmanın sabit rəngi üçün /medicines-dən "sira".
  static Future<List<DermanQiymeti>> qiymetler() async {
    final netice = await Future.wait([
      ApiClient.get('/prices'),
      ApiClient.get('/medicines'),
    ]);
    final sira = {
      for (final e in (netice[1] as List))
        (e as Map<String, dynamic>)['id'] as int: e['sira'] as int,
    };
    final dermanlar = (netice[0] as Map<String, dynamic>)['dermanlar'] as List;
    return dermanlar.map((e) {
      final j = e as Map<String, dynamic>;
      final id = j['medicine_id'] as int;
      return DermanQiymeti(
        medicineId: id,
        ad: j['ad'] as String,
        sira: sira[id] ?? 0,
        cari: j['cari'] == null
            ? null
            : QiymetSetri.fromJson(j['cari'] as Map<String, dynamic>),
        tarixce: (j['tarixce'] as List)
            .map((x) => QiymetSetri.fromJson(x as Map<String, dynamic>))
            .toList(),
      );
    }).toList();
  }

  static Future<void> qiymetElave(
      int dermanId, double qiymet, String baslamaTarixi) async {
    await ApiClient.post('/prices', {
      'medicine_id': dermanId,
      'qiymet': qiymet,
      'baslama_tarixi': baslamaTarixi,
    });
  }
}