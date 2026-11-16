import 'app_state.dart';

/// İstifadəçiyə görstərilən mətni aktiv dildə qaytarır.
/// t('ana_sehife') kimi çağırılır; açar tapılmazsa özü qayıdır.
String t(String achar) => L10n.deyer(achar);

/// '2026-11' → aktiv dildə 'noyabr 2026' kimi.
String ayAdi(String isoAy) => L10n.ayAdi(isoAy);

class L10n {
  static const Map<String, Map<String, String>> _c = {
    'menecer': {'az': 'Menecer', 'en': 'Manager', 'ru': 'Менеджер'},
    'gonder': {'az': 'Göndər', 'en': 'Send', 'ru': 'Отправить'},
    'menecer_serhi': {
      'az': 'Menecerin şərhi',
      'en': 'Manager comment',
      'ru': 'Комментарий менеджера',
    },
    'bildirisler': {
      'az': 'Bildirişlər',
      'en': 'Notifications',
      'ru': 'Уведомления',
    },
    'bildiris_yoxdur': {
      'az': 'Hələ bildiriş yoxdur',
      'en': 'No notifications yet',
      'ru': 'Пока нет уведомлений',
    },
    'bildiris_yuklenmedi': {
      'az': 'Bildirişlər yüklənmədi — yenidən yoxlayın',
      'en': 'Notifications unavailable — retry',
      'ru': 'Не удалось загрузить уведомления — повторите',
    },
    'menecer_elaqe_numune': {
      'az': 'E-poçt və telefon nümunədir.',
      'en': 'Email and phone are examples.',
      'ru': 'Почта и телефон указаны для примера.',
    },
    'stok_telebi': {
      'az': 'Stok tələbi',
      'en': 'Stock request',
      'ru': 'Заявка на пополнение',
    },
    'stok_telebleri': {
      'az': 'Stok tələbləri',
      'en': 'Stock requests',
      'ru': 'Заявки на пополнение',
    },
    'yeni_stok_telebi': {
      'az': 'Yeni stok tələbi',
      'en': 'New stock request',
      'ru': 'Новая заявка',
    },
    'stok_telebi_yoxdur': {
      'az': 'Hələ stok tələbi yoxdur',
      'en': 'No stock requests yet',
      'ru': 'Пока нет заявок',
    },
    'bildir': {'az': 'Bildir', 'en': 'Request', 'ru': 'Запросить'},
    'taleb_qaralama': {'az': 'Qaralama', 'en': 'Draft', 'ru': 'Черновик'},
    'taleb_gonderildi': {
      'az': 'Göndərildi',
      'en': 'Submitted',
      'ru': 'Отправлено',
    },
    'taleb_gozleyir': {'az': 'Gözləyir', 'en': 'On hold', 'ru': 'Ожидает'},
    'taleb_tesdiqlendi': {
      'az': 'Təsdiqləndi',
      'en': 'Approved',
      'ru': 'Одобрено',
    },
    'taleb_setri_movcuddur': {
      'az': 'Eyni aptek və dərman artıq əlavə olunub',
      'en': 'This pharmacy and medicine are already included',
      'ru': 'Эта аптека и препарат уже добавлены',
    },
    'taleb_setrini_sil': {
      'az': 'Sətri sil',
      'en': 'Remove row',
      'ru': 'Удалить строку',
    },
    'lazim_olan_miqdar': {
      'az': 'Lazım olan miqdar',
      'en': 'Quantity needed',
      'ru': 'Необходимое количество',
    },
    'miqdar_1_100000': {
      'az': 'Miqdar 1–100000 arası tam ədəd olmalıdır',
      'en': 'Enter a whole quantity from 1 to 100000',
      'ru': 'Введите целое количество от 1 до 100000',
    },
    'aptek_secin': {
      'az': 'Aptek seçin',
      'en': 'Choose a pharmacy',
      'ru': 'Выберите аптеку',
    },
    'aptek_teyin_olunmayib': {
      'az': 'Aktiv aptek təyin olunmayıb',
      'en': 'No active pharmacy assigned',
      'ru': 'Нет назначенной активной аптеки',
    },
    'menecer_teyin_olunmayib': {
      'az': 'Aktiv menecer təyin olunmayıb',
      'en': 'No active manager assigned',
      'ru': 'Нет назначенного активного менеджера',
    },
    'diqqet_dermani_yoxdur': {
      'az': 'Diqqət tələb edən dərman yoxdur',
      'en': 'No medicines need attention',
      'ru': 'Нет препаратов, требующих внимания',
    },
    'bos_stok_telebi': {
      'az': 'Göndərmək üçün dərman və miqdar əlavə edin',
      'en': 'Add a medicine and quantity before submitting',
      'ru': 'Добавьте препарат и количество перед отправкой',
    },
    'stok_telebi_saxlandi': {
      'az': 'Qaralama yadda saxlandı',
      'en': 'Draft saved',
      'ru': 'Черновик сохранён',
    },
    'stok_telebi_gonderildi': {
      'az': 'Stok tələbi menecerə göndərildi',
      'en': 'Stock request sent to the manager',
      'ru': 'Заявка отправлена менеджеру',
    },
    'stok_telebi_izah': {
      'az': 'Azalan və ya bitən dərmanı seçin, lazım olan apteki və miqdarı yazın. Qaralama menecerə görünmür.',
      'en': 'Choose a low or depleted medicine, its destination pharmacy and quantity. Drafts are private.',
      'ru': 'Выберите препарат с низким или нулевым остатком, аптеку и количество. Черновики видны только вам.',
    },
    'stok_telebi_bildiris_metni': {
      'az':
          'Nümayəndə azalan məhsulun seçilmiş aptekə əlavə olunmasını istəyir.',
      'en': 'Your representative requests low-stock medicines for selected pharmacies.',
      'ru': 'Представитель запрашивает препараты с низким остатком для выбранных аптек.',
    },
    'telebi_tesdiqle': {'az': 'Təsdiqlə', 'en': 'Approve', 'ru': 'Одобрить'},
    'telebi_gozlet': {'az': 'Gözlət', 'en': 'Put on hold', 'ru': 'Отложить'},
    'tesdiq_mal_daxilolmasi': {
      'az': 'Təsdiqlədikdə tələb olunan dərmanlar göstərilən miqdarda seçilmiş apteklərə mal daxilolması kimi yazılacaq və stok artacaq.',
      'en': 'Approval records incoming stock for the requested medicines and quantities at the selected pharmacies, increasing their stock.',
      'ru': 'При одобрении поступление указанных препаратов и количеств будет записано для выбранных аптек, увеличив их остатки.',
    },
    'gozlet_stoku_deyismir': {
      'az': 'Tələb gözləməyə alınacaq. Stok dəyişməyəcək.',
      'en': 'The request will be put on hold. Stock will not change.',
      'ru': 'Заявка будет отложена. Остатки не изменятся.',
    },
    'profil_sekli': {
      'az': 'Profil şəkli',
      'en': 'Profile photo',
      'ru': 'Фото профиля',
    },
    'sekli_sil': {
      'az': 'Şəkli sil',
      'en': 'Remove photo',
      'ru': 'Удалить фото',
    },
    'sekil_olcusu': {
      'az': 'PNG/JPEG şəkli seçin; ölçüsü 2 MB-dan çox olmamalıdır',
      'en': 'Choose a PNG/JPEG photo up to 2 MB',
      'ru': 'Выберите фото PNG/JPEG размером до 2 МБ',
    },
    'sekil_yuklenmedi': {
      'az': 'Şəkil yüklənmədi. Yenidən yoxlayın.',
      'en': 'Photo upload failed. Please retry.',
      'ru': 'Не удалось загрузить фото. Повторите попытку.',
    },
    'Şəkil PNG/JPEG olmalı, 2 MB və 4096 pikseli keçməməlidir': {
      'az': 'Şəkil PNG/JPEG olmalı, 2 MB və 4096 pikseli keçməməlidir',
      'en': 'Photo must be PNG/JPEG, at most 2 MB and 4096 pixels',
      'ru': 'Фото должно быть PNG/JPEG, не более 2 МБ и 4096 пикселей',
    },
    'Stok tələbi tapılmadı': {
      'az': 'Stok tələbi tapılmadı',
      'en': 'Stock request not found',
      'ru': 'Заявка не найдена',
    },
    'Bu stok tələbi üçün icazən yoxdur': {
      'az': 'Bu stok tələbi üçün icazən yoxdur',
      'en': 'You cannot access this stock request',
      'ru': 'Нет доступа к этой заявке',
    },
    'Eyni aptek və dərman təkrarlanır': {
      'az': 'Eyni aptek və dərman təkrarlanır',
      'en': 'Duplicate pharmacy and medicine',
      'ru': 'Аптека и препарат повторяются',
    },
    'Stok tələbi üçün aptek seçin': {
      'az': 'Stok tələbi üçün aptek seçin',
      'en': 'Choose a pharmacy for this request',
      'ru': 'Выберите аптеку для заявки',
    },
    'Bu dərman artıq diqqət tələb etmir': {
      'az': 'Bu dərman artıq diqqət tələb etmir',
      'en': 'This medicine no longer needs attention',
      'ru': 'Этот препарат больше не требует внимания',
    },
    'Göndərilmiş stok tələbi dəyişdirilə bilməz': {
      'az': 'Göndərilmiş stok tələbi dəyişdirilə bilməz',
      'en': 'A submitted request cannot be edited',
      'ru': 'Отправленную заявку нельзя изменить',
    },
    'Stok tələbi artıq göndərilib': {
      'az': 'Stok tələbi artıq göndərilib',
      'en': 'Stock request already submitted',
      'ru': 'Заявка уже отправлена',
    },
    'Aktiv menecer təyin olunmayıb': {
      'az': 'Aktiv menecer təyin olunmayıb',
      'en': 'No active manager assigned',
      'ru': 'Нет назначенного активного менеджера',
    },
    'Boş stok tələbi göndərilə bilməz': {
      'az': 'Boş stok tələbi göndərilə bilməz',
      'en': 'Cannot submit an empty request',
      'ru': 'Нельзя отправить пустую заявку',
    },
    'Bu stok tələbi üçün qərar artıq verilib': {
      'az': 'Bu stok tələbi üçün qərar artıq verilib',
      'en': 'This decision has already been made',
      'ru': 'Решение по заявке уже принято',
    },
    'Bildiriş tapılmadı': {
      'az': 'Bildiriş tapılmadı',
      'en': 'Notification not found',
      'ru': 'Уведомление не найдено',
    },

    // Ümumi
    'legv_et': {'az': 'Ləğv et', 'en': 'Cancel', 'ru': 'Отмена'},
    'qeyd_yenilendi': {
      'az': 'Qeyd yeniləndi',
      'en': 'Record updated',
      'ru': 'Запись обновлена',
    },
    'tesdiq': {'az': 'Təsdiq', 'en': 'Confirm', 'ru': 'Подтвердить'},
    'davam': {'az': 'Davam et', 'en': 'Continue', 'ru': 'Продолжить'},
    'yadda_saxla': {'az': 'Yadda saxla', 'en': 'Save', 'ru': 'Сохранить'},
    'bagla': {'az': 'Bağla', 'en': 'Close', 'ru': 'Закрыть'},
    'xeta_baslik': {'az': 'Xəta', 'en': 'Error', 'ru': 'Ошибка'},

    // Parametrlər
    'parametrler': {'az': 'Parametrlər', 'en': 'Settings', 'ru': 'Настройки'},
    'sexsi_parametrler': {
      'az': 'Şəxsi parametrlər',
      'en': 'Personal settings',
      'ru': 'Личные настройки',
    },
    'umumi_parametrler': {
      'az': 'Ümumi parametrlər',
      'en': 'General settings',
      'ru': 'Общие настройки',
    },
    'dil': {'az': 'Dil', 'en': 'Language', 'ru': 'Язык'},
    'qaranliq_rejim': {
      'az': 'Qaranlıq rejim',
      'en': 'Dark mode',
      'ru': 'Тёмная тема',
    },
    'tehlukesizlik': {
      'az': 'Təhlükəsizlik',
      'en': 'Security',
      'ru': 'Безопасность',
    },
    'sertler_qaydalar': {
      'az': 'Şərtlər və qaydalar',
      'en': 'Terms & conditions',
      'ru': 'Условия и правила',
    },
    'tez_tez_suallar': {
      'az': 'Tez-tez verilən suallar',
      'en': 'FAQ',
      'ru': 'Частые вопросы',
    },
    'cixis_et': {'az': 'Çıxış et', 'en': 'Log out', 'ru': 'Выйти'},
    'cixis_suali': {
      'az': 'Çıxış edilsin?',
      'en': 'Log out?',
      'ru': 'Выйти из аккаунта?',
    },
    'cixis_izah': {
      'az': 'Hesabdan çıxacaqsınız. Yenidən giriş üçün e-poçt və şifrə lazım olacaq.',
      'en': 'You will be logged out. Email and password will be required to sign back in.',
      'ru': 'Вы выйдете из аккаунта. Для повторного входа потребуются почта и пароль.',
    },
    'cixis': {'az': 'Çıxış', 'en': 'Log out', 'ru': 'Выйти'},
    'dil_seçimi_izah': {
      'az': 'Sizə uyğun dili seçin.',
      'en': 'Choose your preferred language.',
      'ru': 'Выберите подходящий язык.',
    },
    'az_dil': {
      'az': 'Azərbaycan',
      'en': 'Azerbaijani',
      'ru': 'Азербайджанский',
    },
    'en_dil': {'az': 'İngilis', 'en': 'English', 'ru': 'Английский'},
    'ru_dil': {'az': 'Rus', 'en': 'Russian', 'ru': 'Русский'},

    // Statuslar
    'az_qalib': {'az': 'Az qalıb', 'en': 'Low stock', 'ru': 'Мало осталось'},
    'qaliq_yoxdur': {
      'az': 'Qalıq yoxdur',
      'en': 'Out of stock',
      'ru': 'Нет остатка',
    },
    'sifir': {'az': 'Sıfır', 'en': 'Zero', 'ru': 'Ноль'},
    'az_': {'az': 'Az', 'en': 'Low', 'ru': 'Мало'},
    'ugur': {'az': 'Uğurlu', 'en': 'Success', 'ru': 'Успешно'},
    'tesdiqlenib': {
      'az': 'Təsdiqlənib',
      'en': 'Approved',
      'ru': 'Подтверждено',
    },
    'gözləyir': {'az': 'Gözləyir', 'en': 'Pending', 'ru': 'Ожидает'},
    'satis': {'az': 'Satış', 'en': 'Sale', 'ru': 'Продажа'},
    'geri_qaytarma': {'az': 'Geri qaytarma', 'en': 'Return', 'ru': 'Возврат'},
    'daxilolma': {'az': 'Daxilolma', 'en': 'Stock in', 'ru': 'Поступление'},
    'resept': {'az': 'Resept', 'en': 'Prescription', 'ru': 'Рецепт'},
    'aptek': {'az': 'Aptek', 'en': 'Pharmacy', 'ru': 'Аптека'},
    'depo': {'az': 'Depo', 'en': 'Warehouse', 'ru': 'Склад'},
    'eded': {'az': 'ədəd', 'en': 'pcs', 'ru': 'шт'},

    // Ana səhifə
    'region_teyin_edilmeyib': {
      'az': 'Sənə region təyin olunmayıb. Adminlə əlaqə saxla.',
      'en': 'No region assigned to you. Contact admin.',
      'ru': 'Вам не назначен регион. Обратитесь к администратору.',
    },
    'salam': {'az': 'Salam', 'en': 'Hello', 'ru': 'Здравствуйте'},
    'diqqet_teleb_eden': {
      'az': 'Diqqət tələb edən',
      'en': 'Attention needed',
      'ru': 'Требует внимания',
    },
    've_daha': {
      'az': 'və daha {n} qeyd',
      'en': 'and {n} more records',
      'ru': 'и ещё {n} записей',
    },
    'stok_bolmesine_kech': {
      'az': 'Stok bölməsinə keç',
      'en': 'Go to stock',
      'ru': 'Перейти к остаткам',
    },
    'derman_uzre': {
      'az': 'Dərman üzrə',
      'en': 'By medicine',
      'ru': 'По препаратам',
    },
    'regionlar_uzre_satish': {
      'az': 'Regionlar üzrə satış',
      'en': 'Sales by region',
      'ru': 'Продажи по регионам',
    },
    'son_qeydler': {
      'az': 'Son qeydlər',
      'en': 'Recent records',
      'ru': 'Последние записи',
    },
    'hele_qeyd_yoxdur': {
      'az': 'Hələ qeyd yoxdur. Stok bölməsindən qeyd əlavə et.',
      'en': 'No records yet. Add one from the stock section.',
      'ru': 'Записей пока нет. Добавьте из раздела остатков.',
    },
    'satilib': {'az': 'Satılıb', 'en': 'Sold', 'ru': 'Продано'},
    'qaliq': {'az': 'Qalıq', 'en': 'Stock', 'ru': 'Остаток'},

    // Naviqasiya
    'ana_sehife': {'az': 'Ana səhifə', 'en': 'Home', 'ru': 'Главная'},
    'stok': {'az': 'Stok', 'en': 'Stock', 'ru': 'Остатки'},
    'hesabat': {'az': 'Hesabat', 'en': 'Report', 'ru': 'Отчёт'},
    'isciler': {'az': 'İşçilər', 'en': 'Workers', 'ru': 'Сотрудники'},
    'hesabatlar': {'az': 'Hesabatlar', 'en': 'Reports', 'ru': 'Отчёты'},
    'profil': {'az': 'Profil', 'en': 'Profile', 'ru': 'Профиль'},

    // Stok ekranı
    'region_derman_teyin_edilmeyib': {
      'az': 'Sənə region və ya dərman təyin olunmayıb. Admindən xahiş et.',
      'en': 'No region or medicine assigned to you. Ask your admin.',
      'ru':
          'Вам не назначены регион или препараты. Обратитесь к администратору.',
    },
    'qeyd_elave_et': {
      'az': 'Qeyd əlavə et',
      'en': 'Add record',
      'ru': 'Добавить запись',
    },
    'region': {'az': 'Region', 'en': 'Region', 'ru': 'Регион'},
    'ay': {'az': 'Ay', 'en': 'Month', 'ru': 'Месяц'},
    'derman': {'az': 'Dərman', 'en': 'Medicine', 'ru': 'Препарат'},
    'butun_dermanlar': {
      'az': 'Bütün dərmanlar',
      'en': 'All medicines',
      'ru': 'Все препараты',
    },
    'aktiv_noqte_yoxdur': {
      'az': 'Bu regionda aktiv aptek və ya depo yoxdur',
      'en': 'No active pharmacy or warehouse in this region',
      'ru': 'В этом регионе нет активных аптек или складов',
    },
    'bu_gune': {'az': 'bu günə', 'en': 'as of today', 'ru': 'на сегодня'},
    'ayin_sonuna': {
      'az': 'ayın sonuna',
      'en': 'as of month end',
      'ru': 'на конец месяца',
    },
    'qaliq_izah': {
      'az': 'Qalıq: {qaliq} aptek və ya depoda olan say.\nSatılıb və Resept: {ay} ərzində.',
      'en': 'Stock: quantity at the pharmacy or warehouse {qaliq}.\nSold and Prescription: during {ay}.',
      'ru': 'Остаток: количество в аптеке или на складе {qaliq}.\nПродано и Рецепт: за {ay}.',
    },
    'region_cemi': {
      'az': 'Region cəmi · {ay}',
      'en': 'Region total · {ay}',
      'ru': 'Итог по региону · {ay}',
    },
    'qeyd_tarixcesi': {
      'az': 'Qeyd tarixçəsi',
      'en': 'Record history',
      'ru': 'История записей',
    },

    // Qeyd forması
    'aptek_depo_sec': {
      'az': 'Aptek və ya depo seç',
      'en': 'Choose a pharmacy or warehouse',
      'ru': 'Выберите аптеку или склад',
    },
    'derman_sec': {
      'az': 'Dərman seç',
      'en': 'Choose a medicine',
      'ru': 'Выберите препарат',
    },
    'say_boyuk_olmalidir': {
      'az': 'Say 0-dan böyük olmalıdır',
      'en': 'Quantity must be greater than 0',
      'ru': 'Количество должно быть больше 0',
    },
    'hekim_sec': {
      'az': 'Həkim seç',
      'en': 'Choose a doctor',
      'ru': 'Выберите врача',
    },
    'qeyd_yazilsin': {
      'az': 'Qeyd yazılsın?',
      'en': 'Save this record?',
      'ru': 'Сохранить запись?',
    },
    'qaliq_menfi_xeberdarliq': {
      'az': 'Diqqət: qalıq {qaliq}, satış {say}. Qalıq mənfi olacaq.',
      'en': 'Note: stock is {qaliq}, sale is {say}. Stock will go negative.',
      'ru': 'Внимание: остаток {qaliq}, продажа {say}. Остаток станет отрицательным.',
    },
    'qeyd_deyisdirilmir': {
      'az': 'Qeydə tarixçədən düzəliş etmək olar. Dəyişikliklər auditdə saxlanılır.',
      'en': 'You can edit the record in History. Changes are saved in the audit log.',
      'ru': 'Запись можно исправить в истории. Изменения сохраняются в журнале аудита.',
    },
    'yaz': {'az': 'Yaz', 'en': 'Save', 'ru': 'Записать'},
    'resept_yazildi': {
      'az': 'Resept yazıldı',
      'en': 'Prescription saved',
      'ru': 'Рецепт записан',
    },
    'qeyd_yazildi_yeni_qaliq': {
      'az': '{nov} yazıldı. Yeni qalıq: {qaliq}',
      'en': '{nov} saved. New stock: {qaliq}',
      'ru': '{nov} записано. Новый остаток: {qaliq}',
    },
    'aptek_depo': {
      'az': 'Aptek / depo',
      'en': 'Pharmacy / warehouse',
      'ru': 'Аптека / склад',
    },
    'resept_sayi': {
      'az': 'Resept sayı',
      'en': 'Prescription count',
      'ru': 'Количество рецептов',
    },
    'say': {'az': 'Say', 'en': 'Quantity', 'ru': 'Количество'},
    'tarix': {'az': 'Tarix', 'en': 'Date', 'ru': 'Дата'},
    'hekimler_yuklenmedi': {
      'az': 'Həkim siyahısı yüklənmədi',
      'en': 'Could not load doctors',
      'ru': 'Не удалось загрузить врачей',
    },
    'hekim': {'az': 'Həkim', 'en': 'Doctor', 'ru': 'Врач'},
    'sebeb_isteye_gore': {
      'az': 'Səbəb (istəyə görə)',
      'en': 'Reason (optional)',
      'ru': 'Причина (по желанию)',
    },
  };

