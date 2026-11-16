import 'package:flutter/material.dart';

import 'app_state.dart';
import 'l10n.dart';
import 'stock_screen.dart';
import 'auth_service.dart';
import 'profile_screen.dart';
import 'charts_screen.dart';
import 'workers_screen.dart';
import 'manager_reports_screen.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';

class _Tab {
  final String Function() label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
  _Tab(this.label, this.icon, this.selectedIcon, this.page);
}

class HomeShell extends StatefulWidget {
  final Session session;
  final VoidCallback onLogout;
  final void Function(Session)? onSessionChanged;
  const HomeShell({
    super.key,
    required this.session,
    required this.onLogout,
    this.onSessionChanged,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  int _geriQaytarmaAcari = 0;
  late final TabController _hesabatlar;

  @override
  void initState() {
    super.initState();
    _hesabatlar = TabController(length: 4, vsync: this);
  }

  void _geriQaytarmalaraKech() {
    _hesabatlar.index = 2;
    setState(() {
      _index = 2;
      _geriQaytarmaAcari++;
    });
  }

  @override
  void dispose() {
    _hesabatlar.dispose();
    super.dispose();
  }

  List<_Tab> _tablar() {
    final profil = _Tab(
      () => t('profil'),
      Icons.person_outline,
      Icons.person,
      ProfilEkrani(
        session: widget.session,
        onLogout: widget.onLogout,
        onSessionChanged: widget.onSessionChanged,
      ),
    );

    switch (widget.session.rol) {
      case 'representative':
        return [
          _Tab(
            () => t('ana_sehife'),
            Icons.home_outlined,
            Icons.home,
            AnaSehife(
              ad: widget.session.ad,
              aktiv: _index == 0,
              onStokaKech: () => setState(() => _index = 1),
            ),
          ),
          _Tab(
            () => t('stok'),
            Icons.inventory_2_outlined,
            Icons.inventory_2,
            StokEkrani(aktiv: _index == 1),
          ),
          _Tab(
            () => t('hesabat'),
            Icons.bar_chart_outlined,
            Icons.bar_chart,
            QrafiklerEkrani(),
          ),
          profil,
        ];
      case 'manager':
        return [
          _Tab(
            () => t('ana_sehife'),
            Icons.home_outlined,
            Icons.home,
            AnaSehife(
              ad: widget.session.ad,
              menecer: true,
              aktiv: _index == 0,
              onGeriQaytarmayaKech: _geriQaytarmalaraKech,
            ),
          ),
          _Tab(
            () => t('isciler'),
            Icons.groups_outlined,
            Icons.groups,
            IscilerEkrani(),
          ),
          _Tab(
            () => t('hesabatlar'),
            Icons.bar_chart_outlined,
            Icons.bar_chart,
            MenecerHesabatlarEkrani(
              controller: _hesabatlar,
              geriQaytarmaAcari: _geriQaytarmaAcari,
            ),
          ),
          profil,
        ];
      default:
        return [profil];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        final tablar = _tablar();
        final i = _index.clamp(0, tablar.length - 1);
        return Scaffold(
          appBar: AppBar(
            title: Text(tablar[i].label()),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: BildirisDugmesi(
                  key: ValueKey(widget.session.login),
                  menecer: widget.session.rol == 'manager',
                ),
              ),
            ],
          ),
          body: IndexedStack(
            index: i,
            children: [
              for (var j = 0; j < tablar.length; j++)
                HeroMode(enabled: j == i, child: tablar[j].page),
            ],
          ),
          bottomNavigationBar: tablar.length < 2
              ? null
              : NavigationBar(
                  selectedIndex: i,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  onDestinationSelected: (v) => setState(() => _index = v),
                  destinations: [
                    for (final tb in tablar)
                      NavigationDestination(
                        icon: Icon(tb.icon),
                        selectedIcon: Icon(tb.selectedIcon),
                        label: tb.label(),
                      ),
                  ],
                ),
        );
      },
    );
  }
}
