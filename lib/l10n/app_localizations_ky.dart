// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kirghiz Kyrgyz (`ky`).
class AppLocalizationsKy extends AppLocalizations {
  AppLocalizationsKy([String locale = 'ky']) : super(locale);

  @override
  String get insightsBrightestPeriod => 'Эң жаркын мезгил';

  @override
  String get insightsPeriodWeek => 'Апта';

  @override
  String get insightsPeriodMonth => 'Ай';

  @override
  String get insightsPeriodYear => 'Жыл';

  @override
  String get insightsPeriodAllTime => 'Бардык убакыт';

  @override
  String insightsVsLastWeek(String delta) {
    return 'Өткөн жумага салыштырмалуу $delta';
  }

  @override
  String insightsVsLastMonth(String delta) {
    return 'Өткөн айга салыштырмалуу $delta';
  }

  @override
  String insightsVsLastYear(String delta) {
    return 'Өткөн жылга салыштырмалуу $delta';
  }

  @override
  String get insightsCategorySummary => 'Сереп';

  @override
  String get insightsCategoryEmotions => 'Эмоциялар';

  @override
  String get insightsCategoryActivity => 'Активдүүлүк';

  @override
  String get insightsCategoryMemories => 'Эскерүүлөр';

  @override
  String get insightsCategoryMedia => 'Медиа';

  @override
  String get insightsCounters => 'Сандар менен';

  @override
  String get insightsMinds => 'Жазуулар';

  @override
  String get insightsActiveDays => 'Активдүү күндөр';

  @override
  String get insightsWords => 'Сөздөр';

  @override
  String get insightsBrightestDay => 'Эң жаркын күн';

  @override
  String get insightsBrightestWeek => 'Эң жаркын жума';

  @override
  String get insightsBrightestMonth => 'Эң жаркын ай';

  @override
  String get insightsBrightestYear => 'Эң жаркын жыл';

  @override
  String insightsBrightestDetails(String minds, String emotions, String media) {
    return 'жазуу: $minds · эмоция: $emotions · медиа: $media';
  }

  @override
  String get insightsEmotionDistribution => 'Эмоциялар';

  @override
  String get insightsEmotionTrend => 'Эмоциялардын динамикасы';

  @override
  String get insightsEmotionPairs => 'Бирге кездешкен эмоциялар';

  @override
  String get insightsEmotionRhythm => 'Эмоционалдык ритм';

  @override
  String get insightsByWeekday => 'Жуманын күндөрү боюнча';

  @override
  String get insightsByDayPart => 'Суткалык убакыт боюнча';

  @override
  String get insightsNight => 'Түн';

  @override
  String get insightsMorning => 'Эртең менен';

  @override
  String get insightsAfternoon => 'Күндүз';

  @override
  String get insightsEvening => 'Кечинде';

  @override
  String get insightsStreak => 'Серия';

  @override
  String get insightsStreakLabel => 'күн катары менен';

  @override
  String insightsLongestStreak(String count) {
    return 'Рекорд: $count';
  }

  @override
  String get insightsStreakKeepGoing =>
      'Серияны үзбөө үчүн бүгүн жазуу кошуңуз';

  @override
  String get insightsHeatmap => 'Активдүүлүк картасы';

  @override
  String get insightsActivityTime => 'Суткалык убакыт';

  @override
  String insightsPeakHour(String hour) {
    return 'Көбүнчө $hour чамасында';
  }

  @override
  String get insightsOnThisDay => 'Ошол кезде';

  @override
  String get insightsMediaCounters => 'Медиа';

  @override
  String get insightsPhotos => 'Сүрөттөр';

  @override
  String get insightsVideos => 'Видеолор';

  @override
  String get insightsVoiceNotes => 'Үн жазуулары';

  @override
  String get insightsRoundVideos => 'Тегерек видеолор';

  @override
  String get insightsEmptyPeriod => 'Бул мезгилде азырынча жазуу жок';

