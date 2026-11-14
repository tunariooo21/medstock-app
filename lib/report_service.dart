import 'api_client.dart';
import 'report_models.dart';

class HesabatServisi {
  static Future<HesabatMelumati> yukle() async {
    final netice = await Future.wait([
      ApiClient.get('/reports/monthly'),
      ApiClient.get('/doctors'),
      ApiClient.get('/medicines'),
    ]);
    return HesabatMelumati(
      hesabat: Hesabat.fromJson(netice[0] as Map<String, dynamic>),
      hekimler: (netice[1] as List)
          .map((e) => Hekim.fromJson(e as Map<String, dynamic>))
          .toList(),
      dermanlar: (netice[2] as List)
          .map((e) => Derman.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Yalnız ekranda görünən həkimlərin rəqəmləri göndərilir.
  static Future<Hesabat> saxla(
    int id,
    Map<String, int> say,
    Set<int> hekimIdleri,
  ) async {
    final setirler = <Map<String, int>>[];
    say.forEach((acar, deyer) {
      final hisseler = acar.split(':');
      final hekimId = int.parse(hisseler[0]);
      if (hekimIdleri.contains(hekimId)) {
        setirler.add({
          'doctor_id': hekimId,
          'medicine_id': int.parse(hisseler[1]),
          'say': deyer,
        });
      }
    });
    final cavab = await ApiClient.put('/reports/monthly/$id', {'setirler': setirler});
    return Hesabat.fromJson(cavab as Map<String, dynamic>);
  }

  static Future<Hesabat> gonder(int id) async {
    final cavab = await ApiClient.post('/reports/monthly/$id/submit');
    return Hesabat.fromJson(cavab as Map<String, dynamic>);
  }
}