import 'package:flutter/material.dart';

import 'api_client.dart';
import 'manager_service.dart';
import 'prices_models.dart';
import 'theme/app_theme.dart';
import 'widgets/state_widgets.dart';

String _pul(double v) => '${v.toStringAsFixed(2)} ₼';

String _iso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class _YeniQiymet {
  final double qiymet;
  final DateTime tarix;
  const _YeniQiymet(this.qiymet, this.tarix);
}

class QiymetlerEkrani extends StatefulWidget {
  const QiymetlerEkrani({super.key});

  @override
  State<QiymetlerEkrani> createState() => _QiymetlerEkraniState();
}

class _QiymetlerEkraniState extends State<QiymetlerEkrani> {
  int _acar = 0;

  Future<void> _yeniQiymet(DermanQiymeti d) async {
    final giris = await showDialog<_YeniQiymet>(
      context: context,
      builder: (_) => _QiymetDialog(derman: d),
    );
    if (giris == null || !mounted) return;

    final tesdiq = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni qiymət əlavə olunsun?'),
        content: Text(
          '${d.ad}: ${_pul(giris.qiymet)}\n'
          'Qüvvəyə minmə: ${tarixGoster(_iso(giris.tarix))}\n\n'
          'Köhnə qiymət tarixçədə qalır.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Ləğv et')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Əlavə et')),
        ],
      ),
    );
    if (tesdiq != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await MenecerServisi.qiymetElave(
          d.medicineId, giris.qiymet, _iso(giris.tarix));
      if (!mounted) return;
      setState(() => _acar++);
      messenger.showSnackBar(const SnackBar(content: Text('Qiymət əlavə olundu')));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text(e.mesaj),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AsyncGorunus<List<DermanQiymeti>>(
      key: ValueKey(_acar),
      yukle: MenecerServisi.qiymetler,
      bosdur: (l) => l.isEmpty,
      bosIkon: Icons.sell_outlined,
      bosMetn: 'Aktiv dərman yoxdur',
      qur: (context, siyahi) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final d in siyahi)
            _DermanKarti(d: d, onYeni: () => _yeniQiymet(d)),
        ],
      ),
    );
  }
}

class _DermanKarti extends StatelessWidget {
  final DermanQiymeti d;
  final VoidCallback onYeni;
  const _DermanKarti({required this.d, required this.onYeni});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final tarixce = d.tarixce;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                Expanded(child: Text(d.ad, style: tema.titleMedium)),
              ],
            ),
            const SizedBox(height: 8),
            if (d.cari == null)
              Text('Qiymət təyin olunmayıb', style: tema.bodyLarge)
            else ...[
              Text(_pul(d.cari!.qiymet),
                  style: tema.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text('${tarixGoster(d.cari!.baslamaTarixi)} tarixindən',
                  style: tema.bodySmall),
            ],
            const SizedBox(height: 8),
            if (tarixce.isNotEmpty)
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text('Tarixçə (${tarixce.length})',
                      style: tema.titleSmall),
                  children: [
                    for (final q in tarixce)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(_pul(q.qiymet)),
                        subtitle: Text([
                          tarixGoster(q.baslamaTarixi),
                          if (q.kim != null) q.kim!,
                        ].join(' · ')),
                      ),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: onYeni,
                icon: const Icon(Icons.add),
                label: const Text('Yeni qiymət'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QiymetDialog extends StatefulWidget {
  final DermanQiymeti derman;
  const _QiymetDialog({required this.derman});

  @override
  State<_QiymetDialog> createState() => _QiymetDialogState();
}

class _QiymetDialogState extends State<_QiymetDialog> {
  final _c = TextEditingController();
  late DateTime _tarix;
  String? _xeta;

  @override
  void initState() {
    super.initState();
    final indi = DateTime.now();
    _tarix = DateTime(indi.year, indi.month, indi.day);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  DateTime get _bugun {
    final indi = DateTime.now();
    return DateTime(indi.year, indi.month, indi.day);
  }

  Future<void> _tarixSec() async {
    final s = await showDatePicker(
      context: context,
      initialDate: _tarix,
      firstDate: _bugun,
      lastDate: DateTime(_bugun.year + 1, _bugun.month, _bugun.day),
    );
    if (s != null) setState(() => _tarix = s);
  }

  void _saxla() {
    final metn = _c.text.trim().replaceAll(',', '.');
    if (!RegExp(r'^\d{1,8}(\.\d{1,2})?$').hasMatch(metn)) {
      setState(() => _xeta = 'Qiyməti düzgün yaz (məs. 12.50)');
      return;
    }
    final v = double.parse(metn);
    if (v <= 0) {
      setState(() => _xeta = 'Qiymət 0-dan böyük olmalıdır');
      return;
    }
    Navigator.pop(context, _YeniQiymet(v, _tarix));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.derman.ad}: yeni qiymət'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _c,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Qiymət (₼)',
                border: const OutlineInputBorder(),
                errorText: _xeta,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _tarixSec,
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text('Qüvvəyə minir: ${tarixGoster(_iso(_tarix))}'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ləğv et')),
        FilledButton(onPressed: _saxla, child: const Text('Davam et')),
      ],
    );
  }
}