  @override
  String get insightsEmptyEmotions =>
      'Муну көрүү үчүн жазууларга эмоция белгилеңиз';

  @override
  String get insightsEmptyPairs =>
      'Жуптарды көрүү үчүн жазууга эки эмоция белгилеңиз';

  @override
  String get insightsEmptyOnThisDay =>
      'Бир жума, ай, жарым жыл жана бир жыл мурун азырынча эч нерсе жок';

  @override
  String get insightsEmptyRoundVideos =>
      'Бул мезгилде үн жазуулар жана тегерек видеолор жок';

  @override
  String get insightsEmptyStreak => 'Серияны баштоо үчүн бүгүн жазуу кошуңуз';

  @override
  String get insightsCustomize => 'Аналитиканы ыңгайлаштыруу';

  @override
  String get insightsCustomizeDescription =>
      'Карточкаларды күйгүзүп же өчүрүп, тартып тартибин өзгөртүңүз';

  @override
  String get insightsResetLayout => 'Баштапкы абалга';

  @override
  String get activeTasks => 'Активдүү тапшырмалар';

  @override
  String get galleryIndex => 'Галерея индекси';

  @override
  String get galleryIndexNoAccess => 'Сүрөттөргө уруксат жок';

  @override
  String get galleryIndexNotIndexed => 'Азырынча индекстелген жок';

  @override
  String galleryIndexIndexing(String done, String total) {
    return 'Индекстөө $done / $total';
  }

  @override
  String galleryIndexReady(String count, String time) {
    return '$count сүрөт жана видео · жаңыртылды $time';
  }

  @override
  String galleryIndexThumbnails(String size) {
    return 'Миниатюралар кеши: $size';
  }

  @override
  String get galleryIndexRebuildTitle => 'Галерея индексин кайра түзөбүзбү?';

  @override
  String get galleryIndexRebuildMessage =>
      'Миниатюралар өчүрүлүп, медиатека кайра текшерилет.';

  @override
  String get galleryIndexRebuild => 'Кайра түзүү';

  @override
  String get settings => 'Сөздүктөр';

  @override
  String get userData => 'Колдонуучу маалыматтары';

  @override
  String get appearance => 'Көрүнүш';

  @override
  String get interfaceStyle => 'Интерфейс стили';

  @override
  String get exportToCsv => 'CSVга экспорттоо';

  @override
  String get exportData => 'Маалыматтарды экспорттоо';

  @override
  String get importData => 'Маалыматтарды импорттоо';

  @override
  String get done => 'ДАЙЫН';

  @override
  String get chatWithAI => 'AI менен сүйлөшүү';

  @override
  String get photosPerDay => 'Күнүнө сүрөттөр';

  @override
  String get extraActions => 'Кошумча аракеттер';

  @override
  String get mindOptions => 'Ой варианттары';

  @override
  String get edit => 'Түзөтүү';

  @override
  String get delete => 'Өчүрүү';

  @override
  String get share => 'Бөлүшүү';

  @override
  String get saveToFiles => 'Файлдарга сактоо';

  @override
  String get switchDay => 'Күндү алмаштыруу';

  @override
  String get goToDate => 'Дата аркылуу өтүү';

  @override
  String get showDigest => '... үчүн жыйынтык көрсөтүү';

  @override
  String get translateToEnglish => 'Англис тилине которуу';

  @override
  String get convertToStandalone => 'Өз алдынча кылуу';

  @override
  String get language => 'Тил';

  @override
  String get selectLanguage => 'Тилди тандоо';

  @override
  String get theme => 'Тема';

  @override
  String get themeLight => 'Жарык';

  @override
  String get themeDark => 'Кара';

  @override
  String get themeSystem => 'Система';

  @override
  String get showDayDividers => 'Күн бөлгүчүлөрдү көрсөтүү';

  @override
  String get tabsSettings => 'Таб жөндөөлөрү';

