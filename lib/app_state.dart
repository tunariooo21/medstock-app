import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Dil { az, en, ru }

/// Tətbiqin global vəziyyəti: dil və qaranlıq rejim.
/// Dəyişiklikdə bütün ağacı yenidən qurur (MaterialApp yenilənir).
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  Dil dil = Dil.az;
  bool qaranliq = false;
  bool yuklendi = false;

  Future<void> yukle() async {
    final p = await SharedPreferences.getInstance();
    dil = Dil.values.asNameMap()[p.getString('dil')] ?? Dil.az;
    qaranliq = p.getBool('qaranliq') ?? false;
    yuklendi = true;
    notifyListeners();
  }

  Future<void> dilSec(Dil d) async {
    dil = d;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString('dil', d.name);
  }

  Future<void> qaranliqSec(bool v) async {
    qaranliq = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool('qaranliq', v);
  }
}
