import 'dart:async';

import 'package:flutter/material.dart';

import 'entry_form.dart';
import 'l10n.dart';
import 'history_screen.dart';
import 'stock_models.dart';
import 'stock_service.dart';
import 'stock_request_screen.dart';
import 'stock_request_service.dart';
import 'theme/app_theme.dart';
import 'widgets/state_widgets.dart';

List<String> _sonAylar(int say) {
  final indi = DateTime.now();
  final netice = <String>[];
  for (var i = 0; i < say; i++) {
    final d = DateTime(indi.year, indi.month - i, 1);
    netice.add('${d.year}-${d.month.toString().padLeft(2, '0')}');
  }
  return netice;
}

class StokEkrani extends StatelessWidget {
  final bool aktiv;
  const StokEkrani({super.key, this.aktiv = true});

  @override
  Widget build(BuildContext context) {
    return AsyncGorunus<StokSecimleri>(
      yukle: StokServisi.secimler,
      bosdur: (s) => s.regionlar.isEmpty || s.dermanlar.isEmpty,
      bosIkon: Icons.inventory_2_outlined,
      bosMetn: t('region_derman_teyin_edilmeyib'),
      qur: (context, s) => _StokForma(secimler: s, aktiv: aktiv),
    );
  }
}

class _StokForma extends StatefulWidget {
  final StokSecimleri secimler;
  final bool aktiv;
  const _StokForma({required this.secimler, required this.aktiv});

  @override
  State<_StokForma> createState() => _StokFormaState();
}

