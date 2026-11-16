import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'home_service.dart';
import 'l10n.dart';
import 'stock_request_service.dart';
import 'theme/app_theme.dart';
import 'widgets/state_widgets.dart';

String _reqem(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
    b.write(s[i]);
  }
  return b.toString();
}

class AnaSehife extends StatefulWidget {
  final bool menecer;
  final bool aktiv;
  final String ad;
  final VoidCallback? onStokaKech;
  final VoidCallback? onGeriQaytarmayaKech;
  const AnaSehife({
    super.key,
    this.menecer = false,
    this.aktiv = true,
    this.ad = '',
    this.onStokaKech,
    this.onGeriQaytarmayaKech,
  });

  @override
  State<AnaSehife> createState() => _AnaSehifeState();
}

class _AnaSehifeState extends State<AnaSehife> with WidgetsBindingObserver {
  int _acar = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    StokTalebServisi.deyisdi.addListener(_yenile);
  }

  void _yenile() {
    if (mounted && widget.aktiv) setState(() => _acar++);
  }

  @override
  void didUpdateWidget(covariant AnaSehife oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.aktiv && !oldWidget.aktiv) _yenile();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _yenile();
  }

  @override
  void dispose() {
    StokTalebServisi.deyisdi.removeListener(_yenile);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AsyncGorunus<AnaMelumat>(
      key: ValueKey(_acar),
      yukle: () => AnaServisi.yukle(menecer: widget.menecer),
      bosdur: (m) => m.regionlar.isEmpty,
      bosIkon: Icons.home_outlined,
      bosMetn: t('region_teyin_edilmeyib'),
      qur: (context, m) => RefreshIndicator(
        onRefresh: () async => setState(() => _acar++),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _Salamlama(ad: widget.ad, ay: m.ay),
            const SizedBox(height: 16),
            _Kartlar(
              m: m,
              menecer: widget.menecer,
              onGeriQaytarmayaKech: widget.onGeriQaytarmayaKech,
            ),
            const SizedBox(height: 16),
            if (!widget.menecer && m.diqqet.isNotEmpty)
              _DiqqetKarti(siyahi: m.diqqet, onStokaKech: widget.onStokaKech),
            if (!widget.menecer && m.diqqet.isNotEmpty)
              const SizedBox(height: 16),
            _DermanKarti(m: m),
            const SizedBox(height: 16),
            if (widget.menecer) _RegionQrafiki(m: m),
          ],
        ),
      ),
    );
  }
}

class _Salamlama extends StatelessWidget {
  final String ad;
  final String ay;
  const _Salamlama({required this.ad, required this.ay});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final ilkAd = ad.trim().isEmpty ? null : ad.trim().split(' ').first;
    final ayMetni = ayAdi(ay);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ilkAd == null ? t('salam') : '${t('salam')}, $ilkAd',
          style: tema.headlineSmall,
        ),
        const SizedBox(height: 2),
        Text(
          '${ayMetni[0].toUpperCase()}${ayMetni.substring(1)}',
          style: tema.bodyMedium?.copyWith(color: AppTheme.kicik(context)),
        ),
      ],
    );
  }
}

class _Kartlar extends StatelessWidget {
  final AnaMelumat m;
  final bool menecer;
  final VoidCallback? onGeriQaytarmayaKech;
  const _Kartlar({
    required this.m,
    required this.menecer,
    this.onGeriQaytarmayaKech,
  });

