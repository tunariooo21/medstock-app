import 'l10n.dart' hide ayAdi;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'history_service.dart';
import 'report_screen.dart' show ayAdi;
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

String _iso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _gosterTarix(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

String _gosterVaxt(String? iso) {
  if (iso == null) return '';
  final d = DateTime.tryParse(iso);
  if (d == null) return '';
  return '${_gosterTarix(iso)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _NovGorunus {
  final IconData ikon;
  final Color reng;
  final String ad;
  const _NovGorunus(this.ikon, this.reng, this.ad);
}

_NovGorunus _novGorunus(String novu) => switch (novu) {
  'satis' => _NovGorunus(
    Icons.shopping_cart_outlined,
    Color(0xFF2979D6),
    t('Satış'),
  ),
  'geri_qaytarma' => _NovGorunus(
    Icons.undo_rounded,
    Color(0xFF17B07A),
    t('Geri qaytarma'),
  ),
  'daxilolma' => _NovGorunus(
    Icons.move_to_inbox_outlined,
    Color(0xFF8E5BD6),
    t('Daxilolma'),
  ),
  _ => _NovGorunus(Icons.description_outlined, Color(0xFFEF6A35), t('Resept')),
};

/// Bir nöqtənin (və ya bütün regionun) qeyd tarixçəsi.
class TarixceEkrani extends StatefulWidget {
  final int regionId;
  final int? noqteId;
  final String basliq;
  const TarixceEkrani({
    super.key,
    required this.regionId,
    this.noqteId,
    required this.basliq,
  });

  @override
  State<TarixceEkrani> createState() => _TarixceEkraniState();
}

class _TarixceEkraniState extends State<TarixceEkrani> {
  final _aylar = _sonAylar(12);
  String? _ay; // null = bütün aylar
  String? _novu; // null = hamısı
  int _acar = 0;
  bool _ixracGetdirir = false;

  Future<List<TarixceQeyd>> _yukle() => TarixceServisi.yukle(
    region: widget.regionId,
    noqteId: widget.noqteId,
    ay: _ay,
    novu: _novu,
  );

  Future<void> _ixrac() async {
    setState(() => _ixracGetdirir = true);
    try {
      final baytlar = await TarixceServisi.ixrac(
        region: widget.regionId,
        ay: _ay,
      );
      final faylAdi =
          'medstock-qeydler-${widget.regionId}-${_ay ?? 'butun'}.xlsx';
      if (kIsWeb) {
        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile.fromData(
                baytlar,
                name: faylAdi,
                mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
              ),
            ],
          ),
        );
      } else {
        final qovluq = await getTemporaryDirectory();
        final yol = '${qovluq.path}/$faylAdi';
        final fayl = XFile.fromData(baytlar, name: faylAdi);
        await fayl.saveTo(yol);
        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile(
                yol,
                name: faylAdi,
                mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
              ),
            ],
            text: t('Medstock qeyd tarixçəsi'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t('Excel faylı hazırlanmadı')}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _ixracGetdirir = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.basliq),
        actions: [
          if (_ixracGetdirir)
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              tooltip: t('Excel kimi ixrac et'),
              icon: const Icon(Icons.download_outlined),
              onPressed: _ixrac,
            ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final secim in <(String?, String)>[
                  (null, t('Hamısı')),
                  ('satis', t('Satış')),
                  ('geri_qaytarma', t('Geri qaytarma')),
                  ('daxilolma', t('Daxilolma')),
                  ('resept', t('Resept')),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(secim.$2),
                      selected: _novu == secim.$1,
                      onSelected: (_) => setState(() => _novu = secim.$1),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: DropdownMenu<String?>(
              key: ValueKey('month-${Localizations.localeOf(context)}'),
              initialSelection: _ay,
              label: Text(t('Ay')),
              expandedInsets: EdgeInsets.zero,
              requestFocusOnTap: false,
              dropdownMenuEntries: [
                DropdownMenuEntry(value: null, label: t('Bütün aylar')),
                for (final a in _aylar)
                  DropdownMenuEntry(value: a, label: ayAdi(a)),
              ],
              onSelected: (v) => setState(() => _ay = v),
            ),
          ),
          Expanded(
            child: AsyncGorunus<List<TarixceQeyd>>(
              key: ValueKey(
                '${widget.regionId}|${widget.noqteId}|$_ay|$_novu|$_acar',
              ),
              yukle: _yukle,
              bosdur: (s) => s.isEmpty,
              bosIkon: Icons.history,
              bosMetn: t('Bu filtr üzrə qeyd tapılmadı'),
              qur: (context, siyahi) => RefreshIndicator(
                onRefresh: () async => setState(() => _acar++),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: siyahi.length,
                  itemBuilder: (context, i) => _QeydKarti(
                    q: siyahi[i],
                    onDeyisiklik: () => setState(() => _acar++),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QeydKarti extends StatelessWidget {
  final TarixceQeyd q;
  final VoidCallback onDeyisiklik;
  const _QeydKarti({required this.q, required this.onDeyisiklik});

  Future<void> _detayAc(BuildContext context) async {
    final deyisdi = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _DetayVereq(q: q),
    );
    if (deyisdi == true) onDeyisiklik();
  }

  @override
  Widget build(BuildContext context) {
    final nov = _novGorunus(q.novu);
    final tema = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _detayAc(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: nov.reng.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(nov.ikon, size: 20, color: nov.reng),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.derman, style: tema.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      [
                        nov.ad,
                        q.pointAd,
                        _gosterTarix(q.tarix),
                        if (q.userAd != null) q.userAd!,
                      ].join(' · '),
                      style: tema.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '${q.say}',
                style: tema.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (q.duzeldilebilir)
                _QeydMenyu(q: q, onDeyisiklik: onDeyisiklik),
            ],
          ),
        ),
      ),
    );
  }
}

