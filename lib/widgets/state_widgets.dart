import 'dart:async';

import 'package:flutter/material.dart';

/// Yüklənir: boz "skelet" kartları (bütün ekranı bağlayan spinner yox).
class YuklenirSkelet extends StatefulWidget {
  final int say;
  const YuklenirSkelet({super.key, this.say = 3});

  @override
  State<YuklenirSkelet> createState() => _YuklenirSkeletState();
}

class _YuklenirSkeletState extends State<YuklenirSkelet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reng = Theme.of(context).colorScheme.surfaceContainerHighest;
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1).animate(_c),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.say,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => Container(
          height: 96,
          decoration: BoxDecoration(
            color: reng,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

/// Server oyanır: Render pulsuz planında ilk sorğu uzun çəkə bilər.
class ServerOyanirZolagi extends StatelessWidget {
  const ServerOyanirZolagi({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: scheme.secondaryContainer,
      child: Row(
        children: [
          const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Server oyanır, bir az gözləyin…',
              style: TextStyle(color: scheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

/// Boşdur: ikon + izah + (istəyə görə) növbəti addım düyməsi.
class BosHal extends StatelessWidget {
  final IconData ikon;
  final String metn;
  final String? duymeAdi;
  final VoidCallback? duymeEmeliyyati;

  const BosHal({
    super.key,
    this.ikon = Icons.inbox_outlined,
    required this.metn,
    this.duymeAdi,
    this.duymeEmeliyyati,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, size: 56, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(metn,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
            if (duymeAdi != null && duymeEmeliyyati != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: duymeEmeliyyati, child: Text(duymeAdi!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Xəta: qısa izah + "Yenidən cəhd et". Texniki xəta mətni göstərilmir.
class XetaHali extends StatelessWidget {
  final String metn;
  final VoidCallback onYeniden;

  const XetaHali({
    super.key,
    this.metn = 'Məlumat yüklənmədi. Bir az sonra yenidən cəhd et.',
    required this.onYeniden,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 56, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(metn,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            FilledButton(
                onPressed: onYeniden, child: const Text('Yenidən cəhd et')),
          ],
        ),
      ),
    );
  }
}

/// Dörd halı (yüklənir, server oyanır, xəta, boşdur) bir yerdə idarə edir.
/// Hər ekranda eyni şəkildə istifadə olunacaq.
class AsyncGorunus<T> extends StatefulWidget {
  final Future<T> Function() yukle;
  final Widget Function(BuildContext context, T data) qur;
  final bool Function(T data)? bosdur;
  final String bosMetn;
  final IconData bosIkon;
  final String? bosDuymeAdi;
  final VoidCallback? bosDuymeEmeliyyati;

  /// Bu müddətdən uzun gözləyəndə "Server oyanır" zolağı göstərilir.
  final Duration serverOyanirGecikmesi;

  /// TT: gözləmə müddəti 90 saniyə.
  final Duration umumiLimit;

  const AsyncGorunus({
    super.key,
    required this.yukle,
    required this.qur,
    this.bosdur,
    this.bosMetn = 'Hələ qeyd yoxdur',
    this.bosIkon = Icons.inbox_outlined,
    this.bosDuymeAdi,
    this.bosDuymeEmeliyyati,
    this.serverOyanirGecikmesi = const Duration(seconds: 5),
    this.umumiLimit = const Duration(seconds: 90),
  });

  @override
  State<AsyncGorunus<T>> createState() => _AsyncGorunusState<T>();
}

class _AsyncGorunusState<T> extends State<AsyncGorunus<T>> {
  late Future<T> _future;
  Timer? _timer;
  bool _oyanir = false;

  @override
  void initState() {
    super.initState();
    _basla();
  }

  void _basla() {
    _timer?.cancel();
    _oyanir = false;
    _timer = Timer(widget.serverOyanirGecikmesi, () {
      if (mounted) setState(() => _oyanir = true);
    });
    _future = widget.yukle().timeout(widget.umumiLimit).whenComplete(() {
      _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Column(
            children: [
              if (_oyanir) const ServerOyanirZolagi(),
              const Expanded(child: YuklenirSkelet()),
            ],
          );
        }
        if (snapshot.hasError) {
          return XetaHali(onYeniden: () => setState(_basla));
        }
        final data = snapshot.data as T;
        if (widget.bosdur?.call(data) ?? false) {
          return BosHal(
            ikon: widget.bosIkon,
            metn: widget.bosMetn,
            duymeAdi: widget.bosDuymeAdi,
            duymeEmeliyyati: widget.bosDuymeEmeliyyati,
          );
        }
        return widget.qur(context, data);
      },
    );
  }
}