import 'l10n.dart' hide ayAdi;

import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'report_screen.dart';
import 'summary_models.dart';
import 'summary_service.dart';
import 'theme/app_theme.dart';
import 'widgets/state_widgets.dart';

String _qisaAy(String ay) => L10n.qisaAyAdi(ay);

List<String> _sonAylar(int say) {
  final indi = DateTime.now();
  final netice = <String>[];
  for (var i = 0; i < say; i++) {
    final d = DateTime(indi.year, indi.month - i, 1);
    netice.add('${d.year}-${d.month.toString().padLeft(2, '0')}');
  }
  return netice;
}

/// Hesabatı doldurma ekranını ayrıca səhifə kimi açır.
class HesabatDoldurSehifesi extends StatelessWidget {
  const HesabatDoldurSehifesi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t('Hesabatı doldur'))),
      body: const HesabatEkrani(),
    );
  }
}

class QrafiklerEkrani extends StatefulWidget {
  final bool menecer;
  const QrafiklerEkrani({super.key, this.menecer = false});

  @override
  State<QrafiklerEkrani> createState() => _QrafiklerEkraniState();
}

class _QrafiklerEkraniState extends State<QrafiklerEkrani> {
  final List<String> _aylar = _sonAylar(12);
  late String _ay = _aylar.first;
  int? _region;
  int _acar = 0;
  List<RegionItem> _regionlar = [];

  @override
  void initState() {
    super.initState();
    _regionlariYukle();
  }

  Future<void> _regionlariYukle() async {
    try {
      final r = await XulaseServisi.regionlar();
      if (mounted) setState(() => _regionlar = r);
    } catch (_) {
      // Region siyahısı gəlməsə, yalnız "Bütün regionlar" qalır
    }
  }