  @override
  String get whatsNew => 'Жаңы нерселер?';

  @override
  String get releaseNotes => 'Релиз жазмалары';

  @override
  String get suggestFeature => 'Өзгөчөлүктү сунуш кылуу';

  @override
  String get sendFeedback => 'Пикир-божомол жөнөтүү';

  @override
  String get emailUs => 'Бизге email жазыңыз';

  @override
  String get clearOfflineDataWarning =>
      'Бардык оффлайн маалыматтарың өчүрүлөт. Аларды мурун экспорттогонуңа ынан.';

  @override
  String get sourceCode => 'Булак коду';

  @override
  String get termsOfUse => 'Колдонуу эрежелери';

  @override
  String get privacyPolicy => 'Купуялык саясаты';

  @override
  String get clearOnDeviceData => 'Түзүлүштөгү маалыматтарды тазалоо';

  @override
  String get setOpenAIToken => 'Open AI Token орнотуу';

  @override
  String get cancel => 'Жокко чыгаруу';

  @override
  String get save => 'Сактоо';

  @override
  String get mind => 'Ой';

  @override
  String get profile => 'Профиль';

  @override
  String get insights => 'Талдоо';

  @override
  String get calendar => 'Календарь';

  @override
  String get debugMenu => 'Debug менюсу';

  @override
  String get discussion => 'Талкуулоо';

  @override
  String get about => 'Жөнүндө';

  @override
  String get dangerZone => 'Кооптуу зона';

  @override
  String get enterTokenHere => 'Токенди бул жерге киргизиңиз';

  @override
  String get token => 'Токен';

  @override
  String get clearCache => 'Кэшти тазалоо';

  @override
  String get activeTabs => 'Актив табтар';

  @override
  String get hiddenTabs => 'Жашырын табтар';

  @override
  String get error => 'Ката';

  @override
  String get startDiscussion => 'Талкуулоону баштоо';

  @override
  String get send => 'ЖӨНӨТҮҮ';

  @override
  String get create => 'Түзүү';

  @override
  String get yourFolderName => 'Сиздин папка атыңыз';

  @override
  String get noMindsInSelectedPeriod => 'Тандалган мезгилде ойлор жок';

  @override
  String get noMindsForPeriod => 'Бул мезгил үчүн ойлор жок';

  @override
  String get selectPeriod => 'Мезгилди тандоо ...';

  @override
  String get digest => 'Жыйынтык';

  @override
  String get minds => 'Ойлор';

  @override
  String get searchForYourNotes => 'Эскертмелериңизди издөө';

  @override
  String get searchYourEmoji => 'Эмоджиңизди издөө...';

  @override
  String get writeSomething => 'Бир нерсе жазыңыз...';

  @override
  String get todayMinds => 'Бүгүнкү ойлор';

  @override
  String get youDidNotCollectAnyEntriesYet =>
      'Сиз али эч кандай жазма чогулткан жоксуз';

  @override
  String get areYouSure => 'Ишенимиңиз келип турабы?';

  @override
  String get cannotRemoveMainScreen =>
      'Негизги экранды алып салса болбойт. Таб жөндөөлөрүн жоготуусуз.';

  @override
  String get today => 'Бүгүн';

  @override
  String get yesterday => 'Кечээ';

  @override
  String get thisWeek => 'Бул жума';

  @override
  String get lastTwoWeeks => 'Акыркы 2 жума';

  @override
  String get thisMonth => 'Бул ай';

  @override
  String get thisYear => 'Бул жыл';

  @override
  String get calendarDescription => 'Жазмалар календары менен негизги экран';

  @override
  String get insightsDescription => 'Бардык жазмаларыңыздын статистикасы';

  @override
  String get settingsDescription =>
      'Бардык жөндөөлөр экраны (караңгы режим, синхрондоштуруу жана башкалар)';

  @override
  String get todayDescription => 'Анткени бүгүнкү ойлор';

