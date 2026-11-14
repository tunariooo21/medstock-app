import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'home_service.dart';
import 'prices_models.dart' show tarixGoster;
import 'report_screen.dart' show ayAdi;
import 'theme/app_theme.dart';
import 'widgets/state_widgets.dart';

class AnaSehife extends StatefulWidget {
  final bool menecer;
  const AnaSehife({super.key, this.menecer = false});

  @override
  State<AnaSehife> createState() => _AnaSehifeState();
}

class _AnaSehifeState extends State<AnaSehife> {
  int _acar = 0;

  @override
  Widget build(BuildContext context) {
    return AsyncGorunus<AnaMelumat>(
      key: ValueKey(_acar),
      yukle: () => AnaServisi.yukle(menecer: widget.menecer),
      bosdur: (m) => m.regionlar.isEmpty,
      bosIkon: Icons.home_outlined,
      bosMetn: 'Sana region tayin olunmayib. Admindan xahiş et.',
      qur: (context, m) => RefreshIndicator(
        onRefresh: () async => setState(() => _acar++),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Text(ayAdi(m.ay), style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            _Kartlar(m: m, menecer: widget.menecer),
            const SizedBox(height: 12),
            _DermanKarti(m: m),
            const SizedBox(height: 12),
            if (widget.menecer)
              _RegionQrafiki(m: m)
            else
              _SonQeydler(siyahi: m.sonQeydler),
          ],
        ),
      ),
    );
  }
}

class _Kartlar extends StatelessWidget {
  final AnaMelumat m;
  final bool menecer;
  const _Kartlar({required this.m, required this.menecer});

  @override
  Widget build(BuildContext context) {
    final ucuncu = menecer
        ? _Raqam('Geri qaytarma', '${m.geriQaytarma ?? 0}',
            Icons.assignment_return_outlined)
        : _Raqam('Resept', '${m.resept}', Icons.description_outlined);
    final list = [
      _Raqam('Qalıq', '${m.qaliq}', Icons.inventory_2_outlined, true),
      _Raqam('Satılıb', '${m.satilib}', Icons.shopping_cart_outlined),
      ucuncu,
    ];
    return Row(
      children: [
        for (var i = 0; i < list.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _RaqamKarti(r: list[i])),
        ],
      ],
    );
  }
}

class _Raqam {
  final String ad;
  final String deyer;
  final IconData ikon;
  final bool tund;
  const _Raqam(this.ad, this.deyer, this.ikon, [this.tund = false]);
}

class _RaqamKarti extends StatelessWidget {
  final _Raqam r;
  const _RaqamKarti({required this.r});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tema = Theme.of(context).textTheme;
    final yaziRengi = r.tund ? Colors.white : scheme.onSurface;
    return Card(
      color: r.tund ? scheme.primary : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(r.ikon, size: 20, color: yaziRengi),
            const SizedBox(height: 8),
            Text(r.deyer,
                style: tema.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold, color: yaziRengi)),
            Text(r.ad, style: tema.bodySmall?.copyWith(color: yaziRengi)),
          ],
        ),
      ),
    );
  }
}

class _DermanKarti extends StatelessWidget {
  final AnaMelumat m;
  const _DermanKarti({required this.m});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final stil = tema.bodySmall;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Darman üzra', style: tema.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(child: SizedBox.shrink()),
                SizedBox(width: 56, child: Text('Qaliq', textAlign: TextAlign.right, style: stil)),
                SizedBox(width: 60, child: Text('Satilib', textAlign: TextAlign.right, style: stil)),
                SizedBox(width: 56, child: Text('Resept', textAlign: TextAlign.right, style: stil)),
              ],
            ),
            const Divider(height: 12),
            for (final d in m.dermanlar)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.dermanRengi(d.sira),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(d.ad, style: tema.bodyLarge)),
                    SizedBox(
                      width: 56,
                      child: Text('${d.qaliq}',
                          textAlign: TextAlign.right,
                          style: tema.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text('${d.satilib}',
                          textAlign: TextAlign.right, style: tema.bodyLarge),
                    ),
                    SizedBox(
                      width: 56,
                      child: Text('${d.resept}',
                          textAlign: TextAlign.right, style: tema.bodyLarge),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RegionQrafiki extends StatelessWidget {
  final AnaMelumat m;
  const _RegionQrafiki({required this.m});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tema = Theme.of(context).textTheme;
    final en = m.regionlar.fold<int>(0, (a, r) => r.satilib > a ? r.satilib : a);
    final maxY = en == 0 ? 1.0 : en * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Regionlar üzra satiş', style: tema.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (v, meta) {
                          final i = v.toInt();
                          if (i < 0 || i >= m.regionlar.length) {
                            return const SizedBox.shrink();
                          }
                          final r = m.regionlar[i];
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              children: [
                                Text('${r.satilib}',
                                    style: tema.titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold)),
                                Text(r.ad,
                                    style: tema.bodySmall,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < m.regionlar.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: m.regionlar[i].satilib.toDouble(),
                            width: 28,
                            color: scheme.primary,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SonQeydler extends StatelessWidget {
  final List<SonQeyd> siyahi;
  const _SonQeydler({required this.siyahi});

  (String, IconData) _novu(String n) => switch (n) {
        'satis' => ('Satiş', Icons.shopping_cart_outlined),
        'resept' => ('Resept', Icons.description_outlined),
        _ => ('Geri qaytarma', Icons.assignment_return_outlined),
      };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Son qeydlar', style: tema.titleMedium),
            const SizedBox(height: 8),
            if (siyahi.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Hala qeyd yoxdur. Stok tabindan qeyd alava et.'),
              ),
            for (final q in siyahi)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(_novu(q.novu).$2),
                title: Text('${q.derman} · ${q.pointAd}'),
                subtitle: Text('${_novu(q.novu).$1} · ${tarixGoster(q.tarix)}'),
                trailing: Text('${q.say}',
                    style: tema.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}