class _StokFormaState extends State<_StokForma> with WidgetsBindingObserver {
  final List<String> _aylar = _sonAylar(12);
  late int _region = widget.secimler.regionlar.first.id;
  late String _ay = _aylar.first;
  int _derman = 0; // 0 = bütün dərmanlar
  int _acar = 0;
  int _sorguSayi = 0;
  bool _aktiv = true;
  Timer? _timer;
  StokNeticesi? _son;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    StokTalebServisi.deyisdi.addListener(_yenile);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _yenile());
  }

  void _yenile() {
    if (mounted && widget.aktiv && _aktiv && _sorguSayi == 0) {
      setState(() => _acar++);
    }
  }

  @override
  void didUpdateWidget(covariant _StokForma oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.aktiv && !oldWidget.aktiv) _yenile();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _aktiv = state == AppLifecycleState.resumed;
    if (_aktiv) _yenile();
  }

  @override
  void dispose() {
    _timer?.cancel();
    StokTalebServisi.deyisdi.removeListener(_yenile);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<StokNeticesi> _yukle() async {
    _sorguSayi++;
    try {
      final netice = await StokServisi.yukle(
        region: _region,
        ay: _ay,
        derman: _derman == 0 ? null : _derman,
      );
      _son = netice;
      return netice;
    } finally {
      _sorguSayi--;
    }
  }

  Future<void> _qeydAc({int? noqteId, int? dermanId}) async {
    final n = _son;
    if (n == null || n.noqteler.isEmpty) return;
    final ugurlu = await qeydFormuAc(
      context,
      noqteler: n.noqteler,
      seciliNoqteId: noqteId,
      seciliDermanId: dermanId ?? (_derman == 0 ? null : _derman),
      regionId: _region,
      dermanlar: widget.secimler.dermanlar,
      cariAy: n.cariAy,
    );
    if (ugurlu == true && mounted) setState(() => _acar++);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.secimler;
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _qeydAc(),
        icon: const Icon(Icons.add),
        label: Text(t('qeyd_elave_et')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const StokTalebleriEkrani(),
                  ),
                ),
                icon: const Icon(Icons.notification_add_outlined),
                label: Text(t('stok_telebleri')),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownMenu<int>(
                        initialSelection: _region,
                        label: Text(t('region')),
                        expandedInsets: EdgeInsets.zero,
                        requestFocusOnTap: false,
                        dropdownMenuEntries: [
                          for (final r in s.regionlar)
                            DropdownMenuEntry(value: r.id, label: r.ad),
                        ],
                        onSelected: (v) {
                          if (v != null) setState(() => _region = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownMenu<String>(
                        key: ValueKey(
                          'month-${Localizations.localeOf(context)}',
                        ),
                        initialSelection: _ay,
                        label: Text(t('ay')),
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
                  ],
                ),
                const SizedBox(height: 8),
                DropdownMenu<int>(
                  key: ValueKey('medicine-${Localizations.localeOf(context)}'),
                  initialSelection: _derman,
                  label: Text(t('derman')),
                  expandedInsets: EdgeInsets.zero,
                  requestFocusOnTap: false,
                  dropdownMenuEntries: [
                    DropdownMenuEntry(value: 0, label: t('butun_dermanlar')),
                    for (final d in s.dermanlar)
                      DropdownMenuEntry(
                        value: d.id,
                        label: d.ad,
                        leadingIcon: Icon(
                          Icons.circle,
                          size: 12,
                          color: AppTheme.dermanRengi(d.sira),
                        ),
                      ),
                  ],
                  onSelected: (v) {
                    if (v != null) setState(() => _derman = v);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: AsyncGorunus<StokNeticesi>(
              key: ValueKey('$_region|$_ay|$_derman|$_acar'),
              yukle: _yukle,
              bosdur: (n) => n.noqteler.isEmpty,
              bosIkon: Icons.store_outlined,
              bosMetn: t('aktiv_noqte_yoxdur'),
              qur: (context, n) => RefreshIndicator(
                onRefresh: () async => setState(() => _acar++),
                child: ListView(
                  key: PageStorageKey('stock|$_region|$_ay|$_derman'),
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  children: [
                    _Izah(n: n),
                    const SizedBox(height: 10),
                    _RegionCemi(n: n),
                    const SizedBox(height: 12),
                    for (final p in n.noqteler)
                      _NoqteKarti(
                        p: p,
                        regionId: _region,
                        onTap: () => _qeydAc(noqteId: p.id),
                        onTarixceQayit: () => setState(() => _acar++),
                        onBildir: _ay == _aylar.first
                            ? (d) => stokTalebiAc(
                                context,
                                pointId: p.id,
                                medicineId: d.medicineId,
                              )
                            : null,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rəqəmlərin nə demək olduğunu sadə dillə izah edir.
class _Izah extends StatelessWidget {
  final StokNeticesi n;
  const _Izah({required this.n});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tema = Theme.of(context).textTheme;
    final qaliqSozu = n.cariAy ? t('bu_gune') : t('ayin_sonuna');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              t('qaliq_izah')
                  .replaceAll('{qaliq}', qaliqSozu)
                  .replaceAll('{ay}', ayAdi(n.ay)),
              style: tema.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Üç sütunlu başlıq sətri: Qalıq, Satılıb, Resept
class _SutunBasliqi extends StatelessWidget {
  final Color? reng;
  const _SutunBasliqi({this.reng});

  @override
  Widget build(BuildContext context) {
    final stil = Theme.of(context).textTheme.bodySmall?.copyWith(color: reng);
    return Row(
      children: [
        const Expanded(child: SizedBox.shrink()),
        SizedBox(
          width: 56,
          child: Text(t('qaliq'), textAlign: TextAlign.right, style: stil),
        ),
        SizedBox(
          width: 60,
          child: Text(t('satilib'), textAlign: TextAlign.right, style: stil),
        ),
        SizedBox(
          width: 56,
          child: Text(t('resept'), textAlign: TextAlign.right, style: stil),
        ),
      ],
    );
  }
}

class _RegionCemi extends StatelessWidget {
  final StokNeticesi n;
  const _RegionCemi({required this.n});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tema = Theme.of(context).textTheme;
    final yazi = scheme.onPrimaryContainer;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('region_cemi').replaceAll('{ay}', ayAdi(n.ay)),
              style: tema.titleSmall?.copyWith(color: yazi),
            ),
            const SizedBox(height: 8),
            _SutunBasliqi(reng: yazi),
            const SizedBox(height: 4),
            for (final d in n.cemi)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    _Noqte(AppTheme.dermanRengi(d.sira)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        d.ad,
                        style: tema.bodyLarge?.copyWith(color: yazi),
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      child: Text(
                        '${d.qaliq}',
                        textAlign: TextAlign.right,
                        style: tema.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: yazi,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '${d.satilib}',
                        textAlign: TextAlign.right,
                        style: tema.bodyLarge?.copyWith(color: yazi),
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      child: Text(
                        '${d.resept}',
                        textAlign: TextAlign.right,
                        style: tema.bodyLarge?.copyWith(color: yazi),
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

class _Noqte extends StatelessWidget {
  final Color reng;
  const _Noqte(this.reng);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: reng, shape: BoxShape.circle),
    );
  }
}

class _NoqteKarti extends StatelessWidget {
  final StokNoqte p;
  final int regionId;
  final VoidCallback onTap;
  final VoidCallback onTarixceQayit;
  final void Function(NoqteDerman)? onBildir;
  const _NoqteKarti({
    required this.p,
    required this.regionId,
    required this.onTap,
    required this.onTarixceQayit,
    this.onBildir,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(p.ad, style: tema.titleMedium)),
                  IconButton(
                    tooltip: t('qeyd_tarixcesi'),
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.history, size: 20),
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => TarixceEkrani(
                            regionId: regionId,
                            noqteId: p.id,
                            basliq: p.ad,
                          ),
                        ),
                      );
                      onTarixceQayit();
                    },
                  ),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: Icon(
                      p.novu == 'depo'
                          ? Icons.warehouse_outlined
                          : Icons.local_pharmacy_outlined,
                      size: 16,
                    ),
                    label: Text(p.novu == 'depo' ? t('depo') : t('aptek')),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const _SutunBasliqi(),
              const Divider(height: 12),
              for (final d in p.dermanlar) ...[
                _DermanSetri(d: d),
                if (d.status != 'normal' && onBildir != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => onBildir!(d),
                      icon: const Icon(
                        Icons.notification_add_outlined,
                        size: 18,
                      ),
                      label: Text(t('bildir')),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DermanSetri extends StatelessWidget {
  final NoqteDerman d;
  const _DermanSetri({required this.d});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final nisanRengi = switch (d.status) {
      'az' => AppTheme.azQalib,
      'sifir' => AppTheme.bitib,
      _ => null,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _Noqte(AppTheme.dermanRengi(d.sira)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.ad, style: tema.bodyLarge),
                if (nisanRengi != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        d.status == 'az'
                            ? Icons.warning_amber_rounded
                            : Icons.error_outline,
                        size: 14,
                        color: nisanRengi,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        d.status == 'az' ? t('az_qalib') : t('qaliq_yoxdur'),
                        style: tema.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(
              '${d.qaliq}',
              textAlign: TextAlign.right,
              style: tema.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              '${d.satilib}',
              textAlign: TextAlign.right,
              style: tema.bodyLarge,
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(
              '${d.resept}',
              textAlign: TextAlign.right,
              style: tema.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