class _QeydMenyu extends StatelessWidget {
  final TarixceQeyd q;
  final VoidCallback onDeyisiklik;
  const _QeydMenyu({required this.q, required this.onDeyisiklik});

  Future<void> _duzeltAc(BuildContext context) async {
    final deyisdi = await showDialog<bool>(
      context: context,
      builder: (_) => _DuzelisPencere(q: q),
    );
    if (deyisdi == true) onDeyisiklik();
  }

  Future<void> _silTesdiqle(BuildContext context) async {
    final tesdiq = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('Qeydi sil?')),
        content: Text(
          '${q.derman} · ${q.pointAd} · ${q.say} ${t('eded')} (${_gosterTarix(q.tarix)}) '
          '${t('qeydi silinəcək. Qalıq yenidən hesablanacaq.')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t('Ləğv et')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.xeta),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t('Sil')),
          ),
        ],
      ),
    );
    if (tesdiq != true || !context.mounted) return;
    try {
      await TarixceServisi.sil(q);
      onDeyisiklik();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t('Qeyd silindi'))));
      }
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      onSelected: (secim) {
        if (secim == 'duzelt') {
          _duzeltAc(context);
        } else {
          _silTesdiqle(context);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'duzelt', child: Text(t('Düzəliş et'))),
        PopupMenuItem(
          value: 'sil',
          child: Text(t('Sil'), style: TextStyle(color: AppTheme.xeta)),
        ),
      ],
    );
  }
}

class _DuzelisPencere extends StatefulWidget {
  final TarixceQeyd q;
  const _DuzelisPencere({required this.q});

  @override
  State<_DuzelisPencere> createState() => _DuzelisPencereState();
}

class _DuzelisPencereState extends State<_DuzelisPencere> {
  late final TextEditingController _say = TextEditingController(
    text: '${widget.q.say}',
  );
  late final TextEditingController _sebeb = TextEditingController(
    text: widget.q.sebeb ?? '',
  );
  late DateTime _tarix = DateTime.tryParse(widget.q.tarix) ?? DateTime.now();
  bool _gonderilir = false;

