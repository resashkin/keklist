// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get insightsBrightestPeriod => 'Eng yorqin davr';

  @override
  String get insightsPeriodWeek => 'Hafta';

  @override
  String get insightsPeriodMonth => 'Oy';

  @override
  String get insightsPeriodYear => 'Yil';

  @override
  String get insightsPeriodAllTime => 'Butun davr';

  @override
  String insightsVsLastWeek(String delta) {
    return 'Oʻtgan haftaga nisbatan $delta';
  }

  @override
  String insightsVsLastMonth(String delta) {
    return 'Oʻtgan oyga nisbatan $delta';
  }

  @override
  String insightsVsLastYear(String delta) {
    return 'Oʻtgan yilga nisbatan $delta';
  }

  @override
  String get insightsCategorySummary => 'Umumiy';

  @override
  String get insightsCategoryEmotions => 'Hissiyotlar';

  @override
  String get insightsCategoryActivity => 'Faollik';

  @override
  String get insightsCategoryMemories => 'Xotiralar';

  @override
  String get insightsCategoryMedia => 'Media';

  @override
  String get insightsCounters => 'Raqamlarda';

  @override
  String get insightsMinds => 'Yozuvlar';

  @override
  String get insightsActiveDays => 'Faol kunlar';

  @override
  String get insightsWords => 'Soʻzlar';

  @override
  String get insightsBrightestDay => 'Eng yorqin kun';

  @override
  String get insightsBrightestWeek => 'Eng yorqin hafta';

  @override
  String get insightsBrightestMonth => 'Eng yorqin oy';

  @override
  String get insightsBrightestYear => 'Eng yorqin yil';

  @override
  String insightsBrightestDetails(String minds, String emotions, String media) {
    return 'yozuv: $minds · hissiyot: $emotions · media: $media';
  }

  @override
  String get insightsEmotionDistribution => 'Hissiyotlar';

  @override
  String get insightsEmotionTrend => 'Hissiyotlar dinamikasi';

  @override
  String get insightsEmotionPairs => 'Birga uchraydigan hissiyotlar';

  @override
  String get insightsEmotionRhythm => 'Hissiy ritm';

  @override
  String get insightsByWeekday => 'Hafta kunlari boʻyicha';

  @override
  String get insightsByDayPart => 'Kun vaqti boʻyicha';

  @override
  String get insightsNight => 'Tun';

  @override
  String get insightsMorning => 'Ertalab';

  @override
  String get insightsAfternoon => 'Kunduzi';

  @override
  String get insightsEvening => 'Kechqurun';

  @override
  String get insightsStreak => 'Seriya';

  @override
  String get insightsStreakLabel => 'kun ketma-ket';

  @override
  String insightsLongestStreak(String count) {
    return 'Rekord: $count';
  }

  @override
  String get insightsStreakKeepGoing =>
      'Seriyani uzmaslik uchun bugun yozuv qoʻshing';

  @override
  String get insightsHeatmap => 'Faollik xaritasi';

  @override
  String get insightsActivityTime => 'Kun vaqti';

  @override
  String insightsPeakHour(String hour) {
    return 'Koʻpincha $hour atrofida';
  }

  @override
  String get insightsOnThisDay => 'Shu kuni';

  @override
  String get insightsMediaCounters => 'Media';

  @override
  String get insightsPhotos => 'Rasmlar';

  @override
  String get insightsVideos => 'Videolar';

  @override
  String get insightsVoiceNotes => 'Ovozli yozuvlar';

  @override
  String get insightsRoundVideos => 'Dumaloq videolar';

  @override
  String get insightsEmptyPeriod => 'Bu davrda hali yozuv yoʻq';

  @override
  String get insightsEmptyEmotions =>
      'Buni koʻrish uchun yozuvlarga hissiyot belgilang';

  @override
  String get insightsEmptyPairs =>
      'Juftlarni koʻrish uchun yozuvga ikki hissiyot belgilang';

  @override
  String get insightsEmptyOnThisDay =>
      'Oʻtgan yillarda bu kunda hali hech narsa yoʻq';

  @override
  String get insightsEmptyRoundVideos => 'Bu davrda dumaloq video yoʻq';

  @override
  String get insightsEmptyStreak =>
      'Seriyani boshlash uchun bugun yozuv qoʻshing';

  @override
  String get insightsCustomize => 'Analitikani sozlash';

  @override
  String get insightsCustomizeDescription =>
      'Kartochkalarni yoqing yoki oʻchiring, tartibini sudrab oʻzgartiring';

  @override
  String get insightsResetLayout => 'Tiklash';

  @override
  String get activeTasks => 'Faol vazifalar';

  @override
  String get galleryIndex => 'Galereya indeksi';

  @override
  String get galleryIndexNoAccess => 'Rasmlarga ruxsat yoʻq';

  @override
  String get galleryIndexNotIndexed => 'Hali indekslanmagan';

  @override
  String galleryIndexIndexing(String done, String total) {
    return 'Indekslanmoqda $done / $total';
  }

  @override
  String galleryIndexReady(String count, String time) {
    return '$count ta rasm va video · yangilandi $time';
  }

  @override
  String galleryIndexThumbnails(String size) {
    return 'Miniatyuralar keshi: $size';
  }

  @override
  String get galleryIndexRebuildTitle => 'Galereya indeksi qayta tuzilsinmi?';

  @override
  String get galleryIndexRebuildMessage =>
      'Miniatyuralar oʻchiriladi va mediateka qayta skanerlanadi.';

  @override
  String get galleryIndexRebuild => 'Qayta tuzish';

  @override
  String get allEmotions => 'Hammasi…';

  @override
  String get settings => 'Sozlamalar';

  @override
  String get userData => 'Foydalanuvchi ma\'lumotlari';

  @override
  String get appearance => 'Ko\'rinish';

  @override
  String get interfaceStyle => 'Interfeys uslubi';

  @override
  String get exportToCsv => 'CSV ga eksport qilish';

  @override
  String get exportData => 'Ma\'lumotlarni eksport qilish';

  @override
  String get importData => 'Ma\'lumotlarni import qilish';

  @override
  String get done => 'TAYYOR';

  @override
  String get chatWithAI => 'AI bilan suhbatlashish';

  @override
  String get photosPerDay => 'Kuniga rasmlar';

  @override
  String get extraActions => 'Qo\'shimcha harakatlar';

  @override
  String get mindOptions => 'Fikr variantlari';

  @override
  String get edit => 'Tahrirlash';

  @override
  String get delete => 'O\'chirish';

  @override
  String get share => 'Ulashish';

  @override
  String get saveToFiles => 'Fayllarga saqlash';

  @override
  String get switchDay => 'Kunni almashtirish';

  @override
  String get goToDate => 'Sana orqali o\'tish';

  @override
  String get showDigest => '... uchun xulosa ko\'rsatish';

  @override
  String get translateToEnglish => 'Ingliz tiliga tarjima qilish';

  @override
  String get convertToStandalone => 'Mustaqil qilish';

  @override
  String get language => 'Til';

  @override
  String get selectLanguage => 'Tilni tanlash';

  @override
  String get theme => 'Mavzu';

  @override
  String get themeLight => 'Kunduzgi';

  @override
  String get themeDark => 'Tungi';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get showDayDividers => 'Kun ajratuvchilarini ko\'rsatish';

  @override
  String get tabsSettings => 'Tab sozlamalari';

  @override
  String get whatsNew => 'Yangi nimalar?';

  @override
  String get releaseNotes => 'Reliz eslatmalari';

  @override
  String get suggestFeature => 'Xususiyat taklif qilish';

  @override
  String get sendFeedback => 'Fikr-mulohaza yuborish';

  @override
  String get emailUs => 'Bizga email yozing';

  @override
  String get clearOfflineDataWarning =>
      'Barcha oflayn ma\'lumotlaringiz o\'chiriladi. Ularni oldindan eksport qilganingizga ishonch hosil qiling.';

  @override
  String get sourceCode => 'Manba kodi';

  @override
  String get termsOfUse => 'Foydalanish shartlari';

  @override
  String get privacyPolicy => 'Maxfiylik siyosati';

  @override
  String get clearOnDeviceData => 'Qurilmadagi ma\'lumotlarni tozalash';

  @override
  String get setOpenAIToken => 'Open AI Token o\'rnatish';

  @override
  String get cancel => 'Bekor qilish';

  @override
  String get save => 'Saqlash';

  @override
  String get mind => 'Fikr';

  @override
  String get profile => 'Profil';

  @override
  String get insights => 'Tahlil';

  @override
  String get calendar => 'Taqvim';

  @override
  String get debugMenu => 'Debug menyusi';

  @override
  String get discussion => 'Muhokama';

  @override
  String get about => 'Haqida';

  @override
  String get dangerZone => 'Xavfli zona';

  @override
  String get enterTokenHere => 'Token bu yerga kiriting';

  @override
  String get token => 'Token';

  @override
  String get clearCache => 'Keshni tozalash';

  @override
  String get activeTabs => 'Faol tablar';

  @override
  String get hiddenTabs => 'Yashirin tablar';

  @override
  String get error => 'Xatolik';

  @override
  String get startDiscussion => 'Muhokamani boshlash';

  @override
  String get send => 'YUBORISH';

  @override
  String get updateYourNickname => 'Niknamingizni yangilash';

  @override
  String get yourNickname => 'Sizning niknamingiz';

  @override
  String get create => 'Yaratish';

  @override
  String get yourFolderName => 'Sizning papka nomingiz';

  @override
  String get noMindsInSelectedPeriod => 'Tanlangan davrda fikrlar yo\'q';

  @override
  String get noMindsForPeriod => 'Bu davr uchun fikrlar yo\'q';

  @override
  String get selectPeriod => 'Davrni tanlash ...';

  @override
  String get digest => 'Xulosa';

  @override
  String get minds => 'Fikrlar';

  @override
  String get searchForYourNotes => 'Eslatmalaringizni qidiring';

  @override
  String get searchYourEmoji => 'Emojingizni qidiring...';

  @override
  String get writeSomething => 'Biror narsa yozing...';

  @override
  String get todayMinds => 'Bugungi fikrlar';

  @override
  String get youDidNotCollectAnyEntriesYet =>
      'Siz hali hech qanday yozuv yig\'ganingiz yo\'q';

  @override
  String get areYouSure => 'Ishonchingiz komilmi?';

  @override
  String get cannotRemoveMainScreen =>
      'Asosiy ekranni olib bo\'lmaydi. Tab sozlamalarini yo\'qotasiz.';

  @override
  String get today => 'Bugun';

  @override
  String get yesterday => 'Kecha';

  @override
  String get thisWeek => 'Bu hafta';

  @override
  String get lastTwoWeeks => 'So\'nggi 2 hafta';

  @override
  String get thisMonth => 'Bu oy';

  @override
  String get thisYear => 'Bu yil';

  @override
  String get calendarDescription => 'Yozuvlar taqvimi bilan asosiy ekran';

  @override
  String get insightsDescription => 'Barcha yozuvlaringiz statistikasi';

  @override
  String get settingsDescription =>
      'Barcha sozlamalar ekrani (qorong\'u rejim, sinxronlash va boshqalar)';

  @override
  String get profileDescription => 'Profilingiz bilan ekran';

  @override
  String get todayDescription => 'Faqat bugungi fikrlar';

  @override
  String get debugMenuDescription =>
      'Eksperimental xususiyatlarni yoqish uchun dasturchi vositalari';

  @override
  String get noMindsForThisDay => 'Bu kun uchun fikrlar yo\'q';

  @override
  String get week => 'Hafta';

  @override
  String get password => 'Parol';

  @override
  String get archivePassword => 'Arxiv paroli';

  @override
  String get enterPassword => 'Parolni kiriting';

  @override
  String get confirmPassword => 'Parolni tasdiqlang';

  @override
  String get reenterPassword => 'Parolni qayta kiriting';

  @override
  String get passwordsDoNotMatch => 'Parollar mos kelmaydi';

  @override
  String get exportPassword => 'Eksportni parol bilan himoyalaysizmi?';

  @override
  String get exportPasswordDescription =>
      'Eksportingizni shifrlash uchun parol qo\'shing. Shifrlanmagan eksport uchun buni o\'tkazib yuborishingiz mumkin.';

  @override
  String get importPassword => 'Parolni kiriting';

  @override
  String get importPasswordDescription =>
      'Bu fayl parol bilan himoyalangan. Shifrni ochish uchun parolni kiriting.';

  @override
  String get skipPassword => 'O\'tkazib yuborish (parolsiz)';

  @override
  String get continue_ => 'Davom etish';

  @override
  String get incorrectPassword => 'Noto\'g\'ri parol';

  @override
  String get incorrectPasswordMessage =>
      'Siz kiritgan parol noto\'g\'ri. Iltimos, qayta urinib ko\'ring.';

  @override
  String get corruptedFile => 'Buzilgan fayl';

  @override
  String get invalidFormat => 'Yaroqsiz format';

  @override
  String get missingAudioFiles => 'Ba\'zi audio fayllar yo\'q';

  @override
  String get insufficientStorage => 'Yetarli saqlash joyi yo\'q';

  @override
  String get unknownError => 'Noma\'lum xato';

  @override
  String get retry => 'Qayta urinish';

  @override
  String get ok => 'OK';

  @override
  String get exportSuccess => 'Eksport muvaffaqiyatli';

  @override
  String get exportError => 'Eksport muvaffaqiyatsiz';

  @override
  String get importSuccess => 'Import muvaffaqiyatli';

  @override
  String get importError => 'Import muvaffaqiyatsiz';

  @override
  String get mindsToExport => 'Fikrlar';

  @override
  String get audioFilesToExport => 'Audio fayllar';

  @override
  String get emotionsToExport => 'Hislar';

  @override
  String get mindsExported => 'Fikrlar eksport qilindi';

  @override
  String get audioFilesExported => 'Audio fayllar eksport qilindi';

  @override
  String get mindsImported => 'Fikrlar import qilindi';

  @override
  String get audioFilesImported => 'Audio fayllar import qilindi';

  @override
  String get onboardingMind1 => 'Salom!';

  @override
  String get onboardingMind2 =>
      'Men keklist - qisqa yozuvlarning shaxsiy kundaligiman';

  @override
  String get onboardingMind2Comment1 => 'Yozuvlarga sharh qoldirish mumkin';

  @override
  String get onboardingMind2Comment2 => 'Yozuvni ochish uchun uni bosing';

  @override
  String get onboardingMind3 =>
      '\'Kalendar\' yorlig\'ida barcha yozuvlar kunlar, haftalar va oylar bo\'yicha ko\'rsatiladi';

  @override
  String get onboardingMind4 =>
      '\'Analitika\' yorlig\'i yozuvlaringizning qisqacha statistikasini ko\'rsatadi';

  @override
  String get onboardingMind5 =>
      'Barcha yozuvlar faqat telefoningizda saqlanadi';

  @override
  String get onboardingMind6 =>
      'Yangi yozuv yaratish uchun \'Yozish\' tugmasini bosing';

  @override
  String get noPhotosForDay => 'Bu kun uchun rasmlar topilmadi';

  @override
  String get sourcesMediaFolder => 'Media fayllar';

  @override
  String get sourcesMediaFolderSubtitle =>
      'Tanlangan papkadan foto va videolar';

  @override
  String get mediaFolderSettings => 'Media fayllar';

  @override
  String get licenses => 'Litsenziyalar';

  @override
  String get sourcesWeather => 'Ob-havo';

  @override
  String get sourcesWeatherSubtitle =>
      'Ushbu kun uchun mahalliy ob-havo sharoitlari';

  @override
  String get weatherSettings => 'Ob-havo sozlamalari';

  @override
  String get weatherLatitude => 'Kenglik';

  @override
  String get weatherLongitude => 'Uzunlik';

  @override
  String get weatherSaveLocation => 'Joylashuvni saqlash';

  @override
  String get weatherUseMyLocation => 'Mening joylashuvimdan foydalanish';

  @override
  String get weatherDetectingLocation => 'Joylashuv aniqlanmoqda...';

  @override
  String get weatherOrEnterManually => 'yoki qo\'lda kiriting';

  @override
  String get weatherLocationError =>
      'Joylashuvni aniqlab bo\'lmadi. Iltimos, qo\'lda kiriting.';

  @override
  String get weatherLocationServicesDisabled =>
      'Joylashuv xizmatlari o\'chirilgan. Sozlamalarda yoqing.';

  @override
  String get weatherLocationPermissionDenied => 'Joylashuv ruxsati rad etildi.';

  @override
  String get weatherLocationPermissionPermanentlyDenied =>
      'Joylashuv ruxsati doimiy ravishda rad etildi. Ilova sozlamalari ochilmoqda.';

  @override
  String get audioRecordTitle => 'Audio yozish';

  @override
  String get audioRecordTitleRecording => 'Yozilmoqda…';

  @override
  String get audioRecordHint => 'Saqlash uchun «To\'xtatish»ni bosing.';

  @override
  String get audioRecordStart => 'Boshlash';

  @override
  String get audioRecordStop => 'To\'xtatish';

  @override
  String get audioRecordCancel => 'Bekor qilish';

  @override
  String get audioRecordPermissionError =>
      'Audio yozish uchun mikrofon ruxsati talab qilinadi.';

  @override
  String get audioRecordStartError =>
      'Yozishni boshlash imkoni bo\'lmadi. Qayta urinib ko\'ring.';

  @override
  String get audioRecordStopError =>
      'Yozishni to\'xtatish imkoni bo\'lmadi. Qayta urinib ko\'ring.';

  @override
  String proUserFooter(String price, String date) {
    return 'Siz PRO foydalanuvchisiz. Keyingi $price to\'lov $date da bo\'ladi.';
  }

  @override
  String get emotions => 'Hissiyotlar';

  @override
  String get archived => 'Arxivlangan';

  @override
  String get archive => 'Arxivlash';

  @override
  String get restore => 'Tiklash';

  @override
  String get deletePermanently => 'Butunlay o\'chirish';

  @override
  String get newEmotion => 'Yangi hissiyot';

  @override
  String get editEmotion => 'Hissiyotni tahrirlash';

  @override
  String get addEmotion => 'Hissiyot qo\'shish';

  @override
  String get addEmotionsToMind => 'Hislar qo\'shish';

  @override
  String get emotionNameHint => 'Nomi';

  @override
  String get doneEditing => 'Tayyor';

  @override
  String get emotionEditHint =>
      'Nomini o\'zgartirish uchun bosing · ✕ o\'chirish uchun · tartiblash uchun torting';

  @override
  String get emotionInUseMessage =>
      'Bu hissiyot ba\'zi maindlarda ishlatiladi. Uni o\'sha yerda saqlash uchun arxivlang yoki hamma joydan o\'chiring.';

  @override
  String get emotionPickHint => 'Belgilash uchun bosing';

  @override
  String get emotionDrillHint => 'chuqurlashish uchun bosib turing';

  @override
  String get noEmotionsYet => 'Hozircha hissiyotlar yo\'q';

  @override
  String get noArchivedEmotions => 'Arxivlangan hissiyotlar yo\'q';

  @override
  String get deleteEmotionMessage =>
      'Bu hissiyotni o\'chirasizmi? U undan foydalanadigan barcha maindlardan olib tashlanadi.';

  @override
  String get dayFeedTileSettings => 'Plitka sozlamalari';

  @override
  String get dayFeedColumns => 'Ustunlar';

  @override
  String get dayFeedMindTileSize => 'Plitka o‘lchami';

  @override
  String get dayFeedMindTileSquare => 'Kvadrat';

  @override
  String get dayFeedMindTileWide => 'Keng';

  @override
  String get dayFeedShowMindText => 'Matnni ko‘rsatish';

  @override
  String get dayFeedPhotoAccessHint =>
      'Bu yerda foto va videolarni ko‘rish uchun suratlarga ruxsat bering';

  @override
  String get dayFeedAllowAccess => 'Ruxsat berish';

  @override
  String get dayFeedFolderHint =>
      'Bu yerda foto va videolarni ko‘rish uchun media papkasini tanlang';

  @override
  String get dayFeedChooseFolder => 'Tanlash';

  @override
  String get dayFeedMute => 'Ovozni o‘chirish';

  @override
  String get dayFeedUnmute => 'Ovozni yoqish';

  @override
  String get holdToRecordAudio => 'Ovozli xabar yozish uchun bosib turing';

  @override
  String get holdToRecordVideo => 'Video xabar yozish uchun bosib turing';

  @override
  String get roundVideoRecordError => 'Videoni yozib bo‘lmadi';

  @override
  String get roundVideoCameraUnavailable => 'Bu qurilmada kamera mavjud emas';

  @override
  String get roundVideoRetake => 'Qayta olish';

  @override
  String get roundVideoUse => 'Foydalanish';

  @override
  String get removeMedia => 'Mediani o‘chirish';

  @override
  String get shakeToCustomize => 'Sozlash uchun silkiting';

  @override
  String get shakeToCustomizeHint => 'yoki sarlavhani bosib turing';

  @override
  String get customizeSettings => 'Sozlamalarni moslash';

  @override
  String get customizeSettingsDescription =>
      'Belgisi olib tashlangan bo‘lim va qatorlar Sozlamalar ekranida yashiriladi.';

  @override
  String get calendarSettings => 'Kalendar sozlamalari';

  @override
  String get calendarShowMedia => 'Foto va videolarni ko‘rsatish';

  @override
  String get calendarWeekTitles => 'Hafta sarlavhalari';

  @override
  String get calendarHideEmptyDays => 'Bo‘sh kunlarni yashirish';
}
