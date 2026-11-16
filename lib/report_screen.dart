import 'l10n.dart' hide ayAdi;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'api_client.dart';
import 'report_models.dart';
import 'report_service.dart';
import 'theme/app_theme.dart';
import 'widgets/state_widgets.dart';

String ayAdi(String ay) => L10n.ayAdi(ay);

class HesabatEkrani extends StatelessWidget {
  const HesabatEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncGorunus<HesabatMelumati>(
      yukle: HesabatServisi.yukle,
      bosdur: (d) => d.hekimler.isEmpty || d.dermanlar.isEmpty,
      bosIkon: Icons.people_outline,
      bosMetn: t(
        'Regionunda aktiv həkim və ya dərman yoxdur. Admindən xahiş et.',
      ),
      qur: (context, d) => _HesabatForma(melumat: d),
    );
  }
}

class _HesabatForma extends StatefulWidget {
  final HesabatMelumati melumat;
  const _HesabatForma({required this.melumat});

  @override
  State<_HesabatForma> createState() => _HesabatFormaState();
}

class _HesabatFormaState extends State<_HesabatForma> {
  late Hesabat _hesabat;
  late Map<String, int> _say;
  bool _deyisib = false;
  bool _mesgul = false;
  String _axtar = '';

  List<Hekim> get _hekimler => widget.melumat.hekimler;
  List<Derman> get _dermanlar => widget.melumat.dermanlar;
  Set<int> get _hekimIdleri => _hekimler.map((h) => h.id).toSet();
  bool get _aktiv => _hesabat.redakteOlunaBiler && !_mesgul;

  @override
  void initState() {
    super.initState();
    _hesabat = widget.melumat.hesabat;
    _say = Map.of(_hesabat.say);
  }

  String _acar(int hekimId, int dermanId) => '$hekimId:$dermanId';

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

  Future<void> _saxla() async {
    setState(() => _mesgul = true);
    try {
      final yeni = await HesabatServisi.saxla(_hesabat.id, _say, _hekimIdleri);
      if (!mounted) return;
      setState(() {
        _hesabat = yeni;
        _say = Map.of(yeni.say);
        _deyisib = false;
      });
      _bildir(t('Yadda saxlandı'));
    } on ApiException catch (e) {
      _bildir(e.mesaj, xeta: true);
    } finally {
      if (mounted) setState(() => _mesgul = false);
    }
  }

  Future<void> _gonder() async {
    final tesdiq = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('Hesabat göndərilsin?')),
        content: Text(t('Göndərildikdən sonra hesabatı dəyişmək olmaz.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t('Ləğv et')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t('Göndər')),
          ),
        ],
      ),
    );
    if (tesdiq != true || !mounted) return;

    setState(() => _mesgul = true);
    try {
      await HesabatServisi.saxla(_hesabat.id, _say, _hekimIdleri);
      final yeni = await HesabatServisi.gonder(_hesabat.id);
      if (!mounted) return;
      setState(() {
        _hesabat = yeni;
        _say = Map.of(yeni.say);
        _deyisib = false;
      });
      _bildir(t('Hesabat göndərildi'));
    } on ApiException catch (e) {
      _bildir(e.mesaj, xeta: true);
    } finally {
      if (mounted) setState(() => _mesgul = false);
    }
  }

  Widget _ustHisse() {
    final scheme = Theme.of(context).colorScheme;
    final (metn, ikon, reng) = switch (_hesabat.status) {
      'qaralama' => (t('Qaralama'), Icons.edit_note, scheme.outline),
      'gonderildi' => (t('Göndərilib'), Icons.send, scheme.primary),
      'geri_qaytarildi' => (
        t('Geri qaytarılıb'),
        Icons.reply,
        AppTheme.azQalib,
      ),
      'tesdiqlendi' => (t('Təsdiqlənib'), Icons.check_circle, AppTheme.ugur),
      _ => (_hesabat.status, Icons.info_outline, scheme.outline),
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ayAdi(_hesabat.ay),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Chip(
                avatar: Icon(ikon, size: 18, color: reng),
                label: Text(metn),
              ),
            ],
          ),
          if (_hesabat.status == 'geri_qaytarildi' &&
              (_hesabat.serh ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('${t('Menecerin şərhi')}: ${_hesabat.serh}'),
            ),
          ],
          if (!_hesabat.redakteOlunaBiler) ...[
            const SizedBox(height: 8),
            Text(t('Bu hesabat artıq dəyişdirilə bilməz.')),
          ],
        ],
      ),
    );
  }

  Widget _hekimKarti(Hekim h) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(h.ad, style: Theme.of(context).textTheme.titleMedium),
            if ((h.ixtisas ?? '').isNotEmpty)
              Text(h.ixtisas!, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            for (final d in _dermanlar)
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
                  Expanded(child: Text(d.ad)),
                  SayDuzenle(
                    key: ValueKey('${h.id}:${d.id}'),
                    deyer: _say[_acar(h.id, d.id)] ?? 0,
                    aktiv: _aktiv,
                    onChanged: (v) => setState(() {
                      _say[_acar(h.id, d.id)] = v;
                      _deyisib = true;
                    }),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _altDugmeler() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _aktiv && _deyisib ? _saxla : null,
                child: Text(t('Yadda saxla')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _aktiv ? _gonder : null,
                child: Text(t('Göndər')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final soz = _axtar.trim().toLowerCase();
    final gorunenler = _hekimler
        .where((h) => soz.isEmpty || h.ad.toLowerCase().contains(soz))
        .toList();

    final elementler = <Widget>[];
    int? cariKlinika;
    for (final h in gorunenler) {
      if (h.clinicId != cariKlinika) {
        cariKlinika = h.clinicId;
        elementler.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
            child: Text(
              h.clinicAd,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        );
      }
      elementler.add(_hekimKarti(h));
    }
    if (gorunenler.isEmpty) {
      elementler.add(
        Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text(t('Heç nə tapılmadı'))),
        ),
      );
    }

    return Column(
      children: [
        _ustHisse(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: t('Həkim axtar'),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _axtar = v),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: elementler,
          ),
        ),
        if (_hesabat.redakteOlunaBiler) _altDugmeler(),
      ],
    );
  }
}

/// "− rəqəm +" sahəsi. Rəqəmi düymələrlə və ya klaviaturadan dəyişmək olar.
class SayDuzenle extends StatefulWidget {
  final int deyer;
  final bool aktiv;
  final ValueChanged<int> onChanged;

  const SayDuzenle({
    super.key,
    required this.deyer,
    required this.aktiv,
    required this.onChanged,
  });

  @override
  State<SayDuzenle> createState() => _SayDuzenleState();
}

class _SayDuzenleState extends State<SayDuzenle> {
  late final TextEditingController _c = TextEditingController(
    text: '${widget.deyer}',
  );

  @override
  void didUpdateWidget(SayDuzenle kohne) {
    super.didUpdateWidget(kohne);
    final cari = int.tryParse(_c.text) ?? 0;
    if (cari != widget.deyer) _c.text = '${widget.deyer}';
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _deyis(int v) {
    final yeni = v.clamp(0, 999999);
    _c.text = '$yeni';
    widget.onChanged(yeni);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.outlined(
          onPressed: widget.aktiv && widget.deyer > 0
              ? () => _deyis(widget.deyer - 1)
              : null,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 60,
          child: TextField(
            controller: _c,
            enabled: widget.aktiv,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(),
            ),
            onChanged: (t) => widget.onChanged(int.tryParse(t) ?? 0),
          ),
        ),
        IconButton.outlined(
          onPressed: widget.aktiv ? () => _deyis(widget.deyer + 1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
