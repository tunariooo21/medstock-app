import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n.dart';
import '../theme/app_theme.dart';

/// Yüklənir: parıldayan (shimmer) boz skelet kartları.
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
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baza = Theme.of(context).colorScheme.surfaceContainerHighest;
    final isiq = Color.alphaBlend(
      Colors.white.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.08 : 0.72,
      ),
      baza,
    );
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => ListView.separated(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.say,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => Container(
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baza, isiq, baza],
              stops: const [0.25, 0.5, 0.75],
              transform: _SursuyenGradient(_c.value),
            ),
          ),
        ),
      ),
    );
  }
}

class _SursuyenGradient extends GradientTransform {
  final double faiz;
  const _SursuyenGradient(this.faiz);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (faiz * 2 - 1), 0, 0);
}

/// Server oyanır: Render pulsuz planında ilk sorğu uzun çəkə bilər.
class ServerOyanirZolagi extends StatelessWidget {
  const ServerOyanirZolagi({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6E8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF3DFC0)),
        ),
        child: Row(
          children: [
            const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFB17724),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                t('Server oyanır, bir az gözləyin…'),
                style: const TextStyle(fontSize: 13, color: Color(0xFF8A5D17)),
              ),
            ),
          ],
        ),
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
    return _HalGorunusu(
      ikon: ikon,
      reng: AppTheme.esas(context),
      basliq: metn,
      duymeAdi: duymeAdi,
      duymeEmeliyyati: duymeEmeliyyati,
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
    return _HalGorunusu(
      ikon: Icons.wifi_off_rounded,
      reng: Theme.of(context).colorScheme.error,
      basliq: metn,
      duymeAdi: 'Yenidən cəhd et',
      duymeEmeliyyati: onYeniden,
    );
  }
}

class _HalGorunusu extends StatelessWidget {
  final IconData ikon;
  final Color reng;
  final String basliq;
  final String? duymeAdi;
  final VoidCallback? duymeEmeliyyati;

  const _HalGorunusu({
    required this.ikon,
    required this.reng,
    required this.basliq,
    this.duymeAdi,
    this.duymeEmeliyyati,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: reng.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(ikon, size: 42, color: reng),
            ),
            const SizedBox(height: 18),
            Text(
              t(basliq),
              textAlign: TextAlign.center,
              style: tema.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            if (duymeAdi != null && duymeEmeliyyati != null) ...[
              const SizedBox(height: 18),
              FilledButton(
                onPressed: duymeEmeliyyati,
                child: Text(t(duymeAdi!)),
              ),
            ],
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