  Future<void> _saxla() async {
    final say = int.tryParse(_say.text.trim()) ?? 0;
    if (say <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t('Say düzgün deyil'))));
      return;
    }
    setState(() => _gonderilir = true);
    try {
      await TarixceServisi.duzelt(
        widget.q,
        say: say,
        tarix: _iso(_tarix),
        sebeb: _sebeb.text.trim().isEmpty ? null : _sebeb.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t('Qeyd yeniləndi'))));
      }
    } on Exception catch (e) {
      setState(() => _gonderilir = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _tarixSec() async {
    final bugun = DateTime.now();
    final secilen = await showDatePicker(
      context: context,
      initialDate: _tarix,
      firstDate: DateTime(bugun.year - 2, 1, 1),
      lastDate: bugun,
    );
    if (secilen != null) setState(() => _tarix = secilen);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t('Qeydə düzəliş')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.q.derman} · ${widget.q.pointAd}',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppTheme.kicik(context)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _say,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: t('Say')),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _tarixSec,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: InputDecoration(labelText: t('Tarix')),
              child: Text(_gosterTarix(_iso(_tarix))),
            ),
          ),
          if (!widget.q.reseptdir) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _sebeb,
              maxLength: 300,
              decoration: InputDecoration(
                labelText: t('Səbəb'),
                counterText: '',
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _gonderilir ? null : () => Navigator.pop(context),
          child: Text(t('Ləğv et')),
        ),
        FilledButton(
          onPressed: _gonderilir ? null : _saxla,
          child: _gonderilir
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(t('Yadda saxla')),
        ),
      ],
    );
  }
}

/// Qeydin tam məlumatı və audit tarixçəsi.
class _DetayVereq extends StatelessWidget {
  final TarixceQeyd q;
  const _DetayVereq({required this.q});

  @override
  Widget build(BuildContext context) {
    final nov = _novGorunus(q.novu);
    final tema = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(nov.ikon, color: nov.reng),
              const SizedBox(width: 8),
              Text(nov.ad, style: tema.titleLarge),
            ],
          ),
          const SizedBox(height: 12),
          _Setir(t('Dərman'), q.derman),
          _Setir(t('Aptek/Depo'), q.pointAd),
          _Setir(t('Say'), '${q.say}'),
          _Setir(t('Tarix'), _gosterTarix(q.tarix)),
          if (q.sebeb != null && q.sebeb!.isNotEmpty)
            _Setir(t('Səbəb'), q.sebeb!),
          if (q.hekim != null) _Setir(t('Həkim'), q.hekim!),
          if (q.userAd != null) _Setir(t('Əlavə edən'), q.userAd!),
          const SizedBox(height: 12),
          Text(t('Dəyişiklik tarixçəsi'), style: tema.titleSmall),
          const SizedBox(height: 4),
          FutureBuilder<List<AuditQeyd>>(
            future: TarixceServisi.audit(q),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final auditlar = snap.data ?? [];
              if (auditlar.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    t('Dəyişiklik edilməyib'),
                    style: tema.bodySmall?.copyWith(
                      color: AppTheme.kicik(context),
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  for (final a in auditlar)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            a.action == 'delete'
                                ? Icons.delete_outline
                                : Icons.edit_outlined,
                            size: 18,
                            color: a.action == 'delete'
                                ? AppTheme.xeta
                                : AppTheme.esas(context),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${a.action == 'delete' ? t('Silinib') : t('Düzəliş')}'
                              '${a.userAd != null ? ' · ${a.userAd}' : ''}'
                              '${_gosterVaxt(a.createdAt).isNotEmpty ? ' · ${_gosterVaxt(a.createdAt)}' : ''}'
                              '${a.evvelki != null && a.sonraki != null ? '\n${t('Say')}: ${a.evvelki!['say']} → ${a.sonraki!['say']}' : ''}',
                              style: tema.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Setir extends StatelessWidget {
  final String ad;
  final String deyer;
  const _Setir(this.ad, this.deyer);

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              ad,
              style: tema.bodySmall?.copyWith(color: AppTheme.kicik(context)),
            ),
          ),
          Expanded(child: Text(deyer, style: tema.bodyMedium)),
        ],
      ),
    );
  }
}
