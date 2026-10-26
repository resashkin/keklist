// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get insightsBrightestPeriod => 'Ең жарқын кезең';

  @override
  String get insightsPeriodWeek => 'Апта';

  @override
  String get insightsPeriodMonth => 'Ай';

  @override
  String get insightsPeriodYear => 'Жыл';

  @override
  String get insightsPeriodAllTime => 'Барлық уақыт';

  @override
  String insightsVsLastWeek(String delta) {
    return 'Өткен аптамен салыстырғанда $delta';
  }

  @override
  String insightsVsLastMonth(String delta) {
    return 'Өткен аймен салыстырғанда $delta';
  }

  @override
  String insightsVsLastYear(String delta) {
    return 'Өткен жылмен салыстырғанда $delta';
  }

  @override
  String get insightsCategorySummary => 'Шолу';

  @override
  String get insightsCategoryEmotions => 'Эмоциялар';

  @override
  String get insightsCategoryActivity => 'Белсенділік';

  @override
  String get insightsCategoryMemories => 'Естеліктер';

  @override
  String get insightsCategoryMedia => 'Медиа';

  @override
  String get insightsCounters => 'Сандармен';

  @override
  String get insightsMinds => 'Жазбалар';

  @override
  String get insightsActiveDays => 'Белсенді күндер';

  @override
  String get insightsWords => 'Сөздер';

  @override
  String get insightsBrightestDay => 'Ең жарқын күн';

  @override
  String get insightsBrightestWeek => 'Ең жарқын апта';

  @override
  String get insightsBrightestMonth => 'Ең жарқын ай';

  @override
  String get insightsBrightestYear => 'Ең жарқын жыл';

  @override
  String insightsBrightestDetails(String minds, String emotions, String media) {
    return 'жазба: $minds · эмоция: $emotions · медиа: $media';
  }

  @override
  String get insightsEmotionDistribution => 'Эмоциялар';

  @override
  String get insightsEmotionTrend => 'Эмоциялар динамикасы';

  @override
  String get insightsEmotionPairs => 'Бірге кездесетін эмоциялар';

  @override
  String get insightsEmotionRhythm => 'Эмоциялық ырғақ';

  @override
  String get insightsByWeekday => 'Апта күндері бойынша';

  @override
  String get insightsByDayPart => 'Тәулік уақыты бойынша';

  @override
  String get insightsNight => 'Түн';

  @override
  String get insightsMorning => 'Таң';

  @override
  String get insightsAfternoon => 'Күндіз';

  @override
  String get insightsEvening => 'Кеш';

  @override
  String get insightsStreak => 'Серия';

  @override
  String get insightsStreakLabel => 'күн қатарынан';

  @override
  String insightsLongestStreak(String count) {
    return 'Рекорд: $count';
  }

  @override
  String get insightsStreakKeepGoing =>
      'Серияны үзбеу үшін бүгін жазба қосыңыз';

  @override
  String get insightsHeatmap => 'Белсенділік картасы';

  @override
  String get insightsActivityTime => 'Тәулік уақыты';

  @override
  String insightsPeakHour(String hour) {
    return 'Көбіне $hour шамасында';
  }

  @override
  String get insightsOnThisDay => 'Сол кезде';

  @override
  String get insightsMediaCounters => 'Медиа';

  @override
  String get insightsPhotos => 'Фото';

  @override
  String get insightsVideos => 'Бейне';

  @override
  String get insightsVoiceNotes => 'Дауыстық жазбалар';

  @override
  String get insightsRoundVideos => 'Дөңгелек бейнелер';

  @override
  String get insightsEmptyPeriod => 'Бұл кезеңде әзірге жазба жоқ';

  @override
  String get insightsEmptyEmotions =>
      'Мұны көру үшін жазбаларға эмоция белгілеңіз';

  @override
  String get insightsEmptyPairs =>
      'Жұптарды көру үшін жазбаға екі эмоция белгілеңіз';

  @override
  String get insightsEmptyOnThisDay =>
      'Бір апта, ай, жарты жыл және бір жыл бұрын әзірге ештеңе жоқ';

  @override
  String get insightsEmptyRoundVideos =>
      'Бұл кезеңде дауыстық жазбалар мен дөңгелек бейнелер жоқ';

  @override
  String get insightsEmptyStreak => 'Серияны бастау үшін бүгін жазба қосыңыз';

  @override
  String get insightsCustomize => 'Аналитиканы баптау';

  @override
  String get insightsCustomizeDescription =>
      'Карточкаларды қосыңыз не өшіріңіз, ретін сүйреп өзгертіңіз';

  @override
  String get insightsResetLayout => 'Қалпына келтіру';

  @override
  String get activeTasks => 'Белсенді тапсырмалар';

  @override
  String get galleryIndex => 'Галерея индексі';

  @override
  String get galleryIndexNoAccess => 'Фотоға рұқсат жоқ';

  @override
  String get galleryIndexNotIndexed => 'Әлі индекстелмеген';

  @override
  String galleryIndexIndexing(String done, String total) {
    return 'Индекстеу $done / $total';
  }

  @override
  String galleryIndexReady(String count, String time) {
    return '$count фото және бейне · жаңартылды $time';
  }

  @override
  String galleryIndexThumbnails(String size) {
    return 'Миниатюралар кеші: $size';
  }

  @override
  String get galleryIndexRebuildTitle =>
      'Галерея индексін қайта құру керек пе?';

  @override
  String get galleryIndexRebuildMessage =>
      'Миниатюралар өшіріліп, медиатека қайта сканерленеді.';

  @override
  String get galleryIndexRebuild => 'Қайта құру';

  @override
  String get settings => 'Баптаулар';

  @override
  String get userData => 'Пайдаланушы деректері';

  @override
  String get appearance => 'Көрініс';

  @override
  String get interfaceStyle => 'Интерфейс стилі';

  @override
  String get exportToCsv => 'CSV-ға экспорттау';

  @override
  String get exportData => 'Деректерді экспорттау';

  @override
  String get importData => 'Деректерді импорттау';

  @override
  String get done => 'ДАЙЫН';

  @override
  String get chatWithAI => 'AI-мен сөйлесу';

  @override
  String get photosPerDay => 'Күніне суреттер';

  @override
  String get extraActions => 'Қосымша әрекеттер';

  @override
  String get mindOptions => 'Ой нұсқалары';

  @override
  String get edit => 'Өңдеу';

  @override
  String get delete => 'Жою';

  @override
  String get share => 'Бөлісу';

  @override
  String get saveToFiles => 'Файлдарға сақтау';

  @override
  String get switchDay => 'Күнді ауыстыру';

  @override
  String get goToDate => 'Күніне өту';

  @override
  String get showDigest => '... үшін қорытынды көрсету';

  @override
  String get translateToEnglish => 'Ағылшын тіліне аудару';

  @override
  String get convertToStandalone => 'Тәуелсіз ету';

  @override
  String get language => 'Тіл';

  @override
  String get selectLanguage => 'Тілді таңдау';

  @override
  String get theme => 'Тақырып';

  @override
  String get themeLight => 'Ашық';

  @override
  String get themeDark => 'Қараңғы';

  @override
  String get themeSystem => 'Жүйе';

  @override
  String get showDayDividers => 'Күн бөлгіштерін көрсету';

  @override
  String get tabsSettings => 'Таб баптаулары';

  @override
  String get whatsNew => 'Жаңалықтар?';

  @override
  String get releaseNotes => 'Шығарылым жазбалары';

  @override
  String get suggestFeature => 'Функция ұсыну';

  @override
  String get sendFeedback => 'Пікір жіберу';

  @override
  String get emailUs => 'Бізге email жазыңыз';

  @override
  String get clearOfflineDataWarning =>
      'Барлық офлайн деректеріңіз жойылады. Оларды алдын ала экспорттағаныңызға көз жеткізіңіз.';

  @override
  String get sourceCode => 'Дереккөз коды';

  @override
  String get termsOfUse => 'Пайдалану ережелері';

  @override
  String get privacyPolicy => 'Құпиялылық саясаты';

  @override
  String get clearOnDeviceData => 'Құрылғыдағы деректерді тазалау';

  @override
  String get setOpenAIToken => 'Open AI Token орнату';

  @override
  String get cancel => 'Болдырмау';

  @override
  String get save => 'Сақтау';

  @override
  String get mind => 'Ой';

  @override
  String get profile => 'Профиль';

  @override
  String get insights => 'Профиль';

  @override
  String get calendar => 'Күнтізбе';

  @override
  String get debugMenu => 'Debug мәзірі';

  @override
  String get discussion => 'Талқылау';

  @override
  String get about => 'Туралы';

  @override
  String get dangerZone => 'Қауіпті аймақ';

  @override
  String get enterTokenHere => 'Токенді осы жерге енгізіңіз';

  @override
  String get token => 'Токен';

  @override
  String get clearCache => 'Кэшті тазалау';

  @override
  String get activeTabs => 'Белсенді табтар';

  @override
  String get hiddenTabs => 'Жасырын табтар';

  @override
  String get error => 'Қате';

  @override
  String get startDiscussion => 'Талқылауды бастау';

  @override
  String get send => 'ЖІБЕРУ';

  @override
  String get create => 'Жасау';

  @override
  String get yourFolderName => 'Сіздің бума атауыңыз';

  @override
  String get noMindsInSelectedPeriod => 'Таңдалған кезеңде ойлар жоқ';

  @override
  String get noMindsForPeriod => 'Бұл кезең үшін ойлар жоқ';

  @override
  String get selectPeriod => 'Кезеңді таңдау ...';

  @override
  String get digest => 'Қорытынды';

  @override
  String get minds => 'Ойлар';

  @override
  String get searchYourEmoji => 'Эмоджиңізді іздеу...';

  @override
  String get writeSomething => 'Бір нәрсе жазыңыз...';

  @override
  String get todayMinds => 'Бүгінгі ойлар';

  @override
  String get youDidNotCollectAnyEntriesYet =>
      'Сіз әлі ешқандай жазба жинаған жоқсыз';

  @override
  String get areYouSure => 'Сенімдісіз бе?';

  @override
  String get cannotRemoveMainScreen =>
      'Негізгі экранды алып тастауға болмайды. Таб баптауларын жоғалтасыз.';

  @override
  String get today => 'Бүгін';

  @override
  String get yesterday => 'Кеше';

  @override
  String get thisWeek => 'Бұл апта';

  @override
  String get lastTwoWeeks => 'Соңғы 2 апта';

  @override
  String get thisMonth => 'Бұл ай';

  @override
  String get thisYear => 'Бұл жыл';

  @override
  String get calendarDescription => 'Жазбалар күнтізбесімен негізгі экран';

  @override
  String get insightsDescription => 'Сіз және жазбаларыңыздың статистикасы';

  @override
  String get settingsDescription =>
      'Барлық баптаулар экраны (қараңғы режим, синхрондау және т.б.)';

  @override
  String get todayDescription => 'Тек бүгінгі ойлар';

  @override
  String get debugMenuDescription =>
      'Тәжірибелік функцияларды іске қосу үшін әзірлеуші құралдары';

  @override
  String get noMindsForThisDay => 'Бұл күн үшін ойлар жоқ';

  @override
  String get week => 'Апта';

  @override
  String get password => 'Құпия сөз';

  @override
  String get archivePassword => 'Мұрағат құпия сөзі';

  @override
  String get enterPassword => 'Құпия сөзді енгізіңіз';

  @override
  String get confirmPassword => 'Құпия сөзді растаңыз';

  @override
  String get reenterPassword => 'Құпия сөзді қайта енгізіңіз';

  @override
  String get passwordsDoNotMatch => 'Құпия сөздер сәйкес келмейді';

  @override
  String get exportPassword => 'Экспортты құпия сөзбен қорғау керек пе?';

  @override
  String get exportPasswordDescription =>
      'Экспортыңызды шифрлау үшін құпия сөз қосыңыз. Шифрланбаған экспорт үшін мұны өткізіп жіберуге болады.';

  @override
  String get importPassword => 'Құпия сөзді енгізіңіз';

  @override
  String get importPasswordDescription =>
      'Бұл файл құпия сөзбен қорғалған. Шифрды ашу үшін құпия сөзді енгізіңіз.';

  @override
  String get skipPassword => 'Өткізіп жіберу (құпия сөз жоқ)';

  @override
  String get continue_ => 'Жалғастыру';

  @override
  String get incorrectPassword => 'Құпия сөз қате';

  @override
  String get incorrectPasswordMessage =>
      'Сіз енгізген құпия сөз қате. Қайтадан көріңіз.';

  @override
  String get corruptedFile => 'Зақымдалған файл';

  @override
  String get invalidFormat => 'Жарамсыз пішім';

  @override
  String get missingAudioFiles => 'Кейбір аудио файлдар жоқ';

  @override
  String get insufficientStorage => 'Жеткіліксіз қоймалық орын';

  @override
  String get unknownError => 'Белгісіз қате';

  @override
  String get retry => 'Қайтадан көру';

  @override
  String get ok => 'OK';

  @override
  String get exportSuccess => 'Экспорт сәтті';

  @override
  String get exportError => 'Экспорт сәтсіз';

  @override
  String get importSuccess => 'Импорт сәтті';

  @override
  String get importError => 'Импорт сәтсіз';

  @override
  String get mindsToExport => 'Ойлар';

  @override
  String get audioFilesToExport => 'Аудио файлдар';

  @override
  String get emotionsToExport => 'Эмоциялар';

  @override
  String get mindsExported => 'Ойлар экспортталды';

  @override
  String get audioFilesExported => 'Аудио файлдар экспортталды';

  @override
  String get mindsImported => 'Ойлар импортталды';

  @override
  String get audioFilesImported => 'Аудио файлдар импортталды';

  @override
  String get onboardingMind1 => 'Сәлем!';

  @override
  String get onboardingMind2 =>
      'Мен keklist - қысқа жазбалардың жеке күнделігімін';

  @override
  String get onboardingMind2Comment1 => 'Жазбаларға түсініктеме қосуға болады';

  @override
  String get onboardingMind2Comment2 => 'Жазбаны ашу үшін оны түртіңіз';

  @override
  String get onboardingMind3 =>
      '\'Күнтізбе\' қойындысында барлық жазбалар күндер, апталар және айлар бойынша көрсетіледі';

  @override
  String get onboardingMind4 =>
      '\'Аналитика\' қойындысы жазбаларыңыздың қысқаша статистикасын көрсетеді';

  @override
  String get onboardingMind5 => 'Барлық жазбалар тек телефоныңызда сақталады';

  @override
  String get onboardingMind6 =>
      'Жаңа жазба жасау үшін \'Жазу\' түймесін басыңыз';

  @override
  String get noPhotosForDay => 'Бұл күнге фотосуреттер табылмады';

  @override
  String get sourcesMediaFolder => 'Медиа файлдар';

  @override
  String get sourcesMediaFolderSubtitle => 'Таңдалған бумадан фото мен бейне';

  @override
  String get mediaFolderSettings => 'Медиа файлдар';

  @override
  String get licenses => 'Лицензиялар';

  @override
  String get sourcesWeather => 'Ауа райы';

  @override
  String get sourcesWeatherSubtitle =>
      'Бұл күнгі жергілікті ауа райы жағдайлары';

  @override
  String get weatherSettings => 'Ауа райы параметрлері';

  @override
  String get weatherLatitude => 'Ендік';

  @override
  String get weatherLongitude => 'Бойлық';

  @override
  String get weatherSaveLocation => 'Орынды сақтау';

  @override
  String get weatherUseMyLocation => 'Менің орнымды пайдалану';

  @override
  String get weatherDetectingLocation => 'Орын анықталуда...';

  @override
  String get weatherOrEnterManually => 'немесе қолмен енгізу';

  @override
  String get weatherLocationError =>
      'Орынды анықтау мүмкін болмады. Қолмен енгізіңіз.';

  @override
  String get weatherLocationServicesDisabled =>
      'Геолокация қызметтері өшірілген. Параметрлерде қосыңыз.';

  @override
  String get weatherLocationPermissionDenied =>
      'Геолокацияға рұқсат берілмеді.';

  @override
  String get weatherLocationPermissionPermanentlyDenied =>
      'Геолокацияға рұқсат тұрақты түрде берілмеді. Қолданба параметрлері ашылуда.';

  @override
  String get audioRecordTitle => 'Аудио жазу';

  @override
  String get audioRecordTitleRecording => 'Жазылуда…';

  @override
  String get audioRecordHint => 'Сақтау үшін «Тоқтату» батырмасын басыңыз.';

  @override
  String get audioRecordStart => 'Бастау';

  @override
  String get audioRecordStop => 'Тоқтату';

  @override
  String get audioRecordCancel => 'Болдырмау';

  @override
  String get audioRecordPermissionError =>
      'Аудио жазу үшін микрофон рұқсаты қажет.';

  @override
  String get audioRecordStartError =>
      'Жазуды бастау мүмкін болмады. Қайталап көріңіз.';

  @override
  String get audioRecordStopError =>
      'Жазуды тоқтату мүмкін болмады. Қайталап көріңіз.';

  @override
  String proUserFooter(String price, String date) {
    return 'Сіз PRO қолданушысысыз. Келесі $price төлем $date күні болады.';
  }

  @override
  String get emotions => 'Эмоциялар';

  @override
  String get archived => 'Мұрағат';

  @override
  String get archive => 'Мұрағаттау';

  @override
  String get restore => 'Қалпына келтіру';

  @override
  String get deletePermanently => 'Біржола жою';

  @override
  String get newEmotion => 'Жаңа эмоция';

  @override
  String get editEmotion => 'Эмоцияны өңдеу';

  @override
  String get addEmotion => 'Эмоция қосу';

  @override
  String get addEmotionsToMind => 'Эмоциялар қосу';

  @override
  String get emotionNameHint => 'Атауы';

  @override
  String get doneEditing => 'Дайын';

  @override
  String get emotionEditHint =>
      'Атын өзгерту үшін түртіңіз · ✕ жою үшін · реттеу үшін сүйреңіз';

  @override
  String get emotionInUseMessage =>
      'Бұл эмоция кейбір майндтарда қолданылады. Оны сонда сақтау үшін мұрағаттаңыз немесе барлық жерден жойыңыз.';

  @override
  String get noEmotionsYet => 'Әзірге эмоциялар жоқ';

  @override
  String get noArchivedEmotions => 'Мұрағатталған эмоциялар жоқ';

  @override
  String get deleteEmotionMessage =>
      'Бұл эмоцияны жою керек пе? Ол оны пайдаланатын барлық майндтардан жойылады.';

  @override
  String get dayFeedTileSettings => 'Тақта баптаулары';

  @override
  String get dayFeedColumns => 'Бағандар';

  @override
  String get dayFeedMindTileSize => 'Тақта өлшемі';

  @override
  String get dayFeedMindTileSquare => 'Шаршы';

  @override
  String get dayFeedMindTileWide => 'Кең';

  @override
  String get dayFeedShowMindText => 'Мәтінді көрсету';

  @override
  String get dayFeedPhotoAccessHint =>
      'Мұнда фото мен видеоны көру үшін фотоға рұқсат беріңіз';

  @override
  String get dayFeedAllowAccess => 'Рұқсат ету';

  @override
  String get dayFeedFolderHint =>
      'Мұнда фото мен видеоны көру үшін медиа қалтасын таңдаңыз';

  @override
  String get dayFeedChooseFolder => 'Таңдау';

  @override
  String get holdToRecordAudio => 'Дауыстық хабар жазу үшін басып тұрыңыз';

  @override
  String get holdToRecordVideo => 'Бейнехабар жазу үшін басып тұрыңыз';

  @override
  String get roundVideoRecordError => 'Бейнені жазу мүмкін болмады';

  @override
  String get roundVideoCameraUnavailable => 'Бұл құрылғыда камера қолжетімсіз';

  @override
  String get roundVideoRetake => 'Қайта түсіру';

  @override
  String get roundVideoUse => 'Пайдалану';

  @override
  String get removeMedia => 'Медианы жою';

  @override
  String get shakeToCustomize => 'Баптау үшін сілкіңіз';

  @override
  String get shakeToCustomizeHint => 'немесе тақырыпты басып тұрыңыз';

  @override
  String get customizeSettings => 'Баптауларды реттеу';

  @override
  String get customizeSettingsDescription =>
      'Белгісі алынған бөлімдер мен жолдар баптаулар экранында жасырылады.';

  @override
  String get calendarSettings => 'Күнтізбе баптаулары';

  @override
  String get calendarShowMedia => 'Фото мен бейнені көрсету';

  @override
  String get calendarWeekTitles => 'Апта тақырыптары';

  @override
  String get calendarPlayStories => 'Тарихтарды көру';

  @override
  String get storyBackgroundTweak => 'Оқиғалар фоны';

  @override
  String get storyAnimationOff => 'Өшірулі';

  @override
  String get storyAnimationPulse => 'Пульс';

  @override
  String get storyAnimationWave => 'Толқын';

  @override
  String get storyAnimationEqualizer => 'Эквалайзер';

  @override
  String get storyAnimationDrift => 'Дрейф';

  @override
  String get storyAnimationGlow => 'Жарқыл';

  @override
  String get viewerCommentHint => 'Пікір…';

  @override
  String get calendarToCurrentWeek => 'Ағымдағы аптаға';

  @override
  String get storyDateLines => 'Күн жолдары';

  @override
  String get storyTextureTitle => 'Текстура';

  @override
  String get storySpectrum => 'Дыбыс спектрі';

  @override
  String get storySensitivity => 'Сезімталдық';

  @override
  String profileMindfulDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Саналы $count күн',
    );
    return '$_temp0';
  }

  @override
  String get profileName => 'Аты';

  @override
  String get profilePhoto => 'Фото';

  @override
  String get profileEmoji => 'Эмодзи';

  @override
  String get profileInitial => 'Әріп';

  @override
  String get webVersion => 'Веб-нұсқа';

  @override
  String get webVersionAddressHint =>
      'Сол Wi‑Fi желісіндегі компьютер браузерінде ашыңыз; keklist ашық тұруы керек';

  @override
  String get webVersionCopied => 'Мекенжай көшірілді';

  @override
  String get webVersionNeedsPin =>
      'keklist-ті сол Wi‑Fi желісіндегі компьютер браузерінде ашу үшін PIN орнатыңыз.';

  @override
  String get webVersionStarting => 'Іске қосылуда…';

  @override
  String get webVersionNoWifi =>
      'keklist-ті браузерде ашу үшін Wi‑Fi-ға қосылыңыз.';

  @override
  String get webVersionNoBundle => 'Бұл құрастыруда веб-нұсқа жоқ.';

  @override
  String get webVersionPin => 'PIN';

  @override
  String get webVersionPinSet => 'Әр браузер оны 30 күнде бір рет сұрайды';

  @override
  String get webVersionPinNotSet => 'Орнатылмаған';

  @override
  String get webVersionPinHint => '4–8 сан';

  @override
  String get webVersionRemovePin => 'PIN-ді жою';

  @override
  String get webVersionPort => 'Порт';

  @override
  String get aiTab => 'Чат';

  @override
  String get aiTabDescription =>
      'Жазбаларыңызды телефонда жұмыс істейтін AI-мен талқылаңыз';

  @override
  String get aiPrivacyNote =>
      'Тек телефонда жұмыс істейді: жазбалар құрылғыдан шықпайды.';

  @override
  String get aiDisclaimer =>
      'Бұл медициналық қызмет емес. Қауіп төнсе, шұғыл қызметтерге хабарласыңыз.';

  @override
  String get aiYesterday => 'Кеше';

  @override
  String get aiNoSessions => 'Әзірге сессия жоқ';

  @override
  String get aiNewSession => 'Жаңа сессия';

  @override
  String get aiChooseRole => 'Рөлді таңдаңыз';

  @override
  String get aiRoleTherapist => 'Терапевт';

  @override
  String get aiRoleCoach => 'Коуч';

  @override
  String get aiRoleFriend => 'Дос';

  @override
  String get aiMessageHint => 'Хабарлама';

  @override
  String get aiStarterWeek => 'Аптам қалай өтті?';

  @override
  String get aiStarterWorry => 'Соңғы кезде мені не мазалайды?';

  @override
  String get aiStarterJoy => 'Соңғы кезде мені не қуантты?';

  @override
  String get aiActionSaveAsMind => 'Майнд ретінде сақтау';

  @override
  String get aiActionOpenDay => 'Күнді ашу';

  @override
  String get aiActionWeekSummary => 'Апта қорытындысы';

  @override
  String get aiWeekSummaryPrompt =>
      'Соңғы 7 күнімді қорытындыла: не болды, не сезіндім, не ерекше болды.';

  @override
  String get aiSavedAsMind => 'Бүгінге сақталды';

  @override
  String get aiStop => 'Тоқтату';

  @override
  String get aiNoModelTitle => 'Модельді таңдаңыз';

  @override
  String get aiNoModelMessage =>
      'Бастау үшін модельді жүктеп алыңыз. Ол телефонда, интернетсіз жұмыс істейді.';

  @override
  String get aiNoModelOnPhone =>
      'Модельді телефондағы қолданбада жүктеңіз: Баптаулар → AI → Модельдер.';

  @override
  String get aiModels => 'Модельдер';

  @override
  String get aiRoles => 'Рөлдер';

  @override
  String get aiDownloaded => 'Жүктелгендер';

  @override
  String get aiDownloads => 'Жүктелуде';

  @override
  String get aiGalleryCatalog => 'Google AI Edge Gallery';

  @override
  String get aiHuggingFace => 'Hugging Face (GGUF)';

  @override
  String get aiSearchModels => 'GGUF модельдерін іздеу';

  @override
  String get aiDownload => 'Жүктеу';

  @override
  String get aiPause => 'Кідірту';

  @override
  String get aiPaused => 'Кідіртілді';

  @override
  String get aiResume => 'Жалғастыру';

  @override
  String get aiDownloadFailed => 'Жүктеу сәтсіз аяқталды';

  @override
  String get aiCellularTitle => 'Мобильді интернет арқылы жүктеу керек пе?';

  @override
  String aiCellularMessage(String size) {
    return '$size мобильді интернет арқылы жүктеледі.';
  }

  @override
  String get aiDeleteModel => 'Модельді жою керек пе?';

  @override
  String aiStorageUsed(String size) {
    return 'Бұл телефонда: $size';
  }

  @override
  String aiDeviceMemory(String size) {
    return 'Телефон жады: $size';
  }

  @override
  String get aiCatalogFailed =>
      'Тізімді жүктеу мүмкін болмады. Байланысты тексеріңіз.';

  @override
  String get aiNoFilesFit =>
      'Бұл модельдің бірде-бір файлы телефон жадына сыймайды.';

  @override
  String get aiBuiltInRole => 'Кіріктірілген';

  @override
  String get aiOwnRoles => 'Сіздің рөлдеріңіз';

  @override
  String get aiDuplicate => 'Көшірме жасау';

  @override
  String get aiNewRole => 'Жаңа рөл';

  @override
  String get aiRoleName => 'Атауы';

  @override
  String get aiRoleEmoji => 'Эмодзи';

  @override
  String get aiRolePrompt => 'Промпт';

  @override
  String get aiRolePromptHint =>
      'AI қалай сөйлеуі және неге назар аударуы керек';

  @override
  String get aiReadOnlyRole =>
      'Кіріктірілген рөлдерді өзгертуге болмайды. Өз рөліңізді жасау үшін көшірмесін жасаңыз.';

  @override
  String get aiDeleteSession => 'Сессияны жою керек пе?';

  @override
  String get aiDeleteRole => 'Рөлді жою керек пе?';

  @override
  String get aiRecommended => 'Ұсынылады';

  @override
  String get aiLowQuality => 'Сапасы төмен';

  @override
  String get aiModelDoesNotFit =>
      'Бұл модель телефон жадына сыймайды. Кішірек модельді таңдаңыз.';

  @override
  String get aiChooseAnotherModel => 'Басқа модель таңдау';

  @override
  String get creatorEmotionsTitle => 'Эмоциялар';

  @override
  String get creatorEmotionsAfterSave => 'Сақтағаннан кейін сұрау';

  @override
  String get creatorEmotionsButton => 'Пернетақта үстіндегі түйме';

  @override
  String get creatorEmotionsNever => 'Сұрамау';

  @override
  String get insightsWeekAgo => 'Бір апта бұрын';

  @override
  String get insightsMonthAgo => 'Бір ай бұрын';

  @override
  String get insightsHalfYearAgo => 'Жарты жыл бұрын';

  @override
  String get insightsYearAgo => 'Бір жыл бұрын';

  @override
  String get insightsTwoYearsAgo => 'Екі жыл бұрын';

  @override
  String get insightsVoiceAndVideos => 'Дауыс және дөңгелек бейнелер';

  @override
  String insightsWeekNumber(String number) {
    return '$number-апта';
  }

  @override
  String get aiNoSessionsHint =>
      'Аптаңыз, мазасыздық не жақсы күн туралы сұраңыз: чат жазбаларыңызды телефонның өзінде оқиды.';

  @override
  String get showInGallery => 'Галереяда көрсету';

  @override
  String get tileEmojiMotion => 'Эмодзи қозғалысы';

  @override
  String get tileEmojiMotionDrift => 'Дрейф';

  @override
  String get tileEmojiMotionFloat => 'Тербелу';

  @override
  String get tileEmojiMotionStill => 'Қозғалыссыз';

  @override
  String get gridResizeAnimation => 'Шымшу анимациясы';

  @override
  String get gridResizeFly => 'Ұшу';

  @override
  String get gridResizeZoom => 'Зум';

  @override
  String get gridResizeCrossfade => 'Еру';

  @override
  String get feedSortOrder => 'Реті';

  @override
  String get feedSortTime => 'Уақыт';

  @override
  String get feedSortMindsFirst => 'Алдымен жазбалар';

  @override
  String get feedSortMediaFirst => 'Алдымен медиа';

  @override
  String get feedGrouping => 'Топтар';

  @override
  String get feedGroupingNone => 'Жоқ';

  @override
  String get feedGroupingType => 'Түрі';

  @override
  String get feedGroupingTimeOfDay => 'Тәулік';

  @override
  String get feedSectionMinds => 'Жазбалар';

  @override
  String get feedSectionGallery => 'Галерея';

  @override
  String get removePhotoTitle => 'Фотоны алып тастау';

  @override
  String get removeVideoTitle => 'Бейнені алып тастау';

  @override
  String get hideMedia => 'Жасыру';

  @override
  String get hideMediaSubtitle => 'Тек keklist-тен, галереяда қалады';

  @override
  String get deleteFromGallery => 'Галереядан жою';

  @override
  String get deleteFromGallerySubtitle => '«Жақында жойылғандарға» түседі';

  @override
  String get mediaHidden => 'keklist-тен жасырылды';

  @override
  String get mediaShownAgain => 'Қайта keklist-те';

  @override
  String get undo => 'Болдырмау';

  @override
  String get hiddenMedia => 'Жасырын фотолар';

  @override
  String get hiddenMediaHint => 'Фотоны keklist-ке қайтару үшін басыңыз';

  @override
  String get hiddenMediaEmpty => 'Ештеңе жасырылмаған';
}
