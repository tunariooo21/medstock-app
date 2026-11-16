import 'l10n.dart' hide ayAdi;

import 'package:flutter/material.dart';

import 'api_client.dart';
import 'manager_models.dart';
import 'manager_service.dart';
import 'report_screen.dart';
import 'status_chip.dart';
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

/// Menecerin "İşçilər" tabı: işçi siyahısı və hesabat statusları.
class IscilerEkrani extends StatefulWidget {
  const IscilerEkrani({super.key});

  @override
  State<IscilerEkrani> createState() => _IscilerEkraniState();
}

class _IscilerEkraniState extends State<IscilerEkrani> {
  final List<String> _aylar = _sonAylar(12);
  late String _ay = _aylar.first;
  int _acar = 0;

  Future<void> _ac(IsciSetiri isci) async {
    final id = isci.hesabatId;
    if (id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t('Hesabat hələ göndərilməyib'))));
      return;
    }
    final deyisdi = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => HesabatDetalSehifesi(hesabatId: id, iscAd: isci.ad),
      ),
    );
    if (deyisdi == true && mounted) setState(() => _acar++);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: DropdownMenu<String>(
            key: ValueKey('month-${Localizations.localeOf(context)}'),
            initialSelection: _ay,
            label: Text(t('Ay')),
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
        Expanded(
          child: AsyncGorunus<List<IsciSetiri>>(
            key: ValueKey('$_ay|$_acar'),
            yukle: () => MenecerServisi.isciler(_ay),
            bosdur: (l) => l.isEmpty,
            bosIkon: Icons.groups_outlined,
            bosMetn: t('Sənə bağlı işçi yoxdur. Admindən xahiş et.'),
            qur: (context, siyahi) => ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                for (final i in siyahi)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        child: Text(i.ad.isEmpty ? '?' : i.ad[0].toUpperCase()),
                      ),
                      title: Text(i.ad),
                      subtitle: Align(
                        alignment: Alignment.centerLeft,
                        child: StatusNisani(status: i.status),
                      ),
                      trailing: i.cemi == null
                          ? null
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${i.cemi}',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  t('resept'),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                      onTap: () => _ac(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Bir işçinin hesabatının detalı: "Təsdiqlə" və "Geri qaytar".
class HesabatDetalSehifesi extends StatefulWidget {
  final int hesabatId;
  final String iscAd;
  const HesabatDetalSehifesi({
    super.key,
    required this.hesabatId,
    required this.iscAd,
  });

  @override
  State<HesabatDetalSehifesi> createState() => _HesabatDetalSehifesiState();
}

class _HesabatDetalSehifesiState extends State<HesabatDetalSehifesi> {
  int _acar = 0;
  bool _mesgul = false;

  void _bildir(String metn, {bool xeta = false}) {
    if (!mounted) return;
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(metn),
        duration: const Duration(seconds: 3),
        backgroundColor: xeta ? scheme.error : null,
      ),
    );
  }

  Future<void> _tesdiqle() async {
    final tesdiq = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('Hesabat təsdiqlənsin?')),
        content: Text(
          t(
            'Təsdiqləndikdən sonra hesabat dəyişdirilə və geri qaytarıla bilməz.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t('Ləğv et')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t('Təsdiqlə')),
          ),
        ],
      ),
    );
    if (tesdiq != true || !mounted) return;

    setState(() => _mesgul = true);
    try {
      await MenecerServisi.tesdiqle(widget.hesabatId);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop(true);
      messenger.showSnackBar(SnackBar(content: Text(t('Hesabat təsdiqləndi'))));
    } on ApiException catch (e) {
      _bildir(e.mesaj, xeta: true);
      if (mounted) setState(() => _acar++);
    } finally {
      if (mounted) setState(() => _mesgul = false);
    }
  }

  Future<void> _geriQaytar() async {
    final serh = await showDialog<String>(
      context: context,
      builder: (_) => const _SerhDialog(),
    );
    if (serh == null || !mounted) return;

    setState(() => _mesgul = true);
    try {
      await MenecerServisi.geriQaytar(widget.hesabatId, serh);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop(true);
      messenger.showSnackBar(
        SnackBar(content: Text(t('Hesabat şərhlə geri qaytarıldı'))),
      );
    } on ApiException catch (e) {
      _bildir(e.mesaj, xeta: true);
      if (mounted) setState(() => _acar++);
    } finally {
      if (mounted) setState(() => _mesgul = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.iscAd)),
      body: AsyncGorunus<HesabatDetali>(
        key: ValueKey(_acar),
        yukle: () => MenecerServisi.detal(widget.hesabatId),
        qur: (context, d) => Column(
          children: [
            Expanded(child: _Detal(d: d)),
            if (d.status == 'gonderildi')
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _mesgul ? null : _geriQaytar,
                          child: Text(t('Geri qaytar')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _mesgul ? null : _tesdiqle,
                          child: Text(t('Təsdiqlə')),
                        ),
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

class _Detal extends StatelessWidget {
  final HesabatDetali d;
  const _Detal({required this.d});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tema = Theme.of(context).textTheme;
    final dermanXeritesi = {for (final x in d.dermanlar) x.medicineId: x};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: Text(ayAdi(d.ay), style: tema.headlineSmall)),
            StatusNisani(status: d.status),
          ],
        ),
        if (d.status == 'geri_qaytarildi' && (d.serh ?? '').isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${t('Sənin şərhin')}: ${d.serh}'),
          ),
        ],
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t('Dərman üzrə cəmi'), style: tema.titleMedium),
                const SizedBox(height: 8),
                if (d.dermanlar.isEmpty) Text(t('Qeyd yoxdur')),
                for (final x in d.dermanlar)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppTheme.dermanRengi(x.sira),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(x.ad)),
                        Text(
                          '${x.cemi}',
                          style: tema.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(),
                Row(
                  children: [
                    Expanded(child: Text(t('Ümumi'))),
                    Text(
                      '${d.cemi}',
                      style: tema.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(t('Həkimlər üzrə'), style: tema.titleMedium),
        const SizedBox(height: 8),
        for (final h in d.hekimler)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(h.ad, style: tema.titleSmall)),
                      Text(
                        '${h.cemi}',
                        style: tema.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    [
                      h.clinicAd,
                      if ((h.ixtisas ?? '').isNotEmpty) h.ixtisas!,
                    ].join(' · '),
                    style: tema.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      for (final e in h.say.entries)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppTheme.dermanRengi(
                                  dermanXeritesi[e.key]?.sira ?? 0,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${dermanXeritesi[e.key]?.ad ?? '?'}: ${e.value}',
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SerhDialog extends StatefulWidget {
  const _SerhDialog();

  @override
  State<_SerhDialog> createState() => _SerhDialogState();
}

class _SerhDialogState extends State<_SerhDialog> {
  final _c = TextEditingController();
  String? _xeta;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t('Hesabatı geri qaytar')),
      content: TextField(
        controller: _c,
        autofocus: true,
        maxLength: 500,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: t('Nümayəndəyə şərh'),
          border: const OutlineInputBorder(),
          errorText: _xeta,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t('Ləğv et')),
        ),
        FilledButton(
          onPressed: () {
            final metn = _c.text.trim();
            if (metn.isEmpty) {
              setState(() => _xeta = t('Şərh yaz'));
              return;
            }
            Navigator.pop(context, metn);
          },
          child: Text(t('Geri qaytar')),
        ),
      ],
    );
  }
}
