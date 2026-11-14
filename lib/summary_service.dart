import 'api_client.dart';
import 'summary_models.dart';

class XulaseServisi {
  static Future<Xulase> yukle(String ay, int? region) async {
    final regionHissesi = region != null ? '&region=$region' : '';
    final cavab = await ApiClient.get('/reports/summary?month=$ay$regionHissesi');
    return Xulase.fromJson(cavab as Map<String, dynamic>);
  }

  static Future<List<RegionItem>> regionlar() async {
    final cavab = await ApiClient.get('/regions');
    return (cavab as List)
        .map((e) => RegionItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}