  Future<void> _doldur() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const HesabatDoldurSehifesi()));
    if (mounted) setState(() => _acar++);
  }

  @override
  Widget build(BuildContext context) {
    final govde = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: DropdownMenu<String>(
                  key: ValueKey('month-${Localizations.localeOf(context)}'),
                  initialSelection: _ay,
                  expandedInsets: EdgeInsets.zero,
                  requestFocusOnTap: false,
                  dropdownMenuEntries: [
                    for (final a in _aylar)
                      DropdownMenuEntry(value: a, label: ayAdi(a)),
                  ],
                  onSelected: (v) {
                    if (v != null) setState(() => _ay = v);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownMenu<int>(
                  key: ValueKey(
                    '${_regionlar.length}-${Localizations.localeOf(context)}',
                  ),
                  initialSelection: _region ?? 0,
                  expandedInsets: EdgeInsets.zero,
                  requestFocusOnTap: false,
                  dropdownMenuEntries: [
                    DropdownMenuEntry(value: 0, label: t('Bütün regionlar')),
                    for (final r in _regionlar)
                      DropdownMenuEntry(value: r.id, label: r.ad),
                  ],
                  onSelected: (v) => setState(
                    () => _region = (v == null || v == 0) ? null : v,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: AsyncGorunus<Xulase>(
            key: ValueKey('$_ay|$_region|$_acar'),
            yukle: () => XulaseServisi.yukle(_ay, _region),
            bosdur: (x) => x.hecNeYoxdur,
            bosIkon: Icons.bar_chart,
            bosMetn: widget.menecer
                ? t('Bu dövr üçün göndərilmiş hesabat yoxdur')
                : t('Bu dövr üçün hələ qeyd yoxdur'),
            bosDuymeAdi: widget.menecer ? null : t('Hesabatı doldur'),
            bosDuymeEmeliyyati: widget.menecer ? null : _doldur,
            qur: (context, x) => _Kartlar(xulase: x, menecer: widget.menecer),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: widget.menecer
          ? null
          : FloatingActionButton.extended(
              onPressed: _doldur,
              icon: const Icon(Icons.edit_note),
              label: Text(t('Hesabatı doldur')),
            ),
      body: govde,
    );
  }
}

class _Kartlar extends StatelessWidget {
  final Xulase xulase;
  final bool menecer;
  const _Kartlar({required this.xulase, required this.menecer});

  @override
  Widget build(BuildContext context) {
    final x = xulase;
    final esas = Theme.of(context).colorScheme.primary;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      children: [
        _Kart(
          basliq: t('Ümumi göstəricilər'),
          child: _UmumiGostericiler(dermanlar: x.dermanlar),
        ),
        _Kart(
          basliq: t('Dərman üzrə'),
          child: _SutunQrafiki(
            dilimler: [
              for (final d in x.dermanlar)
                _Dilim(d.ad, d.cemi, AppTheme.dermanRengi(d.sira)),
            ],
          ),
        ),
        _Kart(
          basliq: t('Ən çox yazan həkimlər'),
          child: _HekimlerZolagi(hekimler: x.hekimler, dermanlar: x.dermanlar),
        ),
        _Kart(
          basliq: t('Son 6 ay'),
          child: _XettQrafiki(aylar: x.son6Ay),
        ),
        if (menecer && x.iscilar != null)
          _Kart(
            basliq: t('İşçilər üzrə'),
            child: _TekZolaqlar(
              basliq: t('Bütün işçilər'),
              siyahi: x.iscilar!,
              bosMetn: t('Bu ay göndərilmiş hesabat yoxdur'),
            ),
          ),
        if (menecer && x.regionlar != null)
          _Kart(
            basliq: t('Regionlar üzrə'),
            child: _SutunQrafiki(
              dilimler: [
                for (final r in x.regionlar!.take(6))
                  _Dilim(r.ad, r.cemi, esas),
              ],
            ),
          ),
      ],
    );
  }
}

class _Kart extends StatelessWidget {
  final String basliq;
  final Widget child;
  const _Kart({required this.basliq, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(basliq, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _Dilim {
  final String ad;
  final int deyer;
  final Color reng;
  const _Dilim(this.ad, this.deyer, this.reng);
}

class _Efsane extends StatelessWidget {
  final Color reng;
  final String metn;
  const _Efsane(this.reng, this.metn);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: reng, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(metn, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// ---------- 1. Ümumi göstəricilər ----------

class _UmumiGostericiler extends StatelessWidget {
  final List<DermanXulase> dermanlar;
  const _UmumiGostericiler({required this.dermanlar});

  @override
  Widget build(BuildContext context) {
    if (dermanlar.isEmpty) return Text(t('Dərman yoxdur'));
    return LayoutBuilder(
      builder: (context, c) {
        final n = math.min(dermanlar.length, 3);
        final eni = (c.maxWidth - 8 * (n - 1)) / n - 0.01;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final d in dermanlar)
              SizedBox(
                width: eni,
                child: _Gosterici(d: d),
              ),
          ],
        );
      },
    );
  }
}

class _Gosterici extends StatelessWidget {
  final DermanXulase d;
  const _Gosterici({required this.d});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tema = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppTheme.dermanRengi(d.sira),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  d.ad,
                  overflow: TextOverflow.ellipsis,
                  style: tema.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${d.cemi}',
            style: tema.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          _Ferq(faiz: d.ferqFaiz),
        ],
      ),
    );
  }
}

class _Ferq extends StatelessWidget {
  final double? faiz;
  const _Ferq({required this.faiz});

  @override
  Widget build(BuildContext context) {
    final stil = Theme.of(context).textTheme.bodySmall;
    final f = faiz;
    if (f == null) return Text(t('Keçən ay yoxdur'), style: stil);
    if (f == 0) return Text(t('Dəyişməyib'), style: stil);
    final artim = f > 0;
    final reng = artim ? AppTheme.ugur : Colors.red.shade700;
    return Row(
      children: [
        Icon(
          artim ? Icons.arrow_upward : Icons.arrow_downward,
          size: 14,
          color: reng,
        ),
        const SizedBox(width: 2),
        Text(
          '${f.abs().toStringAsFixed(0)}%',
          style: stil?.copyWith(color: reng, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// ---------- 2. Sütun qrafiki (dərman üzrə, regionlar üzrə) ----------

class _SutunQrafiki extends StatelessWidget {
  final List<_Dilim> dilimler;
  const _SutunQrafiki({required this.dilimler});

  @override
  Widget build(BuildContext context) {
    if (dilimler.isEmpty) return Text(t('Məlumat yoxdur'));
    final enCox = dilimler.map((d) => d.deyer).reduce(math.max);
    final maxY = math.max(5, enCox * 1.3).toDouble();
    final reqemStili =
        Theme.of(context).textTheme.labelLarge
            ?.copyWith(fontWeight: FontWeight.bold) ??
        const TextStyle(fontWeight: FontWeight.bold);

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(show: false),
              barTouchData: BarTouchData(
                enabled: false,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => Colors.transparent,
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: 4,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                      BarTooltipItem('${rod.toY.round()}', reqemStili),
                ),
              ),
              barGroups: [
                for (var i = 0; i < dilimler.length; i++)
                  BarChartGroupData(
                    x: i,
                    showingTooltipIndicators: [0],
                    barRods: [
                      BarChartRodData(
                        toY: dilimler[i].deyer.toDouble(),
                        color: dilimler[i].reng,
                        width: 28,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            for (final d in dilimler) _Efsane(d.reng, '${d.ad}: ${d.deyer}'),
          ],
        ),
      ],
    );
  }
}

// ---------- 3. Ən çox yazan həkimlər (üfüqi zolaq) ----------

void _hamisiniGoster(BuildContext context, String basliq, List<AdCemi> siyahi) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.7,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(basliq, style: Theme.of(ctx).textTheme.titleMedium),
            ),
            for (final s in siyahi)
              ListTile(
                title: Text(s.ad),
                trailing: Text(
                  '${s.cemi}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _HekimlerZolagi extends StatelessWidget {
  final List<HekimXulase> hekimler;
  final List<DermanXulase> dermanlar;
  const _HekimlerZolagi({required this.hekimler, required this.dermanlar});

  @override
  Widget build(BuildContext context) {
    if (hekimler.isEmpty) return Text(t('Bu ay üçün həkim qeydi yoxdur'));
    final renglar = {
      for (final d in dermanlar) d.id: AppTheme.dermanRengi(d.sira),
    };
    final ilk5 = hekimler.take(5).toList();
    final enCox = math.max(1, ilk5.first.cemi);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final h in ilk5)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(h.ad, overflow: TextOverflow.ellipsis),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final eni = math.max(4.0, c.maxWidth * h.cemi / enCox);
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            width: eni,
                            height: 16,
                            child: Row(
                              children: [
                                for (final e in h.dermanlar.entries)
                                  Expanded(
                                    flex: math.max(1, e.value),
                                    child: Container(
                                      color: renglar[e.key] ?? Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${h.cemi}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            for (final d in dermanlar)
              _Efsane(AppTheme.dermanRengi(d.sira), d.ad),
          ],
        ),
        if (hekimler.length > 5)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _hamisiniGoster(context, t('Bütün həkimlər'), [
                for (final h in hekimler)
                  AdCemi(id: h.id, ad: h.ad, cemi: h.cemi),
              ]),
              child: Text('${t('Hamısına bax')} (${hekimler.length})'),
            ),
          ),
      ],
    );
  }
}

// ---------- 4. Son 6 ay (xətt qrafiki) ----------

class _XettQrafiki extends StatelessWidget {
  final List<AyCemi> aylar;
  const _XettQrafiki({required this.aylar});

  @override
  Widget build(BuildContext context) {
    if (aylar.length < 2) return Text(t('Məlumat yoxdur'));
    final scheme = Theme.of(context).colorScheme;
    final tema = Theme.of(context).textTheme;
    final enCox = aylar.map((a) => a.cemi).fold<int>(0, math.max);
    final maxY = math.max(5, enCox * 1.3).toDouble();

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (aylar.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(show: false),
                lineTouchData: LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < aylar.length; i++)
                        FlSpot(i.toDouble(), aylar[i].cemi.toDouble()),
                    ],
                    isCurved: true,
                    color: scheme.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Ay adı və rəqəm: hər nöqtənin altında
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final a in aylar)
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Text(_qisaAy(a.ay), style: tema.bodySmall),
                    Text(
                      '${a.cemi}',
                      style: tema.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ---------- Menecer üçün: işçilər üzrə zolaqlar ----------

class _TekZolaqlar extends StatelessWidget {
  final String basliq;
  final List<AdCemi> siyahi;
  final String bosMetn;
  const _TekZolaqlar({
    required this.basliq,
    required this.siyahi,
    required this.bosMetn,
  });

  @override
  Widget build(BuildContext context) {
    if (siyahi.isEmpty) return Text(bosMetn);
    final reng = Theme.of(context).colorScheme.primary;
    final ilk5 = siyahi.take(5).toList();
    final enCox = math.max(1, ilk5.first.cemi);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in ilk5)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(s.ad, overflow: TextOverflow.ellipsis),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final eni = math.max(4.0, c.maxWidth * s.cemi / enCox);
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: eni,
                          height: 16,
                          decoration: BoxDecoration(
                            color: reng,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${s.cemi}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        if (siyahi.length > 5)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _hamisiniGoster(context, basliq, siyahi),
              child: Text('${t('Hamısına bax')} (${siyahi.length})'),
            ),
          ),
      ],
    );
  }
}