  static const _aylar = [
    {'az': 'yanvar', 'en': 'January', 'ru': 'январь'},
    {'az': 'fevral', 'en': 'February', 'ru': 'февраль'},
    {'az': 'mart', 'en': 'March', 'ru': 'март'},
    {'az': 'aprel', 'en': 'April', 'ru': 'апрель'},
    {'az': 'may', 'en': 'May', 'ru': 'май'},
    {'az': 'iyun', 'en': 'June', 'ru': 'июнь'},
    {'az': 'iyul', 'en': 'July', 'ru': 'июль'},
    {'az': 'avqust', 'en': 'August', 'ru': 'август'},
    {'az': 'sentyabr', 'en': 'September', 'ru': 'сентябрь'},
    {'az': 'oktyabr', 'en': 'October', 'ru': 'октябрь'},
    {'az': 'noyabr', 'en': 'November', 'ru': 'ноябрь'},
    {'az': 'dekabr', 'en': 'December', 'ru': 'декабрь'},
  ];

  /// '2026-11' → aktiv dildə 'noyabr 2026' kimi.
  static String ayAdi(String isoAy) {
    final dil = AppState.instance.dil.name;
    try {
      final il = int.parse(isoAy.substring(0, 4));
      final ay = int.parse(isoAy.substring(5, 7));
      if (ay < 1 || ay > 12) return isoAy;
      return '${_aylar[ay - 1][dil] ?? _aylar[ay - 1]['az']} $il';
    } catch (_) {
      return isoAy;
    }
  }

