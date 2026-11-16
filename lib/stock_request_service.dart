import 'package:flutter/foundation.dart';

import 'api_client.dart';

class TalebSetri {
  final int pointId;
  final String pointAd;
  final int medicineId;
  final String medicineAd;
  final int sira;
  final int say;

  const TalebSetri({
    required this.pointId,
    required this.pointAd,
    required this.medicineId,
    required this.medicineAd,
    required this.sira,
    required this.say,
  });

  factory TalebSetri.fromJson(Map<String, dynamic> j) => TalebSetri(
    pointId: j['point_id'] as int,
    pointAd: j['point_ad'] as String,
    medicineId: j['medicine_id'] as int,
    medicineAd: j['medicine_ad'] as String,
    sira: j['sira'] as int,
    say: j['say'] as int,
  );
}

class StokTalebi {
  final int id;
  final String userAd;
  final String status;
  final String? serh;
  final String tarix;
  final List<TalebSetri> setirler;

  const StokTalebi({
    required this.id,
    required this.userAd,
    required this.status,
    required this.serh,
    required this.tarix,
    required this.setirler,
  });

  factory StokTalebi.fromJson(Map<String, dynamic> j) => StokTalebi(
    id: j['id'] as int,
    userAd: j['user_ad'] as String,
    status: j['status'] as String,
    serh: j['menecer_serhi'] as String?,
    tarix: j['created_at'] as String,
    setirler: (j['setirler'] as List)
        .map((e) => TalebSetri.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class StokTalebServisi {
  static final deyisdi = ValueNotifier<int>(0);

  static Future<Map<String, dynamic>> secimler() async =>
      await ApiClient.get('/stock-requests/options') as Map<String, dynamic>;

  static Future<List<StokTalebi>> siyahi() async =>
      (await ApiClient.get('/stock-requests') as List)
          .map((e) => StokTalebi.fromJson(e as Map<String, dynamic>))
          .toList();

  static Future<StokTalebi> detal(int id) async => StokTalebi.fromJson(
    await ApiClient.get('/stock-requests/$id') as Map<String, dynamic>,
  );

  static Future<StokTalebi> saxla(
    int? id,
    List<Map<String, int>> setirler,
  ) async {
    final body = {'setirler': setirler};
    final j = id == null
        ? await ApiClient.post('/stock-requests', body)
        : await ApiClient.put('/stock-requests/$id', body);
    deyisdi.value++;
    return StokTalebi.fromJson(j as Map<String, dynamic>);
  }

  static Future<StokTalebi> gonder(int id) async {
    final j = await ApiClient.post('/stock-requests/$id/submit');
    deyisdi.value++;
    return StokTalebi.fromJson(j as Map<String, dynamic>);
  }

  static Future<StokTalebi> qerar(int id, String status, String serh) async {
    final j = await ApiClient.post('/stock-requests/$id/decision', {
      'status': status,
      'serh': serh,
    });
    deyisdi.value++;
    return StokTalebi.fromJson(j as Map<String, dynamic>);
  }

  static Future<Map<String, dynamic>> bildirisler() async =>
      await ApiClient.get('/notifications') as Map<String, dynamic>;

  static Future<void> oxu(int id) async {
    await ApiClient.post('/notifications/$id/read');
    deyisdi.value++;
  }
}
