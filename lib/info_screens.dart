import 'package:flutter/material.dart';

import 'l10n.dart';
import 'theme/app_theme.dart';

class ShertlerEkrani extends StatelessWidget {
  const ShertlerEkrani({super.key});

  static const _bolmeler = [
    (
      '1. Xidmətdən istifadə',
      'MedStock apteklərdə stok, satış, resept və hesabatların idarə edilməsi '
          'üçün nəzərdə tutulub. Tətbiqdən yalnız rəsmi iş fəaliyyəti çərçivəsində '
          'istifadə edilməlidir.',
    ),
    (
      '2. Hesab və təhlükəsizlik',
      'Hesabın giriş məlumatları şəxsidir və üçüncü şəxslərlə paylaşılmamalıdır. '
          'Şifrənin itirilməsi və ya şübhəli giriş halında dərhal şifrəni dəyişin '
          'və adminlə əlaqə saxlayın.',
    ),
    (
      '3. Məlumatların düzgünlüyü',
      'Daxil edilən stok, satış və resept məlumatlarının düzgünlüyünə istifadəçi '
          'cavabdehdir. Səhv qeydlər hesabat göstəricilərinə birbaşa təsir edir.',
    ),
    (
      '4. Şəxsi məlumatlar',
      'Ad, e-poçt və əlaqə nömrəsi yalnız hesabın idarə edilməsi və bildirişlər '
          'üçün istifadə olunur, üçüncü tərəflərə verilmir.',
    ),
    (
      '5. Məsuliyyətin məhdudlaşdırılması',
      'Xidmət fasilələri, internet bağlantısı problemləri və ya istifadəçi '
          'səhvləri nəticəsində yaranan itkilər üçün xidmət təminatçısı məsuliyyət '
          'daşımır.',
    ),
    (
      '6. Dəyişikliklər',
      'Bu şərtlər zərurət yarandıqda yenilənə bilər. Yeniliklər tətbiqin növbəti '
          'versiyasında qüvvəyə minir.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(t('sertler_qaydalar')),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          itemCount: _bolmeler.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, i) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t(_bolmeler[i].$1),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 6),
              Text(
                t(_bolmeler[i].$2),
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.55,
                  color: AppTheme.kicik(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FaqEkrani extends StatelessWidget {
  const FaqEkrani({super.key});

  static const _suallar = [
    (
      'Şifrəmi necə bərpa edə bilərəm?',
      'Giriş ekranında “Şifrəni unutmusunuz?” keçidinə toxunun, e-poçt ünvanınızı '
          'yazın və göndərilən 6 rəqəmli kodu daxil edərək yeni şifrə yaradın.',
    ),
    (
      'Qeydiyyatdan sonra region necə təyin olunur?',
      'Regionları admin təyin edir. Qeydiyyatdan keçdikdən sonra əlaqə saxlayın ki, '
          'sizə uyğun region və apteklər hesabınıza bağlansın.',
    ),
    (
      'Stok qalığı necə hesablanır?',
      'Qalıq daxilolma, satış və geri qaytarma qeydlərindən avtomatik hesablanır. '
          'Hər hərəkət stok ekranında ayrıca qeyd kimi saxlanılır.',
    ),
    (
      'Aylıq hesabatı necə göndərirəm?',
      'Hesabat bölməsində ayı seçib sətirləri doldurun və “Göndər” düyməsinə '
          'toxunun. Menecer hesabatı təsdiqlədikdən sonra status yenilənir.',
    ),
    (
      'Məlumatlarım internet olmadan görünür?',
      'Xeyr. Stok, satış və hesabat məlumatları serverdə saxlanılır, ona görə '
          'internet bağlantısı tələb olunur.',
    ),
    (
      'Problem yaranarsa kimə müraciət edim?',
      'Əvvəlcə tətbiqi bağlayıb yenidən açın. Problem davam edərsə, sistem '
          'admininə müraciət edin və ekranda görünən xəta mesajını bildirin.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(t('tez_tez_suallar')),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          itemCount: _suallar.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ExpansionTile(
                tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                shape: Border(),
                collapsedShape: Border(),
                iconColor: AppTheme.esas(context),
                collapsedIconColor: AppTheme.kicik(context),
                title: Text(
                  t(_suallar[i].$1),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      t(_suallar[i].$2),
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppTheme.kicik(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