  static const _qisaAylar = {
    'az': [
      'Yan',
      'Fev',
      'Mar',
      'Apr',
      'May',
      'İyn',
      'İyl',
      'Avq',
      'Sen',
      'Okt',
      'Noy',
      'Dek',
    ],
    'en': [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ],
    'ru': [
      'Янв',
      'Фев',
      'Мар',
      'Апр',
      'Май',
      'Июн',
      'Июл',
      'Авг',
      'Сен',
      'Окт',
      'Ноя',
      'Дек',
    ],
  };

  static String qisaAyAdi(String isoAy) {
    final ay = int.tryParse(isoAy.split('-').last);
    if (ay == null || ay < 1 || ay > 12) return isoAy;
    return _qisaAylar[AppState.instance.dil.name]![ay - 1];
  }

  static final _azAcarlar = {
    for (final entry in _c.entries) entry.value['az']!: entry.value,
  };

  static const _metnler = <String, Map<String, String>>{
    'Bu istifadəçi adı artıq mövcuddur': {
      'en': 'This username is already taken',
      'ru': 'Это имя пользователя уже занято',
    },
    'Bu e-poçt ilə hesab artıq mövcuddur': {
      'en': 'An account with this email already exists',
      'ru': 'Аккаунт с этой почтой уже существует',
    },
    'İstifadəçi adı 3–32 simvol olmalı və boşluq içerməməlidir': {
      'en': 'Username must contain 3–32 characters without spaces',
      'ru': 'Имя пользователя должно содержать 3–32 символа без пробелов',
    },
    'Bu əməliyyat üçün icazən yoxdur': {
      'en': 'You do not have permission for this action',
      'ru': 'У вас нет прав на это действие',
    },
    'E-poçt göndərilmədi. Bir az sonra yenidən cəhd edin': {
      'en': 'Email could not be sent. Please try again later',
      'ru': 'Не удалось отправить письмо. Повторите позже',
    },
    'Kodun vaxtı bitib': {
      'en': 'The code has expired',
      'ru': 'Срок действия кода истёк',
    },
    'Kod yanlışdır': {'en': 'Incorrect code', 'ru': 'Неверный код'},
    'Kodun vaxtı bitib. Yenidən kod istəyin': {
      'en': 'The code has expired. Request a new code',
      'ru': 'Срок действия кода истёк. Запросите новый код',
    },
    'Hesab tapılmadı': {'en': 'Account not found', 'ru': 'Аккаунт не найден'},
    'Hesab tapılmadı və ya deaktivdir': {
      'en': 'Account not found or inactive',
      'ru': 'Аккаунт не найден или неактивен',
    },

    '1. Xidmətdən istifadə': {
      'en': '1. Use of the service',
      'ru': '1. Использование сервиса',
    },
    'MedStock apteklərdə stok, satış, resept və hesabatların idarə edilməsi üçün nəzərdə tutulub. Tətbiqdən yalnız rəsmi iş fəaliyyəti çərçivəsində istifadə edilməlidir.':
        {
          'en': 'MedStock manages pharmacy stock, sales, prescriptions and reports. Use the app only for official work activities.',
          'ru': 'MedStock предназначен для управления остатками, продажами, рецептами и отчётами аптек. Используйте приложение только для служебной работы.',
        },
    '2. Hesab və təhlükəsizlik': {
      'en': '2. Account and security',
      'ru': '2. Аккаунт и безопасность',
    },
    'Hesabın giriş məlumatları şəxsidir və üçüncü şəxslərlə paylaşılmamalıdır. Şifrənin itirilməsi və ya şübhəli giriş halında dərhal şifrəni dəyişin və adminlə əlaqə saxlayın.':
        {
          'en': 'Account credentials are private and must not be shared. If your password is lost or you notice suspicious access, change it immediately and contact your admin.',
          'ru': 'Данные входа являются личными и не должны передаваться третьим лицам. При потере пароля или подозрительном входе сразу измените пароль и свяжитесь с администратором.',
        },
    '3. Məlumatların düzgünlüyü': {
      'en': '3. Data accuracy',
      'ru': '3. Достоверность данных',
    },
    'Daxil edilən stok, satış və resept məlumatlarının düzgünlüyünə istifadəçi cavabdehdir. Səhv qeydlər hesabat göstəricilərinə birbaşa təsir edir.':
        {
          'en': 'Users are responsible for the accuracy of stock, sales and prescription entries. Incorrect records directly affect report figures.',
          'ru': 'Пользователь отвечает за достоверность введённых данных об остатках, продажах и рецептах. Ошибочные записи напрямую влияют на показатели отчётов.',
        },
    '4. Şəxsi məlumatlar': {
      'en': '4. Personal data',
      'ru': '4. Персональные данные',
    },
    'Ad, e-poçt və əlaqə nömrəsi yalnız hesabın idarə edilməsi və bildirişlər üçün istifadə olunur, üçüncü tərəflərə verilmir.':
        {
          'en': 'Your name, email and phone number are used only for account management and notifications and are not shared with third parties.',
          'ru': 'Имя, почта и телефон используются только для управления аккаунтом и уведомлений и не передаются третьим лицам.',
        },
    '5. Məsuliyyətin məhdudlaşdırılması': {
      'en': '5. Limitation of liability',
      'ru': '5. Ограничение ответственности',
    },
    'Xidmət fasilələri, internet bağlantısı problemləri və ya istifadəçi səhvləri nəticəsində yaranan itkilər üçün xidmət təminatçısı məsuliyyət daşımır.':
        {
          'en': 'The service provider is not responsible for losses caused by service interruptions, internet connection problems or user errors.',
          'ru': 'Поставщик сервиса не отвечает за потери из-за перебоев в работе, проблем с интернетом или ошибок пользователей.',
        },
    '6. Dəyişikliklər': {'en': '6. Changes', 'ru': '6. Изменения'},
    'Bu şərtlər zərurət yarandıqda yenilənə bilər. Yeniliklər tətbiqin növbəti versiyasında qüvvəyə minir.':
        {
          'en': 'These terms may be updated when necessary. Updates take effect in the next app version.',
          'ru': 'Эти условия могут обновляться по мере необходимости. Изменения вступают в силу в следующей версии приложения.',
        },
    'Şifrəmi necə bərpa edə bilərəm?': {
      'en': 'How do I recover my password?',
      'ru': 'Как восстановить пароль?',
    },
    'Giriş ekranında “Şifrəni unutmusunuz?” keçidinə toxunun, e-poçt ünvanınızı yazın və göndərilən 6 rəqəmli kodu daxil edərək yeni şifrə yaradın.':
        {
          'en': 'Tap Forgot password on the sign-in screen, enter your email, then use the 6-digit code to create a new password.',
          'ru': 'На экране входа нажмите «Забыли пароль?», введите почту и создайте новый пароль с помощью шестизначного кода.',
        },
    'Qeydiyyatdan sonra region necə təyin olunur?': {
      'en': 'How is a region assigned after registration?',
      'ru': 'Как назначается регион после регистрации?',
    },
    'Regionları admin təyin edir. Qeydiyyatdan keçdikdən sonra əlaqə saxlayın ki, sizə uyğun region və apteklər hesabınıza bağlansın.':
        {
          'en': 'The admin assigns regions. Contact your admin after registration to link the appropriate region and pharmacies to your account.',
          'ru': 'Регионы назначает администратор. После регистрации свяжитесь с администратором для привязки нужного региона и аптек.',
        },
    'Stok qalığı necə hesablanır?': {
      'en': 'How is stock calculated?',
      'ru': 'Как рассчитывается остаток?',
    },
    'Qalıq daxilolma, satış və geri qaytarma qeydlərindən avtomatik hesablanır. Hər hərəkət stok ekranında ayrıca qeyd kimi saxlanılır.':
        {
          'en': 'Stock is calculated automatically from receipts, sales and returns. Each movement is saved as a separate stock record.',
          'ru': 'Остаток рассчитывается автоматически по поступлениям, продажам и возвратам. Каждое движение сохраняется отдельной записью.',
        },
    'Aylıq hesabatı necə göndərirəm?': {
      'en': 'How do I submit a monthly report?',
      'ru': 'Как отправить месячный отчёт?',
    },
    'Hesabat bölməsində ayı seçib sətirləri doldurun və “Göndər” düyməsinə toxunun. Menecer hesabatı təsdiqlədikdən sonra status yenilənir.':
        {
          'en': 'Select the month in Reports, fill in the rows and tap Submit. The status updates after your manager approves the report.',
          'ru': 'Выберите месяц в отчётах, заполните строки и нажмите «Отправить». Статус обновится после подтверждения менеджером.',
        },
    'Məlumatlarım internet olmadan görünür?': {
      'en': 'Can I view data offline?',
      'ru': 'Доступны ли данные без интернета?',
    },
    'Xeyr. Stok, satış və hesabat məlumatları serverdə saxlanılır, ona görə internet bağlantısı tələb olunur.':
        {
          'en': 'No. Stock, sales and report data are stored on the server, so an internet connection is required.',
          'ru': 'Нет. Данные об остатках, продажах и отчётах хранятся на сервере, поэтому требуется интернет.',
        },
    'Problem yaranarsa kimə müraciət edim?': {
      'en': 'Who should I contact if there is a problem?',
      'ru': 'К кому обращаться при проблемах?',
    },
    'Əvvəlcə tətbiqi bağlayıb yenidən açın. Problem davam edərsə, sistem admininə müraciət edin və ekranda görünən xəta mesajını bildirin.':
        {
          'en': 'First close and reopen the app. If the problem persists, contact your system admin and report the error message shown on screen.',
          'ru': 'Сначала закройте и откройте приложение. Если проблема сохраняется, свяжитесь с администратором и сообщите текст ошибки.',
        },
    'Giriş': {'en': 'Sign in', 'ru': 'Вход'},
    'Daxil olun': {'en': 'Sign in', 'ru': 'Войти'},
    'Qeydiyyat': {'en': 'Registration', 'ru': 'Регистрация'},
    'Qeydiyyatdan keçin': {'en': 'Sign up', 'ru': 'Зарегистрироваться'},
    'Hesabınız yoxdur?': {'en': 'No account?', 'ru': 'Нет аккаунта?'},
    'Artıq hesabınız var?': {
      'en': 'Already registered?',
      'ru': 'Уже есть аккаунт?',
    },
    'Stok, satış və hesabatları idarə etmək üçün hesabınıza daxil olun.': {
      'en': 'Sign in to manage stock, sales and reports.',
      'ru': 'Войдите для управления остатками, продажами и отчётами.',
    },
    'Stok, satış və hesabatları bir yerdə idarə etmək üçün hesab yaradın.': {
      'en':
          'Create an account to manage stock, sales and reports in one place.',
      'ru': 'Создайте аккаунт для управления остатками, продажами и отчётами.',
    },
    'E-poçt və ya istifadəçi adı': {
      'en': 'Email or username',
      'ru': 'Почта или имя пользователя',
    },
    'E-poçt (və ya istifadəçi adı) və şifrəni yaz': {
      'en': 'Enter your email or username and password',
      'ru': 'Введите почту или имя пользователя и пароль',
    },
    'Şifrəniz': {'en': 'Password', 'ru': 'Пароль'},
    'Şifrəni gizlət': {'en': 'Hide password', 'ru': 'Скрыть пароль'},
    'Şifrəni göstər': {'en': 'Show password', 'ru': 'Показать пароль'},
    'Şifrəni unutmusunuz?': {'en': 'Forgot password?', 'ru': 'Забыли пароль?'},
    'İstifadəçi adınız': {'en': 'Your name', 'ru': 'Ваше имя'},
    'Ad və soyad': {'en': 'Full name', 'ru': 'Имя и фамилия'},
    'Adınızı yaz': {'en': 'Enter your name', 'ru': 'Введите имя'},
    'Giriş adı': {'en': 'Username', 'ru': 'Имя пользователя'},
    'məsələn: elvin.h': {'en': 'e.g. elvin.h', 'ru': 'например: elvin.h'},
    'nümunə@mail.com': {'en': 'example@mail.com', 'ru': 'example@mail.com'},
    'İstifadəçi adı ən azı 3 simvol olmalıdır': {
      'en': 'Username must have at least 3 characters',
      'ru': 'Имя пользователя должно содержать минимум 3 символа',
    },
    'İstifadəçi adında boşluq olmamalıdır': {
      'en': 'Username cannot contain spaces',
      'ru': 'Имя пользователя не должно содержать пробелы',
    },
    'E-poçt ünvanınız': {'en': 'Email address', 'ru': 'Адрес почты'},
    'E-poçt': {'en': 'Email', 'ru': 'Почта'},
    'E-poçt ünvanı düzgün deyil': {
      'en': 'Invalid email address',
      'ru': 'Неверный адрес почты',
    },
    'Şifrə ən azı 8 simvol olmalıdır': {
      'en': 'Password must have at least 8 characters',
      'ru': 'Пароль должен содержать минимум 8 символов',
    },
    'Ən azı 8 simvol': {
      'en': 'At least 8 characters',
      'ru': 'Минимум 8 символов',
    },
    'Şifrələr eyni deyil': {
      'en': 'Passwords do not match',
      'ru': 'Пароли не совпадают',
    },
    'Yenidən şifrəniz': {'en': 'Confirm password', 'ru': 'Подтвердите пароль'},
    'Şifrəni təkrar yazın': {'en': 'Repeat password', 'ru': 'Повторите пароль'},
    'Şifrə bərpası': {'en': 'Password recovery', 'ru': 'Восстановление пароля'},
    'Şifrəni yeniləyin': {'en': 'Reset password', 'ru': 'Сброс пароля'},
    'E-poçt ünvanınızı daxil edin — təsdiq kodunu göndərək və yeni şifrə yaradın.':
        {
          'en': 'Enter your email to receive a verification code and create a new password.',
          'ru': 'Введите почту, чтобы получить код и создать новый пароль.',
        },
    'Kod göndərin': {'en': 'Send code', 'ru': 'Отправить код'},
    'Yeni şifrə yaradın': {
      'en': 'Create a new password',
      'ru': 'Создайте новый пароль',
    },
    'E-poçtunuza göndərilən 6 rəqəmli kodu və yeni şifrənizi yazın.': {
      'en': 'Enter the 6-digit code sent to your email and your new password.',
      'ru': 'Введите шестизначный код из письма и новый пароль.',
    },
    'Təsdiq kodu': {'en': 'Verification code', 'ru': 'Код подтверждения'},
    '6 rəqəmli kod': {'en': '6-digit code', 'ru': 'Шестизначный код'},
    '6 rəqəmli təsdiq kodunu yaz': {
      'en': 'Enter the 6-digit verification code',
      'ru': 'Введите шестизначный код подтверждения',
    },
    'Yeni şifrə': {'en': 'New password', 'ru': 'Новый пароль'},
    'Yeni şifrə ən azı 8 simvol olmalıdır': {
      'en': 'New password must have at least 8 characters',
      'ru': 'Новый пароль должен содержать минимум 8 символов',
    },
    'Yeni şifrəni təkrar yazın': {
      'en': 'Repeat new password',
      'ru': 'Повторите новый пароль',
    },
    'Yadda saxlayın': {'en': 'Save', 'ru': 'Сохранить'},
    'Kodu yenidən göndər': {
      'en': 'Resend code',
      'ru': 'Отправить код повторно',
    },
    'Şifrəniz uğurla yeniləndi!': {
      'en': 'Password reset successfully!',
      'ru': 'Пароль успешно обновлён!',
    },
    'Şifrəniz uğurla yeniləndi. Daxil olma prosesinə davam edə bilərsiniz.': {
      'en': 'Your password has been reset. You can now sign in.',
      'ru': 'Пароль обновлён. Теперь можно войти.',
    },
    'Davam edin': {'en': 'Continue', 'ru': 'Продолжить'},
    'Bütün xanaları doldur': {
      'en': 'Fill in all fields',
      'ru': 'Заполните все поля',
    },
    'Yeni şifrələr eyni deyil': {
      'en': 'New passwords do not match',
      'ru': 'Новые пароли не совпадают',
    },
    'Şifrə uğurla dəyişdirildi': {
      'en': 'Password changed successfully',
      'ru': 'Пароль успешно изменён',
    },
    'Şifrəni dəyişdirin': {'en': 'Change password', 'ru': 'Изменить пароль'},
    'Hesabınızın təhlükəsizliyi üçün şifrəni müntəzəm yeniləyin.': {
      'en': 'Update your password regularly to keep your account secure.',
      'ru': 'Регулярно обновляйте пароль для безопасности аккаунта.',
    },
    'Cari şifrə': {'en': 'Current password', 'ru': 'Текущий пароль'},
    'Mövcud şifrəniz': {
      'en': 'Your current password',
      'ru': 'Ваш текущий пароль',
    },
    'Yeni şifrəni təkrarla': {
      'en': 'Confirm new password',
      'ru': 'Подтвердите новый пароль',
    },
    'Şifrənizi unutmusunuzsa, giriş ekranındakı “Şifrəni unutmusunuz?” keçidindən istifadə edin. E-poçtunuza təsdiq kodu göndəriləcək.':
        {
          'en': 'If you forgot your password, use Forgot password on the sign-in screen. A verification code will be emailed to you.',
          'ru': 'Если забыли пароль, выберите «Забыли пароль?» на экране входа. Код будет отправлен на почту.',
        },
    'Tibbi nümayəndə': {
      'en': 'Medical representative',
      'ru': 'Медицинский представитель',
    },
    'Menecer': {'en': 'Manager', 'ru': 'Менеджер'},
    'Admin': {'en': 'Administrator', 'ru': 'Администратор'},
    'Profili redaktə et': {'en': 'Edit profile', 'ru': 'Редактировать профиль'},
    'Profil şəkli yükləmə tezliklə əlavə olunacaq': {
      'en': 'Profile photo upload is not available yet',
      'ru': 'Загрузка фото профиля пока недоступна',
    },
    'Əlaqə nömrəniz': {'en': 'Phone number', 'ru': 'Номер телефона'},
    'WhatsApp nömrəniz': {'en': 'WhatsApp number', 'ru': 'Номер WhatsApp'},
    'Telefon': {'en': 'Phone', 'ru': 'Телефон'},
    'Hesab məlumatları': {'en': 'Account details', 'ru': 'Данные аккаунта'},
    'Bağlı regionlar': {'en': 'Assigned regions', 'ru': 'Назначенные регионы'},
    'Region təyin olunmayıb. Adminlə əlaqə saxlayın.': {
      'en': 'No region assigned. Contact your admin.',
      'ru': 'Регион не назначен. Обратитесь к администратору.',
    },
    'Hesaba e-poçt əlavə olunmayıb. Şifrə bərpası üçün adminlə əlaqə saxlayın.':
        {
          'en': 'No email is linked. Contact your admin for password recovery.',
          'ru': 'Почта не указана. Для восстановления пароля обратитесь к администратору.',
        },
    'Hesabatı doldur': {'en': 'Fill in report', 'ru': 'Заполнить отчёт'},
    'Bütün regionlar': {'en': 'All regions', 'ru': 'Все регионы'},
    'Bu dövr üçün göndərilmiş hesabat yoxdur': {
      'en': 'No submitted reports for this period',
      'ru': 'Нет отправленных отчётов за этот период',
    },
    'Bu dövr üçün hələ qeyd yoxdur': {
      'en': 'No records for this period yet',
      'ru': 'За этот период пока нет записей',
    },
    'Ümumi göstəricilər': {'en': 'Overview', 'ru': 'Общие показатели'},
    'Ən çox yazan həkimlər': {
      'en': 'Top prescribing doctors',
      'ru': 'Врачи с наибольшим числом рецептов',
    },
    'Son 6 ay': {'en': 'Last 6 months', 'ru': 'Последние 6 месяцев'},
    'İşçilər üzrə': {'en': 'By employee', 'ru': 'По сотрудникам'},
    'Bütün işçilər': {'en': 'All employees', 'ru': 'Все сотрудники'},
    'Bu ay göndərilmiş hesabat yoxdur': {
      'en': 'No reports submitted this month',
      'ru': 'Нет отправленных отчётов за этот месяц',
    },
    'Regionlar üzrə': {'en': 'By region', 'ru': 'По регионам'},
    'Dərman yoxdur': {'en': 'No medicines', 'ru': 'Нет препаратов'},
    'Keçən ay yoxdur': {
      'en': 'No previous month data',
      'ru': 'Нет данных за прошлый месяц',
    },
    'Dəyişməyib': {'en': 'Unchanged', 'ru': 'Без изменений'},
    'Məlumat yoxdur': {'en': 'No data', 'ru': 'Нет данных'},
    'Bu ay üçün həkim qeydi yoxdur': {
      'en': 'No doctor records this month',
      'ru': 'Нет записей врачей за этот месяц',
    },
    'Bütün həkimlər': {'en': 'All doctors', 'ru': 'Все врачи'},
    'Hamısına bax': {'en': 'View all', 'ru': 'Посмотреть все'},
    'Qrafiklər': {'en': 'Charts', 'ru': 'Графики'},
    'Qiymətlər': {'en': 'Prices', 'ru': 'Цены'},
    'Regionunda aktiv həkim və ya dərman yoxdur. Admindən xahiş et.': {
      'en':
          'No active doctors or medicines in your region. Contact your admin.',
      'ru': 'В регионе нет активных врачей или препаратов. Обратитесь к администратору.',
    },
    'Yadda saxlandı': {'en': 'Saved', 'ru': 'Сохранено'},
    'Hesabat göndərilsin?': {'en': 'Submit report?', 'ru': 'Отправить отчёт?'},
    'Göndərildikdən sonra hesabatı dəyişmək olmaz.': {
      'en': 'Reports cannot be edited after submission.',
      'ru': 'После отправки отчёт нельзя изменить.',
    },
    'Göndər': {'en': 'Submit', 'ru': 'Отправить'},
    'Hesabat göndərildi': {'en': 'Report submitted', 'ru': 'Отчёт отправлен'},
    'Qaralama': {'en': 'Draft', 'ru': 'Черновик'},
    'Göndərilib': {'en': 'Submitted', 'ru': 'Отправлено'},
    'Geri qaytarılıb': {'en': 'Returned', 'ru': 'Возвращено'},
    'Doldurulmayıb': {'en': 'Not filled in', 'ru': 'Не заполнено'},
    'Bu hesabat artıq dəyişdirilə bilməz.': {
      'en': 'This report can no longer be edited.',
      'ru': 'Этот отчёт больше нельзя изменить.',
    },
    'Menecerin şərhi': {'en': 'Manager comment', 'ru': 'Комментарий менеджера'},
    'Heç nə tapılmadı': {'en': 'Nothing found', 'ru': 'Ничего не найдено'},
    'Həkim axtar': {'en': 'Search doctors', 'ru': 'Поиск врачей'},
    'Hesabat hələ göndərilməyib': {
      'en': 'Report not submitted yet',
      'ru': 'Отчёт ещё не отправлен',
    },
    'Sənə bağlı işçi yoxdur. Admindən xahiş et.': {
      'en': 'No employees assigned. Contact your admin.',
      'ru': 'Сотрудники не назначены. Обратитесь к администратору.',
    },
    'Hesabat təsdiqlənsin?': {
      'en': 'Approve report?',
      'ru': 'Подтвердить отчёт?',
    },
    'Təsdiqləndikdən sonra hesabat dəyişdirilə və geri qaytarıla bilməz.': {
      'en': 'Once approved, a report cannot be edited or returned.',
      'ru': 'После подтверждения отчёт нельзя изменить или вернуть.',
    },
    'Təsdiqlə': {'en': 'Approve', 'ru': 'Подтвердить'},
    'Hesabat təsdiqləndi': {'en': 'Report approved', 'ru': 'Отчёт подтверждён'},
    'Hesabat şərhlə geri qaytarıldı': {
      'en': 'Report returned with a comment',
      'ru': 'Отчёт возвращён с комментарием',
    },
    'Geri qaytar': {'en': 'Return', 'ru': 'Вернуть'},
    'Sənin şərhin': {'en': 'Your comment', 'ru': 'Ваш комментарий'},
    'Dərman üzrə cəmi': {
      'en': 'Totals by medicine',
      'ru': 'Итоги по препаратам',
    },
    'Qeyd yoxdur': {'en': 'No records', 'ru': 'Нет записей'},
    'Hələ qeyd yoxdur': {'en': 'No records yet', 'ru': 'Записей пока нет'},
    'Ümumi': {'en': 'Total', 'ru': 'Итого'},
    'Həkimlər üzrə': {'en': 'By doctor', 'ru': 'По врачам'},
    'Hesabatı geri qaytar': {'en': 'Return report', 'ru': 'Вернуть отчёт'},
    'Nümayəndəyə şərh': {
      'en': 'Comment for representative',
      'ru': 'Комментарий представителю',
    },
    'Şərh yaz': {'en': 'Enter a comment', 'ru': 'Введите комментарий'},
    'Yeni qiymət əlavə olunsun?': {
      'en': 'Add a new price?',
      'ru': 'Добавить новую цену?',
    },
    'Köhnə qiymət tarixçədə qalır.': {
      'en': 'The old price stays in history.',
      'ru': 'Старая цена остаётся в истории.',
    },
    'Qüvvəyə minmə': {'en': 'Effective date', 'ru': 'Дата вступления в силу'},
    'Qüvvəyə minir': {'en': 'Effective from', 'ru': 'Действует с'},
    'Əlavə et': {'en': 'Add', 'ru': 'Добавить'},
    'Qiymət əlavə olundu': {'en': 'Price added', 'ru': 'Цена добавлена'},
    'Aktiv dərman yoxdur': {
      'en': 'No active medicines',
      'ru': 'Нет активных препаратов',
    },
    'Qiymət təyin olunmayıb': {
      'en': 'Price not set',
      'ru': 'Цена не назначена',
    },
    'Tarixçə': {'en': 'History', 'ru': 'История'},
    'Yeni qiymət': {'en': 'New price', 'ru': 'Новая цена'},
    'Qiyməti düzgün yaz (məs. 12.50)': {
      'en': 'Enter a valid price (e.g. 12.50)',
      'ru': 'Введите верную цену (например, 12.50)',
    },
    'Qiymət 0-dan böyük olmalıdır': {
      'en': 'Price must be greater than 0',
      'ru': 'Цена должна быть больше 0',
    },
    'Qiymət (₼)': {'en': 'Price (₼)', 'ru': 'Цена (₼)'},
    'tarixindən': {'en': 'Effective from', 'ru': 'Действует с'},
    'Bu ay üçün geri qaytarma qeydi yoxdur': {
      'en': 'No returns this month',
      'ru': 'Нет возвратов за этот месяц',
    },
    'Ay üzrə cəmi': {'en': 'Monthly total', 'ru': 'Итог за месяц'},
    'Medstock qeyd tarixçəsi': {
      'en': 'MedStock record history',
      'ru': 'История записей MedStock',
    },
    'Excel faylı hazırlanmadı': {
      'en': 'Could not create Excel file',
      'ru': 'Не удалось создать файл Excel',
    },
    'Excel kimi ixrac et': {'en': 'Export to Excel', 'ru': 'Экспорт в Excel'},
    'Hamısı': {'en': 'All', 'ru': 'Все'},
    'Bütün aylar': {'en': 'All months', 'ru': 'Все месяцы'},
    'Bu filtr üzrə qeyd tapılmadı': {
      'en': 'No records match this filter',
      'ru': 'Нет записей по этому фильтру',
    },
    'Qeydi sil?': {'en': 'Delete record?', 'ru': 'Удалить запись?'},
    'qeydi silinəcək. Qalıq yenidən hesablanacaq.': {
      'en': 'will be deleted. Stock will be recalculated.',
      'ru': 'будет удалена. Остаток будет пересчитан.',
    },
    'Sil': {'en': 'Delete', 'ru': 'Удалить'},
    'Qeyd silindi': {'en': 'Record deleted', 'ru': 'Запись удалена'},
    'Düzəliş et': {'en': 'Edit', 'ru': 'Редактировать'},
    'Say düzgün deyil': {'en': 'Invalid quantity', 'ru': 'Неверное количество'},
    'Qeydə düzəliş': {'en': 'Edit record', 'ru': 'Редактировать запись'},
    'Səbəb': {'en': 'Reason', 'ru': 'Причина'},
    'Aptek/Depo': {'en': 'Pharmacy/Warehouse', 'ru': 'Аптека/Склад'},
    'Əlavə edən': {'en': 'Created by', 'ru': 'Добавлено'},
    'Dəyişiklik tarixçəsi': {'en': 'Change history', 'ru': 'История изменений'},
    'Dəyişiklik edilməyib': {'en': 'No changes', 'ru': 'Изменений нет'},
    'Silinib': {'en': 'Deleted', 'ru': 'Удалено'},
    'Düzəliş': {'en': 'Edited', 'ru': 'Изменено'},
    'Server oyanır, bir az gözləyin…': {
      'en': 'Server is starting, please wait…',
      'ru': 'Сервер запускается, подождите…',
    },
    'Məlumat yüklənmədi. Bir az sonra yenidən cəhd et.': {
      'en': 'Could not load data. Please try again shortly.',
      'ru': 'Не удалось загрузить данные. Повторите немного позже.',
    },
    'Yenidən cəhd et': {'en': 'Retry', 'ru': 'Повторить'},
    'Serverlə əlaqə qurulmadı': {
      'en': 'Could not connect to server',
      'ru': 'Не удалось подключиться к серверу',
    },
    'Sessiya bitib, yenidən daxil ol': {
      'en': 'Session expired. Sign in again',
      'ru': 'Сессия истекла. Войдите снова',
    },
    'Server xətası': {'en': 'Server error', 'ru': 'Ошибка сервера'},
    'Məlumatlar düzgün deyil': {'en': 'Invalid data', 'ru': 'Неверные данные'},
    'Login və ya şifrə yanlışdır': {
      'en': 'Incorrect username or password',
      'ru': 'Неверное имя пользователя или пароль',
    },
    'Bu hesab artıq mövcuddur': {
      'en': 'This account already exists',
      'ru': 'Этот аккаунт уже существует',
    },
    'Məlumatları yoxla: e-poçt və şifrə düzgün olmalıdır': {
      'en': 'Check your email and password',
      'ru': 'Проверьте почту и пароль',
    },
    'Bir az sonra yenidən cəhd edin': {
      'en': 'Try again shortly',
      'ru': 'Повторите немного позже',
    },
    'E-poçt göndərilmədi': {
      'en': 'Email could not be sent',
      'ru': 'Не удалось отправить письмо',
    },
    'Kod göndərildi': {'en': 'Code sent', 'ru': 'Код отправлен'},
    'Çox cəhd edildi. Yeni kod istəyin': {
      'en': 'Too many attempts. Request a new code',
      'ru': 'Слишком много попыток. Запросите новый код',
    },
    'Kod yanlışdır və ya vaxtı bitib': {
      'en': 'Code is incorrect or expired',
      'ru': 'Код неверен или истёк',
    },
    'Şifrə yenilənmədi. Yenidən kod istəyin': {
      'en': 'Password not updated. Request a new code',
      'ru': 'Пароль не обновлён. Запросите новый код',
    },
    'Profil yadda saxlanmadı': {
      'en': 'Profile could not be saved',
      'ru': 'Не удалось сохранить профиль',
    },
    'Demo rejimi (SMTP qurulmayıb). Təsdiq kodunuz': {
      'en': 'Demo mode (SMTP not configured). Verification code',
      'ru': 'Демо-режим (SMTP не настроен). Код подтверждения',
    },
  };

  static String deyer(String achar) {
    final c = _c[achar] ?? _metnler[achar] ?? _azAcarlar[achar];
    return c?[AppState.instance.dil.name] ?? c?['az'] ?? achar;
  }
}
