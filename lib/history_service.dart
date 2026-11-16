import 'dart:typed_data';

import 'api_client.dart';

class TarixceQeyd {
  final String entity; // movement və ya prescription
  final int id;
  final String novu; // satis, geri_qaytarma, daxilolma, resept
  final String derman;
  final String pointAd;
  final int say;
  final String tarix;
  final String? sebeb;
  final String? hekim;
  final String? userAd;
  final bool duzeldilebilir;

  const TarixceQeyd({
    required this.entity,
    required this.id,
    required this.novu,
    required this.derman,
    required this.pointAd,
    required this.say,
    required this.tarix,
    required this.sebeb,
    required this.hekim,
    required this.userAd,
    required this.duzeldilebilir,
  });

  factory TarixceQeyd.fromJson(Map<String, dynamic> j) => TarixceQeyd(
    entity: j['entity'] as String,
    id: j['id'] as int,
    novu: j['novu'] as String,
    derman: j['derman'] as String,
    pointAd: j['point_ad'] as String,
    say: j['say'] as int,
    tarix: j['tarix'] as String,
    sebeb: j['sebeb'] as String?,
    hekim: j['hekim'] as String?,
    userAd: j['user_ad'] as String?,
    duzeldilebilir: j['duzeldilebilir'] as bool? ?? false,
  );

  bool get reseptdir => novu == 'resept';
}

class AuditQeyd {
  final String action; // update və ya delete
  final Map<String, dynamic>? evvelki;
  final Map<String, dynamic>? sonraki;
  final String? userAd;
  final String? createdAt;

  const AuditQeyd({
    required this.action,
    required this.evvelki,
    required this.sonraki,
    required this.userAd,
    required this.createdAt,
  });

  factory AuditQeyd.fromJson(Map<String, dynamic> j) => AuditQeyd(
    action: j['action'] as String,
    evvelki: j['evvelki'] as Map<String, dynamic>?,
    sonraki: j['sonraki'] as Map<String, dynamic>?,
    userAd: j['user_ad'] as String?,
    createdAt: j['created_at'] as String?,
  );
}

class TarixceServisi {
  static Future<List<TarixceQeyd>> yukle({
    required int region,
    int? noqteId,
    String? ay,
    String? novu,
  }) async {
    final hisseler = <String>['region=$region'];
    if (noqteId != null) hisseler.add('point_id=$noqteId');
    if (ay != null) hisseler.add('month=$ay');
    if (novu != null) hisseler.add('novu=$novu');
    final cavab = await ApiClient.get('/history?${hisseler.join('&')}');
    return (cavab as List)
        .map((e) => TarixceQeyd.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Uint8List> ixrac({required int region, String? ay}) async {
    final ayHissesi = ay != null ? '&month=$ay' : '';
    return ApiClient.baytYukle('/history/export?region=$region$ayHissesi');
  }

  static Future<void> duzelt(
    TarixceQeyd q, {
    required int say,
    required String tarix,
    String? sebeb,
  }) async {
    if (q.reseptdir) {
      await ApiClient.patch('/prescriptions/${q.id}', {
        'say': say,
        'tarix': tarix,
      });
    } else {
      await ApiClient.patch('/movements/${q.id}', {
        'say': say,
        'tarix': tarix,
        'sebeb': sebeb,
      });
    }
  }

  static Future<void> sil(TarixceQeyd q) async {
    if (q.reseptdir) {
      await ApiClient.delete('/prescriptions/${q.id}');
    } else {
      await ApiClient.delete('/movements/${q.id}');
    }
  }

  static Future<List<AuditQeyd>> audit(TarixceQeyd q) async {
    final cavab = await ApiClient.get(
      '/history/audit?entity=${q.entity}&entity_id=${q.id}',
    );
    return (cavab as List)
        .map((e) => AuditQeyd.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
