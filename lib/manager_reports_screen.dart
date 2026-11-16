import 'l10n.dart' hide ayAdi;

import 'package:flutter/material.dart';

import 'charts_screen.dart';
import 'prices_screen.dart';
import 'returns_screen.dart';
import 'stock_request_screen.dart';

class MenecerHesabatlarEkrani extends StatelessWidget {
  final TabController controller;
  final int geriQaytarmaAcari;
  const MenecerHesabatlarEkrani({
    super.key,
    required this.controller,
    this.geriQaytarmaAcari = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: t('stok_telebi')),
            Tab(text: t('Qrafiklər')),
            Tab(text: t('Geri qaytarma')),
            Tab(text: t('Qiymətlər')),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: controller,
            children: [
              StokTalebleriEkrani(menecer: true, sehife: false),
              QrafiklerEkrani(menecer: true),
              GeriQaytarmalarEkrani(key: ValueKey(geriQaytarmaAcari)),
              QiymetlerEkrani(),
            ],
          ),
        ),
      ],
    );
  }
}