  @override
  String get debugMenuDescription =>
      'Эксперименталдык өзгөчөлүктөрдү иштетүү үчүн өнүктүрүүчү куралдары';

  @override
  String get noMindsForThisDay => 'Бул күн үчүн ойлор жок';

  @override
  String get week => 'Жума';

  @override
  String get password => 'Сырсөз';

  @override
  String get archivePassword => 'Архив сырсөзү';

  @override
  String get enterPassword => 'Сырсөздү киргизиңиз';

  @override
  String get confirmPassword => 'Сырсөздү ырастаңыз';

  @override
  String get reenterPassword => 'Сырсөздү кайра киргизиңиз';

  @override
  String get passwordsDoNotMatch => 'Сырсөздөр дал келбейт';

  @override
  String get exportPassword => 'Экспортту сырсөз менен коргоого алуу керекпи?';

  @override
  String get exportPasswordDescription =>
      'Экспортуңузду шифрлөө үчүн сырсөз кошуңуз. Шифрлөөсүз экспорт үчүн бул өткөрүп жиберсе болот.';

  @override
  String get importPassword => 'Сырсөздү киргизиңиз';

  @override
  String get importPasswordDescription =>
      'Бул файл сырсөз менен корголгон. Шифрди ачуу үчүн сырсөздү киргизиңиз.';

  @override
  String get skipPassword => 'Өткөрүп жиберүү (сырсөзсүз)';

  @override
  String get continue_ => 'Улантуу';

  @override
  String get incorrectPassword => 'Сырсөз туура эмес';

  @override
  String get incorrectPasswordMessage =>
      'Сиз киргизген сырсөз туура эмес. Кайра аракет кылыңыз.';

  @override
  String get corruptedFile => 'Бузулган файл';

  @override
  String get invalidFormat => 'Жараксыз формат';

  @override
  String get missingAudioFiles => 'Кээ бир аудио файлдар жок';

  @override
  String get insufficientStorage => 'Жетишсиз сактоо орду';

  @override
  String get unknownError => 'Белгисиз ката';

  @override
  String get retry => 'Кайра аракет кылуу';

  @override
  String get ok => 'OK';

  @override
  String get exportSuccess => 'Экспорт ийгиликтүү';

  @override
  String get exportError => 'Экспорт ийгиликсиз';

  @override
  String get importSuccess => 'Импорт ийгиликтүү';

  @override
  String get importError => 'Импорт ийгиликсиз';

  @override
  String get mindsToExport => 'Ойлор';

  @override
  String get audioFilesToExport => 'Аудио файлдар';

  @override
  String get emotionsToExport => 'Эмоциялар';

  @override
  String get mindsExported => 'Ойлор экспортталды';

  @override
  String get audioFilesExported => 'Аудио файлдар экспортталды';

  @override
  String get mindsImported => 'Ойлор импортталды';

  @override
  String get audioFilesImported => 'Аудио файлдар импортталды';

  @override
  String get onboardingMind1 => 'Салам!';

  @override
  String get onboardingMind2 =>
      'Мен keklist - кыска жазуулардын жеке күндөлүгүмүн';

  @override
  String get onboardingMind2Comment1 => 'Жазууларга комментарий жазса болот';

  @override
  String get onboardingMind2Comment2 => 'Жазууну ачуу үчүн аны басыңыз';

  @override
  String get onboardingMind3 =>
      '\'Жылнаама\' өтмөгүндө бардык жазуулар күндөр, жумалар жана айлар боюнча көрсөтүлөт';

  @override
  String get onboardingMind4 =>
      '\'Аналитика\' өтмөгү жазууларыңыздын кыскача статистикасын көрсөтөт';

  @override
  String get onboardingMind5 => 'Бардык жазуулар телефонуңузда гана сакталат';

  @override
  String get onboardingMind6 =>
      'Жаңы жазуу жасоо үчүн \'Жазуу\' баскычын басыңыз';

