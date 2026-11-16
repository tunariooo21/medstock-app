import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'api_client.dart';
import 'l10n.dart';
import 'stock_request_service.dart';
import 'theme/app_theme.dart';
import 'widgets/state_widgets.dart';

String talebStatusAdi(String status) => switch (status) {
  'qaralama' => t('taleb_qaralama'),
  'gonderildi' => t('taleb_gonderildi'),
  'gozleyir' => t('taleb_gozleyir'),
  'tesdiqlendi' => t('taleb_tesdiqlendi'),
  _ => status,
};

class TalebStatusu extends StatelessWidget {
  final String status;
  const TalebStatusu({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      'tesdiqlendi' => (Icons.check_circle_outline, AppTheme.ugur),
      'gozleyir' => (Icons.schedule, AppTheme.azQalib),
      'gonderildi' => (Icons.priority_high, AppTheme.bitib),
      _ => (Icons.edit_note, Theme.of(context).colorScheme.primary),
    };
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Icon(icon, size: 18, color: color),
        Text(
          talebStatusAdi(status),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

Future<void> stokTalebiAc(
  BuildContext context, {
  int? pointId,
  int? medicineId,
  StokTalebi? taleb,
}) => Navigator.of(context).push<void>(
  MaterialPageRoute(
    builder: (_) =>
        StokTalebFormu(pointId: pointId, medicineId: medicineId, taleb: taleb),
  ),
);

class StokTalebleriEkrani extends StatefulWidget {
  final bool menecer;
  final bool sehife;
  const StokTalebleriEkrani({
    super.key,
    this.menecer = false,
    this.sehife = true,
  });

  @override
  State<StokTalebleriEkrani> createState() => _StokTalebleriEkraniState();
}

class _StokTalebleriEkraniState extends State<StokTalebleriEkrani> {
  int _acar = 0;

  @override
  void initState() {
    super.initState();
    StokTalebServisi.deyisdi.addListener(_yenile);
  }

  void _yenile() {
    if (mounted) setState(() => _acar++);
  }

  @override
  void dispose() {
    StokTalebServisi.deyisdi.removeListener(_yenile);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = AsyncGorunus<List<StokTalebi>>(
      key: ValueKey(_acar),
      yukle: StokTalebServisi.siyahi,
      qur: (context, list) => RefreshIndicator(
        onRefresh: () async => _yenile(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (!widget.menecer) ...[
              FilledButton.icon(
                onPressed: () => stokTalebiAc(context),
                icon: const Icon(Icons.add),
                label: Text(t('yeni_stok_telebi')),
              ),
              const SizedBox(height: 16),
            ],
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  t('stok_telebi_yoxdur'),
                  textAlign: TextAlign.center,
                ),
              ),
            for (final h in list)
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Icon(
                    h.status == 'qaralama'
                        ? Icons.edit_note
                        : Icons.inventory_2_outlined,
                  ),
                  title: Text(
                    widget.menecer ? h.userAd : '${t('stok_telebi')} #${h.id}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      TalebStatusu(status: h.status),
                      const SizedBox(height: 4),
                      Text(
                        h.setirler
                            .map(
                              (s) =>
                                  '${s.medicineAd} · ${s.pointAd} · ${s.say}',
                            )
                            .join('\n'),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    if (h.status == 'qaralama' && !widget.menecer) {
                      stokTalebiAc(context, taleb: h);
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StokTalebDetali(
                            taleb: h,
                            menecer: widget.menecer,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
    return widget.sehife
        ? Scaffold(
            appBar: AppBar(title: Text(t('stok_telebleri'))),
            body: body,
          )
        : body;
  }
}

class StokTalebFormu extends StatelessWidget {
  final int? pointId;
  final int? medicineId;
  final StokTalebi? taleb;
  const StokTalebFormu({super.key, this.pointId, this.medicineId, this.taleb});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(t('stok_telebi'))),
    body: AsyncGorunus<Map<String, dynamic>>(
      yukle: StokTalebServisi.secimler,
      qur: (_, options) => _TalebForma(
        options: options,
        pointId: pointId,
        medicineId: medicineId,
        taleb: taleb,
      ),
    ),
  );
}

class _RedakteSetri {
  int pointId;
  final int medicineId;
  final String medicineAd;
  final int sira;
  final TextEditingController say;
  _RedakteSetri(
    this.pointId,
    this.medicineId,
    this.medicineAd,
    this.sira,
    String miqdar,
  ) : say = TextEditingController(text: miqdar);
}

class _TalebForma extends StatefulWidget {
  final Map<String, dynamic> options;
  final int? pointId;
  final int? medicineId;
  final StokTalebi? taleb;
  const _TalebForma({
    required this.options,
    this.pointId,
    this.medicineId,
    this.taleb,
  });

  @override
  State<_TalebForma> createState() => _TalebFormaState();
}

class _TalebFormaState extends State<_TalebForma> {
  final _form = GlobalKey<FormState>();
  final _setirler = <_RedakteSetri>[];
  int? _id;
  bool _mesgul = false;
  String? _xeta;
  late final List<Map<String, dynamic>> _apteker =
      (widget.options['pharmacies'] as List).cast<Map<String, dynamic>>();
  late final List<Map<String, dynamic>> _diqqet =
      (widget.options['items'] as List).cast<Map<String, dynamic>>();

  @override
  void initState() {
    super.initState();
    _id = widget.taleb?.id;
    for (final s in widget.taleb?.setirler ?? <TalebSetri>[]) {
      _setirler.add(
        _RedakteSetri(
          s.pointId,
          s.medicineId,
          s.medicineAd,
          s.sira,
          '${s.say}',
        ),
      );
    }
    if (widget.medicineId != null && _apteker.isNotEmpty) {
      final items = _diqqet.where((i) => i['medicine_id'] == widget.medicineId);
      if (items.isNotEmpty) _elave(items.first, ilkin: true);
    }
  }

  void _elave(Map<String, dynamic> item, {bool ilkin = false}) {
    if (_apteker.isEmpty) return;
    final source = ilkin ? widget.pointId : item['point_id'];
    final pid = _apteker.any((p) => p['id'] == source)
        ? source as int
        : _apteker.first['id'] as int;
    if (_setirler.any(
      (s) => s.pointId == pid && s.medicineId == item['medicine_id'],
    )) {
      if (!ilkin) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t('taleb_setri_movcuddur'))));
      }
      return;
    }
    if (_setirler.length >= 100) return;
    void add() => _setirler.add(
      _RedakteSetri(
        pid,
        item['medicine_id'] as int,
        item['medicine_ad'] as String,
        item['sira'] as int,
        '',
      ),
    );
    if (ilkin) {
      add();
    } else {
      setState(add);
    }
  }

  @override
  void dispose() {
    for (final s in _setirler) {
      s.say.dispose();
    }
    super.dispose();
  }

  Future<void> _saxla(bool gonder) async {
    if (_mesgul || !_form.currentState!.validate()) return;
    if (gonder && _setirler.isEmpty) {
      setState(() => _xeta = t('bos_stok_telebi'));
      return;
    }
    final cutler = _setirler.map((s) => '${s.pointId}-${s.medicineId}').toSet();
    if (cutler.length != _setirler.length) {
      setState(() => _xeta = t('taleb_setri_movcuddur'));
      return;
    }
    setState(() {
      _mesgul = true;
      _xeta = null;
    });
    try {
      final saved = await StokTalebServisi.saxla(_id, [
        for (final s in _setirler)
          {
            'point_id': s.pointId,
            'medicine_id': s.medicineId,
            'say': int.parse(s.say.text),
          },
      ]);
      _id = saved.id;
      if (gonder) await StokTalebServisi.gonder(saved.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            gonder ? t('stok_telebi_gonderildi') : t('stok_telebi_saxlandi'),
          ),
        ),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) setState(() => _xeta = e.mesaj);
    } finally {
      if (mounted) setState(() => _mesgul = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final manager = widget.options['manager_ad'] as String?;
    return Column(
      children: [
        Expanded(
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  manager == null
                      ? t('menecer_teyin_olunmayib')
                      : '${t('menecer')}: $manager',
                ),
                const SizedBox(height: 8),
                Text(
                  t('stok_telebi_izah'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (_apteker.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(t('aptek_teyin_olunmayib')),
                  ),
                const SizedBox(height: 12),
                for (final s in _setirler)
                  Card(
                    key: ObjectKey(s),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 12,
                                color: AppTheme.dermanRengi(s.sira),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  s.medicineAd,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ),
                              IconButton(
                                tooltip: t('taleb_setrini_sil'),
                                onPressed: _mesgul
                                    ? null
                                    : () {
                                        setState(() => _setirler.remove(s));
                                        s.say.dispose();
                                      },
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            key: ValueKey(
                              '${s.pointId}-${Localizations.localeOf(context)}',
                            ),
                            initialValue:
                                _apteker.any((p) => p['id'] == s.pointId)
                                ? s.pointId
                                : null,
                            isExpanded: true,
                            decoration: InputDecoration(labelText: t('aptek')),
                            items: [
                              for (final p in _apteker)
                                DropdownMenuItem(
                                  value: p['id'] as int,
                                  child: Text(
                                    '${p['ad']} · ${p['region_ad']}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            onChanged: _mesgul
                                ? null
                                : (v) {
                                    if (v != null) {
                                      setState(() => s.pointId = v);
                                    }
                                  },
                            validator: (v) =>
                                v == null ? t('aptek_secin') : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: s.say,
                            enabled: !_mesgul,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: t('lazim_olan_miqdar'),
                            ),
                            validator: (v) {
                              final n = int.tryParse(v ?? '');
                              return n == null || n <= 0 || n > 100000
                                  ? t('miqdar_1_100000')
                                  : null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                ExpansionTile(
                  title: Text(t('diqqet_teleb_eden')),
                  subtitle: Text('${_diqqet.length}'),
                  initiallyExpanded: _setirler.isEmpty,
                  children: [
                    if (_diqqet.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(t('diqqet_dermani_yoxdur')),
                      ),
                    for (final item in _diqqet)
                      ListTile(
                        leading: Icon(
                          item['status'] == 'sifir'
                              ? Icons.error_outline
                              : Icons.warning_amber_rounded,
                          color: item['status'] == 'sifir'
                              ? AppTheme.bitib
                              : AppTheme.azQalib,
                        ),
                        title: Text(item['medicine_ad'] as String),
                        subtitle: Text(
                          '${item['point_ad']} · ${item['region_ad']}\n${item['status'] == 'sifir' ? t('qaliq_yoxdur') : t('az_qalib')}: ${item['qaliq']}',
                        ),
                        trailing: TextButton(
                          onPressed: _mesgul || _apteker.isEmpty
                              ? null
                              : () => _elave(item),
                          child: Text(t('bildir')),
                        ),
                      ),
                  ],
                ),
                if (_xeta != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _xeta!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _mesgul ? null : () => _saxla(false),
                  icon: const Icon(Icons.save_outlined),
                  label: Text(t('yadda_saxla')),
                ),
                FilledButton.icon(
                  onPressed: _mesgul || manager == null
                      ? null
                      : () => _saxla(true),
                  icon: _mesgul
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(t('gonder')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class StokTalebDetali extends StatefulWidget {
  final StokTalebi taleb;
  final bool menecer;
  const StokTalebDetali({
    super.key,
    required this.taleb,
    required this.menecer,
  });

  @override
  State<StokTalebDetali> createState() => _StokTalebDetaliState();
}

class _StokTalebDetaliState extends State<StokTalebDetali> {
  late StokTalebi _taleb = widget.taleb;
  late final _serh = TextEditingController(text: _taleb.serh);
  bool _mesgul = false;
  String? _xeta;

  @override
  void dispose() {
    _serh.dispose();
    super.dispose();
  }

  Future<void> _qerar(String status) async {
    final razi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          status == 'tesdiqlendi' ? t('telebi_tesdiqle') : t('telebi_gozlet'),
        ),
        content: Text(
          status == 'tesdiqlendi'
              ? t('tesdiq_mal_daxilolmasi')
              : t('gozlet_stoku_deyismir'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t('legv_et')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('tesdiq')),
          ),
        ],
      ),
    );
    if (razi != true || !mounted) return;
    setState(() {
      _mesgul = true;
      _xeta = null;
    });
    try {
      final h = await StokTalebServisi.qerar(_taleb.id, status, _serh.text);
      if (mounted) setState(() => _taleb = h);
    } on ApiException catch (e) {
      if (mounted) setState(() => _xeta = e.mesaj);
    } finally {
      if (mounted) setState(() => _mesgul = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('${t('stok_telebi')} #${_taleb.id}')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(_taleb.userAd, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        TalebStatusu(status: _taleb.status),
        const SizedBox(height: 12),
        for (final s in _taleb.setirler)
          Card(
            child: ListTile(
              leading: Icon(
                Icons.circle,
                size: 12,
                color: AppTheme.dermanRengi(s.sira),
              ),
              title: Text(s.medicineAd),
              subtitle: Text(s.pointAd),
              trailing: Text('${s.say} ${t('eded')}'),
            ),
          ),
        if (_taleb.serh != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('${t('menecer_serhi')}: ${_taleb.serh}'),
          ),
        if (widget.menecer &&
            (_taleb.status == 'gonderildi' || _taleb.status == 'gozleyir')) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _serh,
            enabled: !_mesgul,
            maxLength: 500,
            maxLines: 3,
            decoration: InputDecoration(labelText: t('menecer_serhi')),
          ),
          Text(
            t('tesdiq_mal_daxilolmasi'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (_taleb.status == 'gonderildi')
                OutlinedButton.icon(
                  onPressed: _mesgul ? null : () => _qerar('gozleyir'),
                  icon: const Icon(Icons.schedule),
                  label: Text(t('telebi_gozlet')),
                ),
              FilledButton.icon(
                onPressed: _mesgul ? null : () => _qerar('tesdiqlendi'),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(t('telebi_tesdiqle')),
              ),
            ],
          ),
        ],
        if (_xeta != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _xeta!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    ),
  );
}
