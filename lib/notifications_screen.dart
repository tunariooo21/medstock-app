import 'dart:async';

import 'package:flutter/material.dart';

import 'api_client.dart';
import 'l10n.dart';
import 'stock_request_screen.dart';
import 'stock_request_service.dart';
import 'theme/app_theme.dart';
import 'widgets/state_widgets.dart';

class BildirisDugmesi extends StatefulWidget {
  final bool menecer;
  const BildirisDugmesi({super.key, required this.menecer});

  @override
  State<BildirisDugmesi> createState() => _BildirisDugmesiState();
}

class _BildirisDugmesiState extends State<BildirisDugmesi>
    with WidgetsBindingObserver {
  Timer? _timer;
  int _say = 0;
  bool _yuklenir = false;
  bool _xeta = false;
  bool _aktiv = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    StokTalebServisi.deyisdi.addListener(_yenile);
    _yenile();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_aktiv) _yenile();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _aktiv = state == AppLifecycleState.resumed;
    if (_aktiv) _yenile();
  }

  Future<void> _yenile() async {
    if (_yuklenir) return;
    _yuklenir = true;
    try {
      final data = await StokTalebServisi.bildirisler();
      if (mounted) {
        setState(() {
          _say = data['unread'] as int;
          _xeta = false;
        });
      }
    } on ApiException {
      if (mounted) setState(() => _xeta = true);
    } finally {
      _yuklenir = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    StokTalebServisi.deyisdi.removeListener(_yenile);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: _xeta ? t('bildiris_yuklenmedi') : t('bildirisler'),
    onPressed: () async {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BildirislerEkrani(menecer: widget.menecer),
        ),
      );
      _yenile();
    },
    icon: Badge(
      isLabelVisible: _say > 0 || _xeta,
      label: Text(_xeta ? '!' : '$_say'),
      child: const Icon(Icons.notifications_outlined),
    ),
  );
}

class BildirislerEkrani extends StatefulWidget {
  final bool menecer;
  const BildirislerEkrani({super.key, required this.menecer});

  @override
  State<BildirislerEkrani> createState() => _BildirislerEkraniState();
}

class _BildirislerEkraniState extends State<BildirislerEkrani> {
  int _acar = 0;
  bool _acilir = false;

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

  Future<void> _ac(Map<String, dynamic> b) async {
    if (_acilir) return;
    _acilir = true;
    try {
      final h = await StokTalebServisi.detal(b['request_id'] as int);
      await StokTalebServisi.oxu(b['id'] as int);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StokTalebDetali(taleb: h, menecer: widget.menecer),
        ),
      );
      if (mounted) setState(() => _acar++);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.mesaj)));
      }
    } finally {
      _acilir = false;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(t('bildirisler'))),
    body: AsyncGorunus<Map<String, dynamic>>(
      key: ValueKey(_acar),
      yukle: StokTalebServisi.bildirisler,
      qur: (_, data) {
        final items = (data['items'] as List)
            .cast<Map<String, dynamic>>()
            .where((b) => b['read'] != true)
            .toList();
        return RefreshIndicator(
          onRefresh: () async => setState(() => _acar++),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    t('bildiris_yoxdur'),
                    textAlign: TextAlign.center,
                  ),
                ),
              for (final b in items)
                Card(
                  child: ListTile(
                    leading: Icon(
                      b['kind'] == 'submitted'
                          ? Icons.inventory_2_outlined
                          : b['kind'] == 'gozleyir'
                          ? Icons.schedule
                          : Icons.check_circle_outline,
                      color: b['kind'] == 'submitted'
                          ? AppTheme.bitib
                          : b['kind'] == 'gozleyir'
                          ? AppTheme.azQalib
                          : AppTheme.ugur,
                    ),
                    title: Text(
                      b['kind'] == 'submitted'
                          ? t('stok_telebi')
                          : talebStatusAdi(b['kind'] as String),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${b['user_ad']} · ${t('stok_telebi')} #${b['request_id']}\n${b['kind'] == 'submitted' ? t('stok_telebi_bildiris_metni') : talebStatusAdi(b['kind'] as String)}',
                    ),
                    trailing: Icon(
                      Icons.circle,
                      size: 10,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onTap: () => _ac(b),
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );
}
