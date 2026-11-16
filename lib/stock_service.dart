import 'api_client.dart';
import 'report_models.dart';
import 'stock_models.dart';
import 'summary_models.dart';

class StokSecimleri {
  final List<RegionItem> regionlar;
  final List<Derman> dermanlar;
  const StokSecimleri({required this.regionlar, required this.dermanlar});
}

class StokServisi {
  static Future<StokSecimleri> secimler() async {
    final netice = await Future.wait([
      ApiClient.get('/regions'),
      ApiClient.get('/medicines'),
    ]);
    return StokSecimleri(
      regionlar: (netice[0] as List)
          .map((e) => RegionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      dermanlar: (netice[1] as List)
          .map((e) => Derman.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// derman == null olduqda bütün dərmanlar göstərilir.
  static Future<StokNeticesi> yukle({
    required int region,
    required String ay,
    int? derman,
  }) async {
    final dermanHissesi = derman != null ? '&medicine=$derman' : '';
    final cavab = await ApiClient.get(
      '/stock?region=$region&month=$ay$dermanHissesi',
    );
    return StokNeticesi.fromJson(cavab as Map<String, dynamic>);
  }
}
