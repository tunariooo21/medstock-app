import 'l10n.dart' hide ayAdi;

import 'package:flutter/material.dart';

import 'manager_service.dart';
import 'report_screen.dart' show ayAdi;
import 'returns_models.dart';
import 'prices_models.dart' show tarixGoster;
import 'widgets/state_widgets.dart';

List<String> _sonAylar(int say) {
  final indi = DateTime.now();
  return [
    for (var i = 0; i < say; i++)
      () {
        final d = DateTime(indi.year, indi.month - i, 1);
        return '${d.year}-${d.month.toString().padLeft(2, '0')}';
      }(),
  ];
}

class GeriQaytarmalarEkrani extends StatefulWidget {
  const GeriQaytarmalarEkrani({super.key});

  @override
  State<GeriQaytarmalarEkrani> createState() => _GeriQaytarmalarEkraniState();
}

class _GeriQaytarmalarEkraniState extends State<GeriQaytarmalarEkrani> {
  final List<String> _aylar = _sonAylar(12);
  late String _ay = _aylar.first;

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
          child: AsyncGorunus<GeriQaytarmalar>(
            key: ValueKey(_ay),
            yukle: () => MenecerServisi.geriQaytarmalar(_ay),
            bosdur: (g) => g.siyahi.isEmpty,
            bosIkon: Icons.assignment_return_outlined,
            bosMetn: t('Bu ay üçün geri qaytarma qeydi yoxdur'),
            qur: (context, g) => _Siyahi(g: g),
          ),
        ),
      ],
    );
  }
}

class _Siyahi extends StatelessWidget {
  final GeriQaytarmalar g;
  const _Siyahi({required this.g});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tema = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Card(
          color: scheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${t('Ay üzrə cəmi')} · ${ayAdi(g.ay)}',
                  style: tema.titleSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${g.cemi}',
                  style: tema.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final s in g.siyahi)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Icon(
                s.pointNovu == 'depo'
                    ? Icons.warehouse_outlined
                    : Icons.local_pharmacy_outlined,
              ),
              title: Text('${s.derman} · ${s.pointAd}'),
              subtitle: Text(
                [
                  tarixGoster(s.tarix),
                  s.isciAd,
                  if ((s.sebeb ?? '').isNotEmpty) s.sebeb!,
                ].join(' · '),
              ),
              trailing: Text(
                '${s.say}',
                style: tema.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}