  @override
  Widget build(BuildContext context) {
    final ucuncu = menecer
        ? _Raqam(
            t('geri_qaytarma'),
            '${m.geriQaytarma ?? 0}',
            Icons.assignment_return_outlined,
          )
        : _Raqam(t('resept'), _reqem(m.resept), Icons.description_outlined);
    final list = [
      _Raqam(t('qaliq'), _reqem(m.qaliq), Icons.inventory_2_outlined, true),
      _Raqam(t('satilib'), _reqem(m.satilib), Icons.shopping_cart_outlined),
      ucuncu,
    ];
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < list.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: _RaqamKarti(
                r: list[i],
                onTap: menecer && i == 2 ? onGeriQaytarmayaKech : null,
              ),
            ),
          ],
        ],
      ),
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
  final VoidCallback? onTap;
  const _RaqamKarti({required this.r, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tema = Theme.of(context).textTheme;
    final yaziRengi = r.tund ? scheme.onPrimary : scheme.onSurface;
    final ikonFon = r.tund
        ? scheme.onPrimary.withValues(alpha: 0.16)
        : scheme.primary.withValues(alpha: 0.10);
    final ikonRengi = r.tund ? scheme.onPrimary : scheme.primary;
    return Card(
      color: r.tund ? scheme.primary : scheme.surface,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: ikonFon,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(r.ikon, size: 19, color: ikonRengi),
              ),
              const SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  r.deyer,
                  maxLines: 1,
                  style: tema.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: yaziRengi,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                r.ad,
                style: tema.bodySmall?.copyWith(
                  color: r.tund
                      ? scheme.onPrimary.withValues(alpha: 0.85)
                      : AppTheme.kicik(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiqqetKarti extends StatelessWidget {
  final List<DiqqetSiyahi> siyahi;
  final VoidCallback? onStokaKech;
  const _DiqqetKarti({required this.siyahi, this.onStokaKech});

  (String, Color, Color) _status(String s) => s == 'sifir'
      ? (t('sifir'), AppTheme.bitib, const Color(0xFFFBE9E7))
      : (t('az_'), AppTheme.azQalib, const Color(0xFFFDF1E3));

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final gosterilen = siyahi.take(5).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppTheme.bitib.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 19,
                    color: AppTheme.bitib,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(t('diqqet_teleb_eden'), style: tema.titleMedium),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.bitib,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${siyahi.length}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            for (final d in gosterilen)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _status(d.status).$3,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        d.status == 'sifir'
                            ? Icons.error_outline
                            : Icons.warning_amber_rounded,
                        size: 16,
                        color: _status(d.status).$2,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _status(d.status).$1,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.yazi,
                        ),
                      ),
                    ],
                  ),
                ),
                title: Text(
                  d.derman,
                  style: tema.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${d.pointAd} · ${d.regionAd}',
                  style: tema.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  '${d.qaliq}',
                  style: tema.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            if (siyahi.length > gosterilen.length)
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 4),
                child: Text(
                  t(
                    've_daha',
                  ).replaceAll('{n}', '${siyahi.length - gosterilen.length}'),
                  style: tema.bodySmall,
                ),
              ),
            if (onStokaKech != null)
              Center(
                child: TextButton(
                  onPressed: onStokaKech,
                  child: Text(t('stok_bolmesine_kech')),
                ),
              ),
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
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('derman_uzre'), style: tema.titleMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(child: SizedBox.shrink()),
                SizedBox(
                  width: 52,
                  child: Text(
                    t('qaliq'),
                    textAlign: TextAlign.right,
                    style: stil,
                  ),
                ),
                SizedBox(
                  width: 58,
                  child: Text(
                    t('satilib'),
                    textAlign: TextAlign.right,
                    style: stil,
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Text(
                    t('resept'),
                    textAlign: TextAlign.right,
                    style: stil,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Divider(),
            for (final d in m.dermanlar)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppTheme.dermanRengi(d.sira),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(child: Text(d.ad, style: tema.bodyLarge)),
                    SizedBox(
                      width: 52,
                      child: Text(
                        '${d.qaliq}',
                        textAlign: TextAlign.right,
                        style: tema.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 58,
                      child: Text(
                        '${d.satilib}',
                        textAlign: TextAlign.right,
                        style: tema.bodyLarge,
                      ),
                    ),
                    SizedBox(
                      width: 52,
                      child: Text(
                        '${d.resept}',
                        textAlign: TextAlign.right,
                        style: tema.bodyLarge,
                      ),
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
    final en = m.regionlar.fold<int>(
      0,
      (a, r) => r.satilib > a ? r.satilib : a,
    );
    final maxY = en == 0 ? 4.0 : (en * 1.25).ceilToDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('regionlar_uzre_satish'), style: tema.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (v) => FlLine(
                      color: scheme.outlineVariant.withValues(alpha: 0.6),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 46,
                        getTitlesWidget: (v, meta) {
                          final i = v.toInt();
                          if (i < 0 || i >= m.regionlar.length) {
                            return const SizedBox.shrink();
                          }
                          final r = m.regionlar[i];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              children: [
                                Text(
                                  '${r.satilib}',
                                  style: tema.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                Text(
                                  r.ad,
                                  style: tema.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                            width: 26,
                            color: scheme.primary,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
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
