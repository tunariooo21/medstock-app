import 'package:flutter/material.dart';

import 'charts_screen.dart';
import 'prices_screen.dart';
import 'returns_screen.dart';

class MenecerHesabatlarEkrani extends StatelessWidget {
  const MenecerHesabatlarEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Qrafiklər'),
              Tab(text: 'Geri qaytarma'),
              Tab(text: 'Qiymətlər'),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                QrafiklerEkrani(menecer: true),
                GeriQaytarmalarEkrani(),
                QiymetlerEkrani(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}