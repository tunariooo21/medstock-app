import 'package:flutter/material.dart';

import 'entry_form.dart';
import 'report_screen.dart';
import 'stock_models.dart';
import 'stock_service.dart';
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
  const StokEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncGorunus<StokSecimleri>(
      yukle: StokServisi.secimler,
      bosdur: (s) => s.regionlar.isEmpty || s.dermanlar.isEmpty,
      bosIkon: Icons.inventory_2_outlined,
      bosMetn: 'Sənə region və ya dərman təyin olunmayıb. Admindən xahiş et.',
      qur: (context, s) => _StokForma(secimler: s),
    );
  }
}

class _StokForma extends StatefulWidget {
  final StokSecimleri secimler;
  const _StokForma({required this.secimler});

  @override
  State<_StokForma> createState() => _StokFormaState();
}

class _StokFormaState extends State<_StokForma> {
  final List<String> _aylar = _sonAylar(12);
  late int _region = widget.secimler.regionlar.first.id;
  late String _ay = _aylar.first;
  int _derman = 0; // 0 = bütün dərmanlar
  int _acar = 0;
  StokNeticesi? _son;

  Future<StokNeticesi> _yukle() async {
    final netice = await StokServisi.yukle(
      region: _region,
      ay: _ay,
      derman: _derman == 0 ? null : _derman,
    );
    _son = netice;
    return netice;
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
        label: const Text('Qeyd əlavə et'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownMenu<int>(
                        initialSelection: _region,
                        label: const Text('Region'),
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
                        initialSelection: _ay,
                        label: const Text('Ay'),
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
                  initialSelection: _derman,
                  label: const Text('Dərman'),
                  expandedInsets: EdgeInsets.zero,
                  requestFocusOnTap: false,
                  dropdownMenuEntries: [
                    const DropdownMenuEntry(value: 0, label: 'Bütün dərmanlar'),
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
              bosMetn: 'Bu regionda aktiv aptek və ya depo yoxdur',
              qur: (context, n) => ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                children: [
                  _Izah(n: n),
                  const SizedBox(height: 8),
                  _RegionCemi(n: n),
                  const SizedBox(height: 12),
                  for (final p in n.noqteler)
                    _NoqteKarti(
                      p: p,
                      onTap: () => _qeydAc(noqteId: p.id),
                    ),
                ],
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
    final qaliqSozu = n.cariAy ? 'bu günə' : 'ayın sonuna';
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
              'Qalıq: $qaliqSozu aptek və ya depoda olan say.\n'
              'Satılıb və Resept: ${ayAdi(n.ay)} ərzində.',
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
        SizedBox(width: 56, child: Text('Qalıq', textAlign: TextAlign.right, style: stil)),
        SizedBox(width: 60, child: Text('Satılıb', textAlign: TextAlign.right, style: stil)),
        SizedBox(width: 56, child: Text('Resept', textAlign: TextAlign.right, style: stil)),
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
              'Region cəmi · ${ayAdi(n.ay)}',
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
                      child: Text(d.ad, style: tema.bodyLarge?.copyWith(color: yazi)),
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
  final VoidCallback onTap;
  const _NoqteKarti({required this.p, required this.onTap});

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
                  Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: Icon(
                      p.novu == 'depo'
                          ? Icons.warehouse_outlined
                          : Icons.local_pharmacy_outlined,
                      size: 16,
                    ),
                    label: Text(p.novu == 'depo' ? 'Depo' : 'Aptek'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const _SutunBasliqi(),
              const Divider(height: 12),
              for (final d in p.dermanlar) _DermanSetri(d: d),
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
                        d.status == 'az' ? 'Az qalıb' : 'Qalıq yoxdur',
                        style: tema.bodySmall?.copyWith(
                          color: nisanRengi,
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
                color: nisanRengi,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text('${d.satilib}', textAlign: TextAlign.right, style: tema.bodyLarge),
          ),
          SizedBox(
            width: 56,
            child: Text('${d.resept}', textAlign: TextAlign.right, style: tema.bodyLarge),
          ),
        ],
      ),
    );
  }
}