import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'api_client.dart';
import 'entry_service.dart';
import 'l10n.dart';
import 'report_models.dart';
import 'stock_models.dart';
import 'theme/app_theme.dart';

enum _Novu { satis, resept, geriQaytarma }

String _iso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _gosterTarix(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

/// Qeyd əlavə etmə formasını açır. Qeyd yazılıbsa true qaytarır.
Future<bool?> qeydFormuAc(
  BuildContext context, {
  required List<StokNoqte> noqteler,
  int? seciliNoqteId,
  int? seciliDermanId,
  required int regionId,
  required List<Derman> dermanlar,
  required bool cariAy,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _QeydFormu(
      noqteler: noqteler,
      seciliNoqteId: seciliNoqteId,
      seciliDermanId: seciliDermanId,
      regionId: regionId,
      dermanlar: dermanlar,
      cariAy: cariAy,
    ),
  );
}

class _QeydFormu extends StatefulWidget {
  final List<StokNoqte> noqteler;
  final int? seciliNoqteId;
  final int? seciliDermanId;
  final int regionId;
  final List<Derman> dermanlar;
  final bool cariAy;

  const _QeydFormu({
    required this.noqteler,
    required this.seciliNoqteId,
    required this.seciliDermanId,
    required this.regionId,
    required this.dermanlar,
    required this.cariAy,
  });

  @override
  State<_QeydFormu> createState() => _QeydFormuState();
}

class _QeydFormuState extends State<_QeydFormu> {
  _Novu _novu = _Novu.satis;
  int? _noqteId;
  int? _dermanId;
  int? _hekimId;
  late DateTime _tarix;
  Future<List<Hekim>>? _hekimler;
  final _say = TextEditingController();
  final _sebeb = TextEditingController();
  String? _xeta;
  bool _mesgul = false;

  @override
  void initState() {
    super.initState();
    _noqteId = widget.seciliNoqteId;
    _dermanId = widget.seciliDermanId;
    final indi = DateTime.now();
    _tarix = DateTime(indi.year, indi.month, indi.day);
  }

  @override
  void dispose() {
    _say.dispose();
    _sebeb.dispose();
    super.dispose();
  }

  DateTime get _bugun {
    final indi = DateTime.now();
    return DateTime(indi.year, indi.month, indi.day);
  }

  Future<void> _tarixSec() async {
    final secilen = await showDatePicker(
      context: context,
      initialDate: _tarix,
      firstDate: DateTime(_bugun.year - 1, 1, 1),
      lastDate: _bugun,
    );
    if (secilen != null) setState(() => _tarix = secilen);
  }

  int? _joriQaliq() {
    if (!widget.cariAy) return null;
    for (final p in widget.noqteler) {
      if (p.id != _noqteId) continue;
      for (final d in p.dermanlar) {
        if (d.medicineId == _dermanId) return d.qaliq;
      }
    }
    return null;
  }

  String get _novAdi => switch (_novu) {
    _Novu.satis => t('satis'),
    _Novu.resept => t('resept'),
    _Novu.geriQaytarma => t('geri_qaytarma'),
  };

  Future<void> _saxla() async {
    final noqteId = _noqteId;
    final dermanId = _dermanId;
    if (noqteId == null) return setState(() => _xeta = t('aptek_depo_sec'));
    if (dermanId == null) return setState(() => _xeta = t('derman_sec'));
    final say = int.tryParse(_say.text.trim()) ?? 0;
    if (say <= 0) return setState(() => _xeta = t('say_boyuk_olmalidir'));
    if (_novu == _Novu.resept && _hekimId == null) {
      return setState(() => _xeta = t('hekim_sec'));
    }
    setState(() => _xeta = null);

    final noqte = widget.noqteler.firstWhere((p) => p.id == noqteId);
    final derman = widget.dermanlar.firstWhere((d) => d.id == dermanId);
    final qaliq = _joriQaliq();
    final xeberdarliq = _novu == _Novu.satis && qaliq != null && say > qaliq;

    final tesdiq = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('qeyd_yazilsin')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${noqte.ad} · ${derman.ad}'),
            Text('$_novAdi · $say ${t('eded')} · ${_gosterTarix(_tarix)}'),
            if (xeberdarliq) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.azQalib,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t('qaliq_menfi_xeberdarliq').replaceAll('{qaliq}', '$qaliq').replaceAll('{say}', '$say'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(t('qeyd_deyisdirilmir')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t('legv_et')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t('yaz')),
          ),
        ],
      ),
    );
    if (tesdiq != true || !mounted) return;

    setState(() => _mesgul = true);
    try {
      String mesaj;
      if (_novu == _Novu.resept) {
        await EntryServisi.reseptYaz(
          noqteId: noqteId,
          dermanId: dermanId,
          hekimId: _hekimId!,
          say: say,
          tarix: _iso(_tarix),
        );
        mesaj = t('resept_yazildi');
      } else {
        final yeniQaliq = await EntryServisi.hereketYaz(
          noqteId: noqteId,
          dermanId: dermanId,
          novu: _novu == _Novu.satis ? 'satis' : 'geri_qaytarma',
          say: say,
          tarix: _iso(_tarix),
          sebeb: _novu == _Novu.geriQaytarma ? _sebeb.text.trim() : null,
        );
        mesaj = t('qeyd_yazildi_yeni_qaliq').replaceAll('{nov}', _novAdi).replaceAll('{qaliq}', '$yeniQaliq');
      }
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context, true);
      messenger.showSnackBar(
        SnackBar(content: Text(mesaj), duration: const Duration(seconds: 3)),
      );
    } on ApiException catch (e) {
      if (mounted) setState(() => _xeta = e.mesaj);
    } finally {
      if (mounted) setState(() => _mesgul = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('qeyd_elave_et'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<_Novu>(
                segments: [
                  ButtonSegment(value: _Novu.satis, label: Text(t('satis'))),
                  ButtonSegment(value: _Novu.resept, label: Text(t('resept'))),
                  ButtonSegment(
                    value: _Novu.geriQaytarma,
                    label: Text(t('geri_qaytarma')),
                  ),
                ],
                selected: {_novu},
                showSelectedIcon: false,
                onSelectionChanged: (v) => setState(() {
                  _novu = v.first;
                  _xeta = null;
                  if (_novu == _Novu.resept) {
                    _hekimler ??= EntryServisi.hekimler(widget.regionId);
                  }
                }),
              ),
            ),
            const SizedBox(height: 12),
            DropdownMenu<int>(
              initialSelection: _noqteId,
              label: Text(t('aptek_depo')),
              expandedInsets: EdgeInsets.zero,
              requestFocusOnTap: false,
              dropdownMenuEntries: [
                for (final p in widget.noqteler)
                  DropdownMenuEntry(
                    value: p.id,
                    label: '${p.ad} (${p.novu == 'depo' ? t('depo') : t('aptek')})',
                  ),
              ],
              onSelected: (v) => setState(() => _noqteId = v),
            ),
            const SizedBox(height: 12),
            DropdownMenu<int>(
              initialSelection: _dermanId,
              label: Text(t('derman')),
              expandedInsets: EdgeInsets.zero,
              requestFocusOnTap: false,
              dropdownMenuEntries: [
                for (final d in widget.dermanlar)
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
              onSelected: (v) => setState(() => _dermanId = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _say,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                labelText: _novu == _Novu.resept ? t('resept_sayi') : t('say'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _tarixSec,
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text('${t('tarix')}: ${_gosterTarix(_tarix)}'),
            ),
            if (_novu == _Novu.resept) ...[
              const SizedBox(height: 12),
              FutureBuilder<List<Hekim>>(
                future: _hekimler,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.all(8),
                      child: LinearProgressIndicator(),
                    );
                  }
                  if (snap.hasError) {
                    return Text(t('hekimler_yuklenmedi'));
                  }
                  final hekimler = snap.data ?? [];
                  return DropdownMenu<int>(
                    initialSelection: _hekimId,
                    label: Text(t('hekim')),
                    expandedInsets: EdgeInsets.zero,
                    requestFocusOnTap: false,
                    dropdownMenuEntries: [
                      for (final h in hekimler)
                        DropdownMenuEntry(
                          value: h.id,
                          label: '${h.ad} · ${h.clinicAd}',
                        ),
                    ],
                    onSelected: (v) => setState(() => _hekimId = v),
                  );
                },
              ),
            ],
            if (_novu == _Novu.geriQaytarma) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _sebeb,
                maxLength: 300,
                decoration: InputDecoration(
                  labelText: t('sebeb_isteye_gore'),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
            if (_xeta != null) ...[
              const SizedBox(height: 8),
              Text(_xeta!, style: TextStyle(color: scheme.error)),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _mesgul ? null : _saxla,
                child: _mesgul
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(t('yadda_saxla')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
