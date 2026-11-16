import 'api_client.dart';
import 'report_models.dart';

class EntryServisi {
  static Future<List<Hekim>> hekimler(int regionId) async {
    final cavab = await ApiClient.get('/doctors?region=$regionId');
    return (cavab as List)
        .map((e) => Hekim.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Satış və ya geri qaytarma yazır. Yeni qalığı qaytarır.
  static Future<int> hereketYaz({
    required int noqteId,
    required int dermanId,
    required String novu, // "satis" və ya "geri_qaytarma"
    required int say,
    required String tarix, // YYYY-AA-GG
    String? sebeb,
  }) async {
    final cavab = await ApiClient.post('/movements', {
      'point_id': noqteId,
      'medicine_id': dermanId,
      'novu': novu,
      'say': say,
      'tarix': tarix,
      if (sebeb != null && sebeb.isNotEmpty) 'sebeb': sebeb,
    });
    return (cavab as Map<String, dynamic>)['qaliq'] as int;
  }

  static Future<void> reseptYaz({
    required int noqteId,
    required int dermanId,
    required int hekimId,
    required int say,
    required String tarix,
  }) async {
    await ApiClient.post('/prescriptions', {
      'point_id': noqteId,
      'medicine_id': dermanId,
      'doctor_id': hekimId,
      'say': say,
      'tarix': tarix,
    });
  }
}