  @override
  String get noPhotosForDay => 'Бул күндө сүрөттөр табылган жок';

  @override
  String get sourcesMediaFolder => 'Медиа файлдар';

  @override
  String get sourcesMediaFolderSubtitle =>
      'Тандалган папкадан сүрөттөр жана видеолор';

  @override
  String get mediaFolderSettings => 'Медиа файлдар';

  @override
  String get licenses => 'Лицензиялар';

  @override
  String get sourcesWeather => 'Аба ырайы';

  @override
  String get sourcesWeatherSubtitle =>
      'Бул күн үчүн жергиликтүү аба ырайы шарттары';

  @override
  String get weatherSettings => 'Аба ырайы жөндөөлөрү';

  @override
  String get weatherLatitude => 'Кеңдик';

  @override
  String get weatherLongitude => 'Узундук';

  @override
  String get weatherSaveLocation => 'Жерди сактоо';

  @override
  String get weatherUseMyLocation => 'Менин жеримди колдонуу';

  @override
  String get weatherDetectingLocation => 'Жер аныкталууда...';

  @override
  String get weatherOrEnterManually => 'же кол менен киргизүү';

  @override
  String get weatherLocationError =>
      'Жерди аныктоо мүмкүн болмоду. Кол менен киргизиңиз.';

  @override
  String get weatherLocationServicesDisabled =>
      'Геолокация кызматтары өчүрүлгөн. Жөндөөлөрдө иштетиңиз.';

  @override
  String get weatherLocationPermissionDenied =>
      'Геолокацияга уруксат берилген жок.';

  @override
  String get weatherLocationPermissionPermanentlyDenied =>
      'Геолокацияга уруксат туруктуу берилген жок. Колдонмо жөндөөлөрү ачылууда.';

  @override
  String get audioRecordTitle => 'Аудио жаздыруу';

  @override
  String get audioRecordTitleRecording => 'Жазылууда…';

  @override
  String get audioRecordHint => 'Сактоо үчүн «Токтотуу» баскычын басыңыз.';

  @override
  String get audioRecordStart => 'Баштоо';

  @override
  String get audioRecordStop => 'Токтотуу';

  @override
  String get audioRecordCancel => 'Жокко чыгаруу';

  @override
  String get audioRecordPermissionError =>
      'Аудио жаздыруу үчүн микрофон уруксаты керек.';

  @override
  String get audioRecordStartError =>
      'Жаздырууну баштоо мүмкүн болмоду. Кайталап аракет кылыңыз.';

  @override
  String get audioRecordStopError =>
      'Жаздырууну токтотуу мүмкүн болмоду. Кайталап аракет кылыңыз.';

  @override
  String proUserFooter(String price, String date) {
    return 'Сиз PRO колдонуучусуз. Кийинки $price төлөм $date болот.';
  }

  @override
  String get emotions => 'Эмоциялар';

  @override
  String get archived => 'Архив';

  @override
  String get archive => 'Архивдөө';

  @override
  String get restore => 'Калыбына келтирүү';

  @override
  String get deletePermanently => 'Биротоло өчүрүү';

  @override
  String get newEmotion => 'Жаңы эмоция';

  @override
  String get editEmotion => 'Эмоцияны түзөтүү';

  @override
  String get addEmotion => 'Эмоция кошуу';

  @override
  String get addEmotionsToMind => 'Эмоция кошуу';

  @override
  String get emotionNameHint => 'Аталышы';

  @override
  String get doneEditing => 'Даяр';

  @override
  String get emotionEditHint =>
      'Атын өзгөртүү үчүн басыңыз · ✕ өчүрүү үчүн · иреттөө үчүн сүйрөңүз';

  @override
  String get emotionInUseMessage =>
      'Бул эмоция кээ бир майндтарда колдонулат. Аны ошол жерде сактоо үчүн архивдеңиз же бардык жерден өчүрүңүз.';

