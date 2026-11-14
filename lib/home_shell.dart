import 'package:flutter/material.dart';
import 'stock_screen.dart';
import 'auth_service.dart';
import 'profile_screen.dart';
import 'widgets/state_widgets.dart';
import 'charts_screen.dart';
import 'workers_screen.dart';
import 'manager_reports_screen.dart';
import 'home_screen.dart';




class _Tab {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
  const _Tab(this.label, this.icon, this.selectedIcon, this.page);
}

class HomeShell extends StatefulWidget {
  final Session session;
  final VoidCallback onLogout;
  const HomeShell({super.key, required this.session, required this.onLogout});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  List<_Tab> _tablar() {
    final profil = _Tab(
      'Profil',
      Icons.person_outline,
      Icons.person,
      ProfilEkrani(session: widget.session, onLogout: widget.onLogout),
    );

    switch (widget.session.rol) {
      case 'representative':
        return [
          const _Tab('Ana səhifə', Icons.home_outlined, Icons.home,
              AnaSehife()),
          const _Tab('Stok', Icons.inventory_2_outlined, Icons.inventory_2,
              StokEkrani()),
          const _Tab('Hesabat', Icons.bar_chart_outlined, Icons.bar_chart,
              QrafiklerEkrani()),
          profil,
        ];
      case 'manager':
        return [
          const _Tab('Ana səhifə', Icons.home_outlined, Icons.home,
              AnaSehife(menecer: true)),
          const _Tab('İşçilər', Icons.groups_outlined, Icons.groups,
              IscilerEkrani()),
          const _Tab('Hesabatlar', Icons.bar_chart_outlined, Icons.bar_chart,
              MenecerHesabatlarEkrani()),
          profil,
        ];
      default:
        // Bu rol üçün ekranlar təyin olunmayıb: yalnız profil göstərilir.
        return [profil];
    }
  }

  @override
  Widget build(BuildContext context) {
    final tablar = _tablar();
    final i = _index.clamp(0, tablar.length - 1);

    return Scaffold(
      appBar: AppBar(title: Text(tablar[i].label)),
      body: IndexedStack(
        index: i,
        children: tablar.map((t) => t.page).toList(),
      ),
      bottomNavigationBar: tablar.length < 2
          ? null
          : NavigationBar(
              selectedIndex: i,
              onDestinationSelected: (v) => setState(() => _index = v),
              destinations: [
                for (final t in tablar)
                  NavigationDestination(
                    icon: Icon(t.icon),
                    selectedIcon: Icon(t.selectedIcon),
                    label: t.label,
                  ),
              ],
            ),
    );
  }
}

/// Müvəqqəti demo ekran: dörd vəziyyəti (yüklənir, server oyanır, xəta, boş)
/// göstərir. M3-dən başlayaraq real ekranlarla əvəz olunacaq.
class BosEkran extends StatefulWidget {
  final String ad;
  const BosEkran(this.ad, {super.key});

  @override
  State<BosEkran> createState() => _BosEkranState();
}

class _BosEkranState extends State<BosEkran> {
  int _cehd = 0;
  int _acar = 0;

  // 1-ci cəhd xəta, 2-ci boş, 3-cü məlumatla bitir
  Future<List<String>> _yukle() async {
    _cehd++;
    if (_cehd == 1) {
      await Future.delayed(const Duration(seconds: 7));
      throw Exception('sınaq xətası');
    }
    await Future.delayed(const Duration(seconds: 1));
    return _cehd == 2 ? <String>[] : ['Nümunə məlumat'];
  }

  @override
  Widget build(BuildContext context) {
    return AsyncGorunus<List<String>>(
      key: ValueKey(_acar),
      yukle: _yukle,
      bosdur: (siyahi) => siyahi.isEmpty,
      bosMetn: '${widget.ad} üçün hələ qeyd yoxdur',
      bosDuymeAdi: 'Yenilə',
      bosDuymeEmeliyyati: () => setState(() => _acar++),
      qur: (context, siyahi) => Center(
        child: Text('${widget.ad} ekranı (tezliklə)',
            style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}