  @override
  String get emotionPickHint => 'Белгилөө үчүн басыңыз';

  @override
  String get emotionDrillHint => 'тереңдөө үчүн кармап туруңуз';

  @override
  String get noEmotionsYet => 'Азырынча эмоциялар жок';

  @override
  String get noArchivedEmotions => 'Архивделген эмоциялар жок';

  @override
  String get deleteEmotionMessage =>
      'Бул эмоцияны өчүрөсүзбү? Ал аны колдонгон бардык майндтардан өчүрүлөт.';

  @override
  String get dayFeedTileSettings => 'Плитка жөндөөлөрү';

  @override
  String get dayFeedColumns => 'Мамычалар';

  @override
  String get dayFeedMindTileSize => 'Плитканын өлчөмү';

  @override
  String get dayFeedMindTileSquare => 'Чарчы';

  @override
  String get dayFeedMindTileWide => 'Кең';

  @override
  String get dayFeedShowMindText => 'Текстти көрсөтүү';

  @override
  String get dayFeedPhotoAccessHint =>
      'Бул жерде сүрөт жана видеолорду көрүү үчүн сүрөткө уруксат бериңиз';

  @override
  String get dayFeedAllowAccess => 'Уруксат берүү';

  @override
  String get dayFeedFolderHint =>
      'Бул жерде сүрөт жана видеолорду көрүү үчүн медиа папканы тандаңыз';

  @override
  String get dayFeedChooseFolder => 'Тандоо';

  @override
  String get dayFeedMute => 'Үнүн өчүрүү';

  @override
  String get dayFeedUnmute => 'Үнүн күйгүзүү';

  @override
  String get holdToRecordAudio => 'Үн билдирүү жазуу үчүн басып туруңуз';

  @override
  String get holdToRecordVideo => 'Видео билдирүү жазуу үчүн басып туруңуз';

  @override
  String get roundVideoRecordError => 'Видеону жазуу мүмкүн болбоду';

  @override
  String get roundVideoCameraUnavailable => 'Бул түзмөктө камера жеткиликсиз';

  @override
  String get roundVideoRetake => 'Кайра тартуу';

  @override
  String get roundVideoUse => 'Колдонуу';

  @override
  String get removeMedia => 'Медианы өчүрүү';

  @override
  String get shakeToCustomize => 'Ыңгайлаштыруу үчүн силкиңиз';

  @override
  String get shakeToCustomizeHint => 'же аталышты басып туруңуз';

  @override
  String get customizeSettings => 'Жөндөөлөрдү ыңгайлаштыруу';

  @override
  String get customizeSettingsDescription =>
      'Белгиси алынган бөлүмдөр жана саптар жөндөөлөр экранында жашырылат.';

  @override
  String get calendarSettings => 'Календардын жөндөөлөрү';

  @override
  String get calendarShowMedia => 'Сүрөт жана видеолорду көрсөтүү';

  @override
  String get calendarWeekTitles => 'Жуманын аталыштары';

  @override
  String get calendarPlayStories => 'Окуяларды көрүү';

  @override
  String get storyBackgroundTweak => 'Окуялардын фону';

  @override
  String get storyAnimationOff => 'Өчүк';

  @override
  String get storyAnimationPulse => 'Пульс';

  @override
  String get storyAnimationWave => 'Толкун';

  @override
  String get storyAnimationEqualizer => 'Эквалайзер';

  @override
  String get storyAnimationDrift => 'Дрейф';

  @override
  String get storyAnimationGlow => 'Жаркыроо';

  @override
  String get viewerCommentHint => 'Комментарий…';

  @override
  String get calendarToCurrentWeek => 'Учурдагы жумага';

  @override
  String get storyDateLines => 'Дата саптары';

  @override
  String get storyTextureTitle => 'Текстура';

  @override
  String get storySpectrum => 'Үн спектри';

  @override
  String get storySensitivity => 'Сезгичтик';

  @override
  String profileMindfulDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Аң-сезимдүү $count күн',
    );
    return '$_temp0';
  }

  @override
  String get profileName => 'Аты';

  @override
  String get profilePhoto => 'Сүрөт';

  @override
  String get profileEmoji => 'Эмодзи';

  @override
  String get profileInitial => 'Тамга';

  @override
  String get webVersion => 'Веб-версия';

  @override
  String get webVersionAddressHint =>
      'Ошол эле Wi‑Fi\'дагы компьютердин браузеринде ачыңыз; keklist ачык турушу керек';

  @override
  String get webVersionCopied => 'Дарек көчүрүлдү';

  @override
  String get webVersionNeedsPin =>
      'keklist\'ти ошол эле Wi‑Fi\'дагы компьютердин браузеринде ачуу үчүн PIN коюңуз.';

  @override
  String get webVersionStarting => 'Иштетилүүдө…';

  @override
  String get webVersionNoWifi =>
      'keklist\'ти браузерде ачуу үчүн Wi‑Fi\'га туташыңыз.';

  @override
  String get webVersionNoBundle => 'Бул курамада веб-версия жок.';

  @override
  String get webVersionPin => 'PIN';

  @override
  String get webVersionPinSet => 'Ар бир браузер аны 30 күндө бир жолу сурайт';

  @override
  String get webVersionPinNotSet => 'Коюлган эмес';

  @override
  String get webVersionPinHint => '4–8 сан';

  @override
  String get webVersionRemovePin => 'PIN\'ди өчүрүү';

  @override
  String get webVersionPort => 'Порт';

  @override
  String get aiTab => 'Чат';

  @override
  String get aiTabDescription =>
      'Жазууларыңызды телефондо иштеген AI менен талкулаңыз';

  @override
  String get aiPrivacyNote =>
      'Телефондо гана иштейт: жазуулар түзмөктөн чыкпайт.';

  @override
  String get aiDisclaimer =>
      'Бул медициналык кызмат эмес. Коркунучта болсоңуз, тез жардам кызматына кайрылыңыз.';

  @override
  String get aiYesterday => 'Кечээ';

  @override
  String get aiSessions => 'Сессиялар';

  @override
  String get aiNoSessions => 'Азырынча сессия жок';

  @override
  String get aiNewSession => 'Жаңы сессия';

  @override
  String get aiChooseRole => 'Ролду тандаңыз';

  @override
  String get aiRoleTherapist => 'Терапевт';

  @override
  String get aiRoleCoach => 'Коуч';

  @override
  String get aiRoleFriend => 'Дос';

  @override
  String get aiMessageHint => 'Билдирүү';

  @override
  String get aiStarterWeek => 'Жумам кандай өттү?';

  @override
  String get aiStarterWorry => 'Акыркы убакта мени эмне тынчсыздандырат?';

  @override
  String get aiStarterJoy => 'Акыркы убакта мени эмне кубантты?';

  @override
  String get aiActionSaveAsMind => 'Майнд катары сактоо';

  @override
  String get aiActionOpenDay => 'Күндү ачуу';

  @override
  String get aiActionWeekSummary => 'Жуманын жыйынтыгы';

  @override
  String get aiWeekSummaryPrompt =>
      'Акыркы 7 күнүмдү жыйынтыкта: эмне болду, эмнени сездим, эмне өзгөчө болду.';

  @override
  String get aiSavedAsMind => 'Бүгүнгө сакталды';

  @override
  String get aiThinking => 'Ойлонуп жатам…';

  @override
  String get aiStop => 'Токтотуу';

  @override
  String get aiNoModelTitle => 'Моделди тандаңыз';

  @override
  String get aiNoModelMessage =>
      'Баштоо үчүн моделди жүктөп алыңыз. Ал телефондо, интернетсиз иштейт.';

  @override
  String get aiNoModelOnPhone =>
      'Моделди телефондогу колдонмодон жүктөңүз: Жөндөөлөр → AI → Моделдер.';

  @override
  String get aiModels => 'Моделдер';

  @override
  String get aiRoles => 'Ролдор';

  @override
  String get aiDownloaded => 'Жүктөлгөндөр';

  @override
  String get aiDownloads => 'Жүктөлүүдө';

  @override
  String get aiGalleryCatalog => 'Google AI Edge Gallery';

  @override
  String get aiHuggingFace => 'Hugging Face (GGUF)';

  @override
  String get aiSearchModels => 'GGUF моделдерин издөө';

  @override
  String get aiDownload => 'Жүктөө';

  @override
  String get aiPause => 'Тыным';

  @override
  String get aiPaused => 'Тынымда';

  @override
  String get aiResume => 'Улантуу';

  @override
  String get aiDownloadFailed => 'Жүктөө ишке ашкан жок';

  @override
  String get aiCellularTitle => 'Мобилдик интернет аркылуу жүктөйсүзбү?';

  @override
  String aiCellularMessage(String size) {
    return '$size мобилдик интернет аркылуу жүктөлөт.';
  }

  @override
  String get aiDeleteModel => 'Моделди өчүрөсүзбү?';

  @override
  String aiStorageUsed(String size) {
    return 'Бул телефондо: $size';
  }

  @override
  String aiDeviceMemory(String size) {
    return 'Телефондун эс тутуму: $size';
  }

  @override
  String get aiCatalogFailed =>
      'Тизмени жүктөө мүмкүн болбоду. Байланышты текшериңиз.';

  @override
  String get aiNoFilesFit =>
      'Бул моделдин бир да файлы телефондун эс тутумуна батпайт.';

  @override
  String get aiBuiltInRole => 'Орнотулган';

  @override
  String get aiOwnRoles => 'Сиздин ролдоруңуз';

  @override
  String get aiDuplicate => 'Көчүрмөсүн жасоо';

  @override
  String get aiNewRole => 'Жаңы роль';

  @override
  String get aiRoleName => 'Аталышы';

  @override
  String get aiRoleEmoji => 'Эмодзи';

  @override
  String get aiRolePrompt => 'Промпт';

  @override
  String get aiRolePromptHint =>
      'AI кантип сүйлөшү жана эмнеге көңүл бурушу керек';

  @override
  String get aiReadOnlyRole =>
      'Орнотулган ролдорду өзгөртүүгө болбойт. Өз ролуңузду жасоо үчүн көчүрмөсүн жасаңыз.';

  @override
  String get aiDeleteSession => 'Сессияны өчүрөсүзбү?';

  @override
  String get aiDeleteRole => 'Ролду өчүрөсүзбү?';

  @override
  String get aiRecommended => 'Сунушталат';

  @override
  String get aiLowQuality => 'Сапаты төмөн';

  @override
  String get aiModelDoesNotFit =>
      'Бул модель телефондун эсине батпайт. Кичирээк моделди тандаңыз.';

  @override
  String get aiChooseAnotherModel => 'Башка модель тандоо';

  @override
  String get creatorEmotionsTitle => 'Эмоциялар';

  @override
  String get creatorEmotionsAfterSave => 'Сактагандан кийин суроо';

  @override
  String get creatorEmotionsButton => 'Баскычтоптун үстүндөгү баскыч';

  @override
  String get creatorEmotionsNever => 'Сурабоо';

  @override
  String get insightsWeekAgo => 'Бир жума мурун';

  @override
  String get insightsMonthAgo => 'Бир ай мурун';

  @override
  String get insightsHalfYearAgo => 'Жарым жыл мурун';

  @override
  String get insightsYearAgo => 'Бир жыл мурун';

  @override
  String get insightsTwoYearsAgo => 'Эки жыл мурун';

  @override
  String get insightsVoiceAndVideos => 'Үн жана тегерек видеолор';

  @override
  String insightsWeekNumber(String number) {
    return '$number-жума';
  }
}
