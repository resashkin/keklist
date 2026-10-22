// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Serbian (`sr`).
class AppLocalizationsSr extends AppLocalizations {
  AppLocalizationsSr([String locale = 'sr']) : super(locale);

  @override
  String get insightsBrightestPeriod => 'Најупечатљивији период';

  @override
  String get insightsPeriodWeek => 'Недеља';

  @override
  String get insightsPeriodMonth => 'Месец';

  @override
  String get insightsPeriodYear => 'Година';

  @override
  String get insightsPeriodAllTime => 'Све време';

  @override
  String insightsVsLastWeek(String delta) {
    return '$delta у односу на прошлу недељу';
  }

  @override
  String insightsVsLastMonth(String delta) {
    return '$delta у односу на прошли месец';
  }

  @override
  String insightsVsLastYear(String delta) {
    return '$delta у односу на прошлу годину';
  }

  @override
  String get insightsCategorySummary => 'Преглед';

  @override
  String get insightsCategoryEmotions => 'Емоције';

  @override
  String get insightsCategoryActivity => 'Активност';

  @override
  String get insightsCategoryMemories => 'Успомене';

  @override
  String get insightsCategoryMedia => 'Медији';

  @override
  String get insightsCounters => 'У бројкама';

  @override
  String get insightsMinds => 'Белешке';

  @override
  String get insightsActiveDays => 'Активни дани';

  @override
  String get insightsWords => 'Речи';

  @override
  String get insightsBrightestDay => 'Најупечатљивији дан';

  @override
  String get insightsBrightestWeek => 'Најупечатљивија недеља';

  @override
  String get insightsBrightestMonth => 'Најупечатљивији месец';

  @override
  String get insightsBrightestYear => 'Најупечатљивија година';

  @override
  String insightsBrightestDetails(String minds, String emotions, String media) {
    return 'белешки: $minds · емоција: $emotions · медија: $media';
  }

  @override
  String get insightsEmotionDistribution => 'Емоције';

  @override
  String get insightsEmotionTrend => 'Ток емоција';

  @override
  String get insightsEmotionPairs => 'Емоције заједно';

  @override
  String get insightsEmotionRhythm => 'Емоционални ритам';

  @override
  String get insightsByWeekday => 'По данима у недељи';

  @override
  String get insightsByDayPart => 'По добу дана';

  @override
  String get insightsNight => 'Ноћ';

  @override
  String get insightsMorning => 'Јутро';

  @override
  String get insightsAfternoon => 'Поподне';

  @override
  String get insightsEvening => 'Вече';

  @override
  String get insightsStreak => 'Низ';

  @override
  String get insightsStreakLabel => 'дана заредом';

  @override
  String insightsLongestStreak(String count) {
    return 'Рекорд: $count';
  }

  @override
  String get insightsStreakKeepGoing => 'Додај белешку данас да наставиш низ';

  @override
  String get insightsHeatmap => 'Мапа активности';

  @override
  String get insightsActivityTime => 'Доба дана';

  @override
  String insightsPeakHour(String hour) {
    return 'Најактивнији око $hour';
  }

  @override
  String get insightsOnThisDay => 'На данашњи дан';

  @override
  String get insightsMediaCounters => 'Медији';

  @override
  String get insightsPhotos => 'Фотографије';

  @override
  String get insightsVideos => 'Видео записи';

  @override
  String get insightsVoiceNotes => 'Гласовне белешке';

  @override
  String get insightsRoundVideos => 'Округли видео записи';

  @override
  String get insightsEmptyPeriod => 'У овом периоду још нема белешки';

  @override
  String get insightsEmptyEmotions => 'Означи белешке емоцијама да видиш ово';

  @override
  String get insightsEmptyPairs =>
      'Означи белешку са две емоције да видиш парове';

  @override
  String get insightsEmptyOnThisDay =>
      'Још ништа са овог дана из претходних година';

  @override
  String get insightsEmptyRoundVideos =>
      'Нема округлих видео записа у овом периоду';

  @override
  String get insightsEmptyStreak => 'Додај белешку данас да започнеш низ';

  @override
  String get insightsCustomize => 'Прилагоди аналитику';

  @override
  String get insightsCustomizeDescription =>
      'Укључи или искључи картице и превуци их за редослед';

  @override
  String get insightsResetLayout => 'Ресетуј';

  @override
  String get activeTasks => 'Активни задаци';

  @override
  String get galleryIndex => 'Индекс галерије';

  @override
  String get galleryIndexNoAccess => 'Нема приступа Фотографијама';

  @override
  String get galleryIndexNotIndexed => 'Још није индексирано';

  @override
  String galleryIndexIndexing(String done, String total) {
    return 'Индексирање $done од $total';
  }

  @override
  String galleryIndexReady(String count, String time) {
    return '$count фотографија и видео записа · ажурирано $time';
  }

  @override
  String galleryIndexThumbnails(String size) {
    return 'Кеш сличица: $size';
  }

  @override
  String get galleryIndexRebuildTitle => 'Поново изградити индекс галерије?';

  @override
  String get galleryIndexRebuildMessage =>
      'Сличице ће бити обрисане, а библиотека поново скенирана.';

  @override
  String get galleryIndexRebuild => 'Поново изгради';

  @override
  String get allEmotions => 'Све…';

  @override
  String get settings => 'Подешавања';

  @override
  String get userData => 'Кориснички подаци';

  @override
  String get appearance => 'Изглед';

  @override
  String get interfaceStyle => 'Стил интерфејса';

  @override
  String get exportToCsv => 'Извоз у CSV';

  @override
  String get exportData => 'Извоз података';

  @override
  String get importData => 'Увоз података';

  @override
  String get done => 'ГОТОВО';

  @override
  String get chatWithAI => 'Чет са AI';

  @override
  String get photosPerDay => 'Фотографије дневно';

  @override
  String get extraActions => 'Додатне акције';

  @override
  String get mindOptions => 'Опције белешке';

  @override
  String get edit => 'Уреди';

  @override
  String get delete => 'Обриши';

  @override
  String get share => 'Подели';

  @override
  String get saveToFiles => 'Сачувај у фајлове';

  @override
  String get switchDay => 'Промени дан';

  @override
  String get goToDate => 'Иди на датум';

  @override
  String get showDigest => 'Прикажи сажетак за ...';

  @override
  String get translateToEnglish => 'Преведи на енглески';

  @override
  String get convertToStandalone => 'Претвори у самосталну';

  @override
  String get language => 'Језик';

  @override
  String get selectLanguage => 'Изаберите језик';

  @override
  String get theme => 'Тема';

  @override
  String get themeLight => 'Светла';

  @override
  String get themeDark => 'Тамна';

  @override
  String get themeSystem => 'Систем';

  @override
  String get showDayDividers => 'Прикажи разделиоце дана';

  @override
  String get tabsSettings => 'Подешавања картица';

  @override
  String get whatsNew => 'Шта је ново?';

  @override
  String get releaseNotes => 'Белешке о издању';

  @override
  String get suggestFeature => 'Предложи функцију';

  @override
  String get sendFeedback => 'Пошаљи повратну информацију';

  @override
  String get emailUs => 'Пошаљи нам e-поруку';

  @override
  String get clearOfflineDataWarning =>
      'Сви офлајн подаци ће бити обрисани. Увери се да си их већ извезао.';

  @override
  String get sourceCode => 'Изворни код';

  @override
  String get termsOfUse => 'Услови коришћења';

  @override
  String get privacyPolicy => 'Политика приватности';

  @override
  String get clearOnDeviceData => 'Очисти податке на уређају';

  @override
  String get setOpenAIToken => 'Постави Open AI токен';

  @override
  String get cancel => 'Откажи';

  @override
  String get save => 'Сачувај';

  @override
  String get mind => 'Белешка';

  @override
  String get profile => 'Профил';

  @override
  String get insights => 'Увиди';

  @override
  String get calendar => 'Календар';

  @override
  String get debugMenu => 'Мени за отклањање грешака';

  @override
  String get discussion => 'Дискусија';

  @override
  String get about => 'О програму';

  @override
  String get dangerZone => 'Опасна зона';

  @override
  String get enterTokenHere => 'Унесите токен овде';

  @override
  String get token => 'Токен';

  @override
  String get clearCache => 'Очисти кеш';

  @override
  String get activeTabs => 'Активне картице';

  @override
  String get hiddenTabs => 'Скривене картице';

  @override
  String get error => 'Грешка';

  @override
  String get startDiscussion => 'Почни дискусију';

  @override
  String get send => 'ПОШАЉИ';

  @override
  String get updateYourNickname => 'Ажурирај свој надимак';

  @override
  String get yourNickname => 'Твој надимак';

  @override
  String get create => 'Направи';

  @override
  String get yourFolderName => 'Назив твог фолдера';

  @override
  String get noMindsInSelectedPeriod => 'Нема белешки у изабраном периоду';

  @override
  String get noMindsForPeriod => 'Нема белешки за овај период';

  @override
  String get selectPeriod => 'Изабери период ...';

  @override
  String get digest => 'Сажетак';

  @override
  String get minds => 'Белешке';

  @override
  String get searchForYourNotes => 'Претражи своје белешке';

  @override
  String get searchYourEmoji => 'Претражи свој емоџи...';

  @override
  String get writeSomething => 'Напиши нешто...';

  @override
  String get todayMinds => 'Данашње белешке';

  @override
  String get youDidNotCollectAnyEntriesYet =>
      'Још увек ниси прикупио ниједан унос';

  @override
  String get areYouSure => 'Да ли сте сигурни?';

  @override
  String get cannotRemoveMainScreen =>
      'Није могуће уклонити главни екран. Изгубићеш опцију да подесиш картице.';

  @override
  String get today => 'Данас';

  @override
  String get yesterday => 'Јуче';

  @override
  String get thisWeek => 'Ова недеља';

  @override
  String get lastTwoWeeks => 'Последње 2 недеље';

  @override
  String get thisMonth => 'Овај месец';

  @override
  String get thisYear => 'Ова година';

  @override
  String get calendarDescription => 'Главни екран са календаром уноса';

  @override
  String get insightsDescription => 'Статистика свих твојих уноса';

  @override
  String get settingsDescription =>
      'Екран са свим подешавањима (тамни режим, синхронизација итд.)';

  @override
  String get profileDescription => 'Екран са твојим профилом';

  @override
  String get todayDescription => 'Само данашње белешке';

  @override
  String get debugMenuDescription =>
      'Алати за програмере за укључивање експерименталних функција';

  @override
  String get noMindsForThisDay => 'Нема белешки за овај дан';

  @override
  String get week => 'Недеља';

  @override
  String get password => 'Лозинка';

  @override
  String get archivePassword => 'Лозинка архиве';

  @override
  String get enterPassword => 'Унеси лозинку';

  @override
  String get confirmPassword => 'Потврди лозинку';

  @override
  String get reenterPassword => 'Поново унеси лозинку';

  @override
  String get passwordsDoNotMatch => 'Лозинке се не подударају';

  @override
  String get exportPassword => 'Извоз у ZIP';

  @override
  String get exportPasswordDescription =>
      'Додај лозинку да шифрујеш свој извоз. Можеш да прескочиш ово за нешифровани извоз.';

  @override
  String get importPassword => 'Унеси лозинку';

  @override
  String get importPasswordDescription =>
      'Овај фајл је заштићен лозинком. Унеси лозинку за дешифровање.';

  @override
  String get skipPassword => 'Прескочи (без лозинке)';

  @override
  String get continue_ => 'Настави';

  @override
  String get incorrectPassword => 'Нетачна лозинка';

  @override
  String get incorrectPasswordMessage =>
      'Лозинка коју си унео је нетачна. Покушај поново.';

  @override
  String get corruptedFile => 'Оштећени фајл';

  @override
  String get invalidFormat => 'Неважећи формат';

  @override
  String get missingAudioFiles => 'Неки аудио фајлови недостају';

  @override
  String get insufficientStorage => 'Недовољно простора за складиштење';

  @override
  String get unknownError => 'Непозната грешка';

  @override
  String get retry => 'Покушај поново';

  @override
  String get ok => 'У реду';

  @override
  String get exportSuccess => 'Извоз успешан';

  @override
  String get exportError => 'Извоз није успео';

  @override
  String get importSuccess => 'Увоз успешан';

  @override
  String get importError => 'Увоз није успео';

  @override
  String get mindsToExport => 'Белешке';

  @override
  String get audioFilesToExport => 'Аудио фајлови';

  @override
  String get emotionsToExport => 'Емоције';

  @override
  String get mindsExported => 'Белешке извезене';

  @override
  String get audioFilesExported => 'Аудио фајлови извезени';

  @override
  String get mindsImported => 'Белешке увезене';

  @override
  String get audioFilesImported => 'Аудио фајлови увезени';

  @override
  String get onboardingMind1 => 'Здраво!';

  @override
  String get onboardingMind2 =>
      'Ја сам keklist - лични дневник кратких белешки';

  @override
  String get onboardingMind2Comment1 => 'Белешке могу бити коментарисане';

  @override
  String get onboardingMind2Comment2 => 'Да отвориш белешку, притисни на њу';

  @override
  String get onboardingMind3 =>
      'У картици \'Календар\' све белешке су приказане по данима, недељама и месецима';

  @override
  String get onboardingMind4 =>
      'Картица \'Аналитика\' приказује кратку статистику твојих уноса';

  @override
  String get onboardingMind5 =>
      'Све белешке су сачуване само на твојом телефону';

  @override
  String get onboardingMind6 => 'Да креирате нову белешку, додирните \'Пиши\'';

  @override
  String get noPhotosForDay => 'Нема фотографија за овај дан';

  @override
  String get sourcesMediaFolder => 'Медијске датотеке';

  @override
  String get sourcesMediaFolderSubtitle =>
      'Фотографије и видео из прилагођене фасцикле';

  @override
  String get mediaFolderSettings => 'Медијске датотеке';

  @override
  String get licenses => 'Лиценце';

  @override
  String get sourcesWeather => 'Временска прогноза';

  @override
  String get sourcesWeatherSubtitle => 'Локалне временске прилике за овај дан';

  @override
  String get weatherSettings => 'Подешавања временске прогнозе';

  @override
  String get weatherLatitude => 'Географска ширина';

  @override
  String get weatherLongitude => 'Географска дужина';

  @override
  String get weatherSaveLocation => 'Сачувај локацију';

  @override
  String get weatherUseMyLocation => 'Користи моју локацију';

  @override
  String get weatherDetectingLocation => 'Откривање локације...';

  @override
  String get weatherOrEnterManually => 'или унесите ручно';

  @override
  String get weatherLocationError =>
      'Локација није могла бити откривена. Унесите ручно.';

  @override
  String get weatherLocationServicesDisabled =>
      'Услуге локације су онемогућене. Омогућите их у подешавањима.';

  @override
  String get weatherLocationPermissionDenied => 'Дозвола за локацију одбијена.';

  @override
  String get weatherLocationPermissionPermanentlyDenied =>
      'Дозвола за локацију је трајно одбијена. Отварање подешавања апликације.';

  @override
  String get audioRecordTitle => 'Сними аудио';

  @override
  String get audioRecordTitleRecording => 'Снима се…';

  @override
  String get audioRecordHint => 'Тапните Стоп да сачувате на уређај.';

  @override
  String get audioRecordStart => 'Почни';

  @override
  String get audioRecordStop => 'Стоп';

  @override
  String get audioRecordCancel => 'Откажи';

  @override
  String get audioRecordPermissionError =>
      'Потребна је дозвола за микрофон за снимање звука.';

  @override
  String get audioRecordStartError =>
      'Није могуће покренути снимање. Покушајте поново.';

  @override
  String get audioRecordStopError =>
      'Није могуће зауставити снимање. Покушајте поново.';

  @override
  String proUserFooter(String price, String date) {
    return 'Ви сте PRO корисник. Следећа уплата $price биће $date.';
  }

  @override
  String get emotions => 'Емоције';

  @override
  String get archived => 'Архивирано';

  @override
  String get archive => 'Архивирај';

  @override
  String get restore => 'Врати';

  @override
  String get deletePermanently => 'Трајно обриши';

  @override
  String get newEmotion => 'Нова емоција';

  @override
  String get editEmotion => 'Измени емоцију';

  @override
  String get addEmotion => 'Додај емоцију';

  @override
  String get addEmotionsToMind => 'Додај емоције';

  @override
  String get emotionNameHint => 'Назив';

  @override
  String get doneEditing => 'Готово';

  @override
  String get emotionEditHint =>
      'Додирните за преименовање · ✕ за уклањање · превуците за преуређивање';

  @override
  String get emotionInUseMessage =>
      'Ова емоција се користи у неким мислима. Архивирајте је да остане тамо, или је обришите свуда.';

  @override
  String get emotionPickHint => 'Додирните за означавање';

  @override
  String get emotionDrillHint => 'дуже држите за дубље';

  @override
  String get noEmotionsYet => 'Још нема емоција';

  @override
  String get noArchivedEmotions => 'Нема архивираних емоција';

  @override
  String get deleteEmotionMessage =>
      'Обрисати ову емоцију? Биће уклоњена из свих мисли које је користе.';

  @override
  String get dayFeedTileSettings => 'Подешавања плочица';

  @override
  String get dayFeedColumns => 'Колоне';

  @override
  String get dayFeedMindTileSize => 'Величина плочице';

  @override
  String get dayFeedMindTileSquare => 'Квадрат';

  @override
  String get dayFeedMindTileWide => 'Широка';

  @override
  String get dayFeedShowMindText => 'Прикажи текст';

  @override
  String get dayFeedPhotoAccessHint =>
      'Дозволи приступ фотографијама да би овде видео фотографије и видео записе';

  @override
  String get dayFeedAllowAccess => 'Дозволи';

  @override
  String get dayFeedFolderHint =>
      'Изабери медијску фасциклу да би овде видео фотографије и видео записе';

  @override
  String get dayFeedChooseFolder => 'Изабери';

  @override
  String get dayFeedMute => 'Искључи звук';

  @override
  String get dayFeedUnmute => 'Укључи звук';

  @override
  String get holdToRecordAudio => 'Држи за гласовну поруку';

  @override
  String get holdToRecordVideo => 'Држи за видео поруку';

  @override
  String get roundVideoRecordError => 'Снимање видеа није успело';

  @override
  String get roundVideoCameraUnavailable =>
      'Камера није доступна на овом уређају';

  @override
  String get roundVideoRetake => 'Сними поново';

  @override
  String get roundVideoUse => 'Користи';

  @override
  String get removeMedia => 'Уклони медије';

  @override
  String get shakeToCustomize => 'Протресите за прилагођавање';

  @override
  String get shakeToCustomizeHint => 'или дуго притисните наслов';

  @override
  String get customizeSettings => 'Прилагоди подешавања';

  @override
  String get customizeSettingsDescription =>
      'Неозначени одељци и редови се скривају са екрана подешавања.';

  @override
  String get calendarSettings => 'Подешавања календара';

  @override
  String get calendarShowMedia => 'Прикажи фотографије и видео записе';

  @override
  String get calendarWeekTitles => 'Наслови недеља';

  @override
  String get calendarPlayStories => 'Пусти приче';

  @override
  String get storyBackgroundTweak => 'Позадина прича';

  @override
  String get storyAnimationOff => 'Искључено';

  @override
  String get storyAnimationPulse => 'Пулс';

  @override
  String get storyAnimationWave => 'Талас';

  @override
  String get storyAnimationEqualizer => 'Еквилајзер';

  @override
  String get storyAnimationDrift => 'Дрифт';

  @override
  String get storyAnimationGlow => 'Сјај';

  @override
  String get viewerCommentHint => 'Коментар…';
}

/// The translations for Serbian, using the Latin script (`sr_Latn`).
class AppLocalizationsSrLatn extends AppLocalizationsSr {
  AppLocalizationsSrLatn() : super('sr_Latn');

  @override
  String get insightsBrightestPeriod => 'Najupečatljiviji period';

  @override
  String get insightsPeriodWeek => 'Nedelja';

  @override
  String get insightsPeriodMonth => 'Mesec';

  @override
  String get insightsPeriodYear => 'Godina';

  @override
  String get insightsPeriodAllTime => 'Sve vreme';

  @override
  String insightsVsLastWeek(String delta) {
    return '$delta u odnosu na prošlu nedelju';
  }

  @override
  String insightsVsLastMonth(String delta) {
    return '$delta u odnosu na prošli mesec';
  }

  @override
  String insightsVsLastYear(String delta) {
    return '$delta u odnosu na prošlu godinu';
  }

  @override
  String get insightsCategorySummary => 'Pregled';

  @override
  String get insightsCategoryEmotions => 'Emocije';

  @override
  String get insightsCategoryActivity => 'Aktivnost';

  @override
  String get insightsCategoryMemories => 'Uspomene';

  @override
  String get insightsCategoryMedia => 'Mediji';

  @override
  String get insightsCounters => 'U brojkama';

  @override
  String get insightsMinds => 'Beleške';

  @override
  String get insightsActiveDays => 'Aktivni dani';

  @override
  String get insightsWords => 'Reči';

  @override
  String get insightsBrightestDay => 'Najupečatljiviji dan';

  @override
  String get insightsBrightestWeek => 'Najupečatljivija nedelja';

  @override
  String get insightsBrightestMonth => 'Najupečatljiviji mesec';

  @override
  String get insightsBrightestYear => 'Najupečatljivija godina';

  @override
  String insightsBrightestDetails(String minds, String emotions, String media) {
    return 'beleški: $minds · emocija: $emotions · medija: $media';
  }

  @override
  String get insightsEmotionDistribution => 'Emocije';

  @override
  String get insightsEmotionTrend => 'Tok emocija';

  @override
  String get insightsEmotionPairs => 'Emocije zajedno';

  @override
  String get insightsEmotionRhythm => 'Emocionalni ritam';

  @override
  String get insightsByWeekday => 'Po danima u nedelji';

  @override
  String get insightsByDayPart => 'Po dobu dana';

  @override
  String get insightsNight => 'Noć';

  @override
  String get insightsMorning => 'Jutro';

  @override
  String get insightsAfternoon => 'Popodne';

  @override
  String get insightsEvening => 'Veče';

  @override
  String get insightsStreak => 'Niz';

  @override
  String get insightsStreakLabel => 'dana zaredom';

  @override
  String insightsLongestStreak(String count) {
    return 'Rekord: $count';
  }

  @override
  String get insightsStreakKeepGoing => 'Dodaj belešku danas da nastaviš niz';

  @override
  String get insightsHeatmap => 'Mapa aktivnosti';

  @override
  String get insightsActivityTime => 'Doba dana';

  @override
  String insightsPeakHour(String hour) {
    return 'Najaktivniji oko $hour';
  }

  @override
  String get insightsOnThisDay => 'Na današnji dan';

  @override
  String get insightsMediaCounters => 'Mediji';

  @override
  String get insightsPhotos => 'Fotografije';

  @override
  String get insightsVideos => 'Video zapisi';

  @override
  String get insightsVoiceNotes => 'Glasovne beleške';

  @override
  String get insightsRoundVideos => 'Okrugli video zapisi';

  @override
  String get insightsEmptyPeriod => 'U ovom periodu još nema beleški';

  @override
  String get insightsEmptyEmotions => 'Označi beleške emocijama da vidiš ovo';

  @override
  String get insightsEmptyPairs =>
      'Označi belešku sa dve emocije da vidiš parove';

  @override
  String get insightsEmptyOnThisDay =>
      'Još ništa sa ovog dana iz prethodnih godina';

  @override
  String get insightsEmptyRoundVideos =>
      'Nema okruglih video zapisa u ovom periodu';

  @override
  String get insightsEmptyStreak => 'Dodaj belešku danas da započneš niz';

  @override
  String get insightsCustomize => 'Prilagodi analitiku';

  @override
  String get insightsCustomizeDescription =>
      'Uključi ili isključi kartice i prevuci ih za redosled';

  @override
  String get insightsResetLayout => 'Resetuj';

  @override
  String get activeTasks => 'Aktivni zadaci';

  @override
  String get galleryIndex => 'Indeks galerije';

  @override
  String get galleryIndexNoAccess => 'Nema pristupa Fotografijama';

  @override
  String get galleryIndexNotIndexed => 'Još nije indeksirano';

  @override
  String galleryIndexIndexing(String done, String total) {
    return 'Indeksiranje $done od $total';
  }

  @override
  String galleryIndexReady(String count, String time) {
    return '$count fotografija i video zapisa · ažurirano $time';
  }

  @override
  String galleryIndexThumbnails(String size) {
    return 'Keš sličica: $size';
  }

  @override
  String get galleryIndexRebuildTitle => 'Ponovo izgraditi indeks galerije?';

  @override
  String get galleryIndexRebuildMessage =>
      'Sličice će biti obrisane, a biblioteka ponovo skenirana.';

  @override
  String get galleryIndexRebuild => 'Ponovo izgradi';

  @override
  String get allEmotions => 'Sve…';

  @override
  String get settings => 'Podešavanja';

  @override
  String get userData => 'Korisnički podaci';

  @override
  String get appearance => 'Izgled';

  @override
  String get interfaceStyle => 'Stil interfejsa';

  @override
  String get exportToCsv => 'Izvezi u CSV';

  @override
  String get exportData => 'Izvoz podataka';

  @override
  String get importData => 'Uvoz podataka';

  @override
  String get done => 'GOTOVO';

  @override
  String get chatWithAI => 'Ćaskanje sa AI';

  @override
  String get photosPerDay => 'Fotografije po danu';

  @override
  String get extraActions => 'Dodatne akcije';

  @override
  String get mindOptions => 'Opcije uma';

  @override
  String get edit => 'Uredi';

  @override
  String get delete => 'Obriši';

  @override
  String get share => 'Podeli';

  @override
  String get saveToFiles => 'Sačuvaj u fajlove';

  @override
  String get switchDay => 'Promeni dan';

  @override
  String get goToDate => 'Idi na datum';

  @override
  String get showDigest => 'Prikaži sažetak za ...';

  @override
  String get translateToEnglish => 'Prevedi na engleski';

  @override
  String get convertToStandalone => 'Konvertuj u samostalno';

  @override
  String get language => 'Jezik';

  @override
  String get selectLanguage => 'Izaberi jezik';

  @override
  String get theme => 'Tema';

  @override
  String get themeLight => 'Svetla';

  @override
  String get themeDark => 'Tamna';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get showDayDividers => 'Prikaži razdelnike dana';

  @override
  String get tabsSettings => 'Podešavanja tabova';

  @override
  String get whatsNew => 'Šta je novo?';

  @override
  String get releaseNotes => 'Beleške o izdanju';

  @override
  String get suggestFeature => 'Predloži funkciju';

  @override
  String get sendFeedback => 'Pošalji povratnu informaciju';

  @override
  String get emailUs => 'Pošalji nam e-poruku';

  @override
  String get clearOfflineDataWarning =>
      'Svi oflajn podaci će biti obrisani. Uveri se da si ih već izvezao.';

  @override
  String get sourceCode => 'Izvorni kod';

  @override
  String get termsOfUse => 'Uslovi korišćenja';

  @override
  String get privacyPolicy => 'Politika privatnosti';

  @override
  String get clearOnDeviceData => 'Obriši podatke na uređaju';

  @override
  String get setOpenAIToken => 'Postavi Open AI Token';

  @override
  String get cancel => 'Otkaži';

  @override
  String get save => 'Sačuvaj';

  @override
  String get mind => 'Um';

  @override
  String get profile => 'Profil';

  @override
  String get insights => 'Uvid';

  @override
  String get calendar => 'Kalendar';

  @override
  String get debugMenu => 'Debug meni';

  @override
  String get discussion => 'Diskusija';

  @override
  String get about => 'O aplikaciji';

  @override
  String get dangerZone => 'Zona opasnosti';

  @override
  String get enterTokenHere => 'Unesite token ovde';

  @override
  String get token => 'Token';

  @override
  String get clearCache => 'Obriši keš';

  @override
  String get activeTabs => 'Aktivni tabovi';

  @override
  String get hiddenTabs => 'Skriveni tabovi';

  @override
  String get error => 'Greška';

  @override
  String get startDiscussion => 'Započni diskusiju';

  @override
  String get send => 'POŠALJI';

  @override
  String get updateYourNickname => 'Ažuriraj svoj nadimak';

  @override
  String get yourNickname => 'Tvoj nadimak';

  @override
  String get create => 'Napravi';

  @override
  String get yourFolderName => 'Ime tvoje fascikle';

  @override
  String get noMindsInSelectedPeriod => 'Nema uma u izabranom periodu';

  @override
  String get noMindsForPeriod => 'Nema uma za ovaj period';

  @override
  String get selectPeriod => 'Izaberi period ...';

  @override
  String get digest => 'Sažetak';

  @override
  String get minds => 'Umovi';

  @override
  String get searchForYourNotes => 'Pretraži svoje beleške';

  @override
  String get searchYourEmoji => 'Pretraži svoj emoji...';

  @override
  String get writeSomething => 'Napiši nešto...';

  @override
  String get todayMinds => 'Današnji umovi';

  @override
  String get youDidNotCollectAnyEntriesYet =>
      'Još uvek niste prikupili nijedan unos';

  @override
  String get areYouSure => 'Da li ste sigurni?';

  @override
  String get cannotRemoveMainScreen =>
      'Ne možete ukloniti glavni ekran. Izgubićete opciju za podešavanje tabova.';

  @override
  String get today => 'Danas';

  @override
  String get yesterday => 'Juče';

  @override
  String get thisWeek => 'Ova nedelja';

  @override
  String get lastTwoWeeks => 'Poslednje 2 nedelje';

  @override
  String get thisMonth => 'Ovaj mesec';

  @override
  String get thisYear => 'Ova godina';

  @override
  String get calendarDescription => 'Glavni ekran sa kalendarom unosa';

  @override
  String get insightsDescription => 'Statistike svih vaših unosa';

  @override
  String get settingsDescription =>
      'Ekran sa svim podešavanjima (tamni režim, sinhronizacija i sl.)';

  @override
  String get profileDescription => 'Ekran sa vašim profilom';

  @override
  String get todayDescription => 'Samo današnji umovi';

  @override
  String get debugMenuDescription =>
      'Alati za programere za uključivanje eksperimentalnih funkcija';

  @override
  String get noMindsForThisDay => 'Nema uma za ovaj dan';

  @override
  String get week => 'Nedelja';

  @override
  String get password => 'Lozinka';

  @override
  String get archivePassword => 'Lozinka arhive';

  @override
  String get enterPassword => 'Unesi lozinku';

  @override
  String get confirmPassword => 'Potvrdi lozinku';

  @override
  String get reenterPassword => 'Ponovo unesi lozinku';

  @override
  String get passwordsDoNotMatch => 'Lozinke se ne podudaraju';

  @override
  String get exportPassword => 'Zaštititi izvoz lozinkom?';

  @override
  String get exportPasswordDescription =>
      'Dodaj lozinku da šifruješ izvoz. Možeš preskočiti za nešifrovani izvoz.';

  @override
  String get importPassword => 'Unesi lozinku';

  @override
  String get importPasswordDescription =>
      'Ovaj fajl je zaštićen lozinkom. Unesi lozinku da dešifruješ.';

  @override
  String get skipPassword => 'Preskoči (bez lozinke)';

  @override
  String get continue_ => 'Nastavi';

  @override
  String get incorrectPassword => 'Netačna lozinka';

  @override
  String get incorrectPasswordMessage =>
      'Lozinka koju si uneo je netačna. Pokušaj ponovo.';

  @override
  String get corruptedFile => 'Oštećeni fajl';

  @override
  String get invalidFormat => 'Nevažeći format';

  @override
  String get missingAudioFiles => 'Neki audio fajlovi nedostaju';

  @override
  String get insufficientStorage => 'Nedovoljno memorije';

  @override
  String get unknownError => 'Nepoznata greška';

  @override
  String get retry => 'Pokušaj ponovo';

  @override
  String get ok => 'OK';

  @override
  String get exportSuccess => 'Izvoz uspešan';

  @override
  String get exportError => 'Izvoz neuspešan';

  @override
  String get importSuccess => 'Uvoz uspešan';

  @override
  String get importError => 'Uvoz neuspešan';

  @override
  String get mindsToExport => 'Umovi';

  @override
  String get audioFilesToExport => 'Audio fajlovi';

  @override
  String get emotionsToExport => 'Emocije';

  @override
  String get mindsExported => 'Umovi izvezeni';

  @override
  String get audioFilesExported => 'Audio fajlovi izvezeni';

  @override
  String get mindsImported => 'Umovi uvezeni';

  @override
  String get audioFilesImported => 'Audio fajlovi uvezeni';

  @override
  String get onboardingMind1 => 'Zdravo!';

  @override
  String get onboardingMind2 =>
      'Ja sam keklist - lični dnevnik kratkih beleški';

  @override
  String get onboardingMind2Comment1 => 'Beleške mogu biti komentarisane';

  @override
  String get onboardingMind2Comment2 => 'Da otvorite belešku, dotaknite je';

  @override
  String get onboardingMind3 =>
      'U kartici \'Kalendar\', sve beleške su prikazane po danima, nedeljama i mesecima';

  @override
  String get onboardingMind4 =>
      'Kartica \'Analitika\' prikazuje kratku statistiku vaših unosa';

  @override
  String get onboardingMind5 => 'Sve beleške se čuvaju samo na vašem telefonu';

  @override
  String get onboardingMind6 => 'Da kreirate novu belešku, dodirnite \'Piši\'';

  @override
  String get noPhotosForDay => 'Nema fotografija za ovaj dan';

  @override
  String get sourcesMediaFolder => 'Medijske datoteke';

  @override
  String get sourcesMediaFolderSubtitle =>
      'Fotografije i video iz prilagođene fascikle';

  @override
  String get mediaFolderSettings => 'Medijske datoteke';

  @override
  String get licenses => 'Licence';

  @override
  String get sourcesWeather => 'Vremenska prognoza';

  @override
  String get sourcesWeatherSubtitle => 'Lokalne vremenske prilike za ovaj dan';

  @override
  String get weatherSettings => 'Podešavanja vremenske prognoze';

  @override
  String get weatherLatitude => 'Geografska širina';

  @override
  String get weatherLongitude => 'Geografska dužina';

  @override
  String get weatherSaveLocation => 'Sačuvaj lokaciju';

  @override
  String get weatherUseMyLocation => 'Koristi moju lokaciju';

  @override
  String get weatherDetectingLocation => 'Otkrivanje lokacije...';

  @override
  String get weatherOrEnterManually => 'ili unesite ručno';

  @override
  String get weatherLocationError =>
      'Lokacija nije mogla biti otkrivena. Unesite ručno.';

  @override
  String get weatherLocationServicesDisabled =>
      'Usluge lokacije su onemogućene. Omogućite ih u podešavanjima.';

  @override
  String get weatherLocationPermissionDenied => 'Dozvola za lokaciju odbijena.';

  @override
  String get weatherLocationPermissionPermanentlyDenied =>
      'Dozvola za lokaciju je trajno odbijena. Otvaranje podešavanja aplikacije.';

  @override
  String get audioRecordTitle => 'Snimi audio';

  @override
  String get audioRecordTitleRecording => 'Snima se…';

  @override
  String get audioRecordHint => 'Tapnite Stop da sačuvate na uređaj.';

  @override
  String get audioRecordStart => 'Počni';

  @override
  String get audioRecordStop => 'Stop';

  @override
  String get audioRecordCancel => 'Otkaži';

  @override
  String get audioRecordPermissionError =>
      'Potrebna je dozvola za mikrofon za snimanje zvuka.';

  @override
  String get audioRecordStartError =>
      'Nije moguće pokrenuti snimanje. Pokušajte ponovo.';

  @override
  String get audioRecordStopError =>
      'Nije moguće zaustaviti snimanje. Pokušajte ponovo.';

  @override
  String proUserFooter(String price, String date) {
    return 'Vi ste PRO korisnik. Sledeća uplata $price biće $date.';
  }

  @override
  String get emotions => 'Emocije';

  @override
  String get archived => 'Arhivirano';

  @override
  String get archive => 'Arhiviraj';

  @override
  String get restore => 'Vrati';

  @override
  String get deletePermanently => 'Trajno obriši';

  @override
  String get newEmotion => 'Nova emocija';

  @override
  String get editEmotion => 'Izmeni emociju';

  @override
  String get addEmotion => 'Dodaj emociju';

  @override
  String get addEmotionsToMind => 'Dodaj emocije';

  @override
  String get emotionNameHint => 'Naziv';

  @override
  String get doneEditing => 'Gotovo';

  @override
  String get emotionEditHint =>
      'Dodirnite za preimenovanje · ✕ za uklanjanje · prevucite za preuređivanje';

  @override
  String get emotionInUseMessage =>
      'Ova emocija se koristi u nekim mislima. Arhivirajte je da ostane tamo, ili je obrišite svuda.';

  @override
  String get emotionPickHint => 'Dodirnite za označavanje';

  @override
  String get emotionDrillHint => 'duže držite za dublje';

  @override
  String get noEmotionsYet => 'Još nema emocija';

  @override
  String get noArchivedEmotions => 'Nema arhiviranih emocija';

  @override
  String get deleteEmotionMessage =>
      'Obrisati ovu emociju? Biće uklonjena iz svih misli koje je koriste.';

  @override
  String get dayFeedTileSettings => 'Podešavanja pločica';

  @override
  String get dayFeedColumns => 'Kolone';

  @override
  String get dayFeedMindTileSize => 'Veličina pločice';

  @override
  String get dayFeedMindTileSquare => 'Kvadrat';

  @override
  String get dayFeedMindTileWide => 'Široka';

  @override
  String get dayFeedShowMindText => 'Prikaži tekst';

  @override
  String get dayFeedPhotoAccessHint =>
      'Dozvoli pristup fotografijama da bi ovde video fotografije i video zapise';

  @override
  String get dayFeedAllowAccess => 'Dozvoli';

  @override
  String get dayFeedFolderHint =>
      'Izaberi medijsku fasciklu da bi ovde video fotografije i video zapise';

  @override
  String get dayFeedChooseFolder => 'Izaberi';

  @override
  String get dayFeedMute => 'Isključi zvuk';

  @override
  String get dayFeedUnmute => 'Uključi zvuk';

  @override
  String get holdToRecordAudio => 'Drži za glasovnu poruku';

  @override
  String get holdToRecordVideo => 'Drži za video poruku';

  @override
  String get roundVideoRecordError => 'Snimanje videa nije uspelo';

  @override
  String get roundVideoCameraUnavailable =>
      'Kamera nije dostupna na ovom uređaju';

  @override
  String get roundVideoRetake => 'Snimi ponovo';

  @override
  String get roundVideoUse => 'Koristi';

  @override
  String get removeMedia => 'Ukloni medije';

  @override
  String get shakeToCustomize => 'Protresite za prilagođavanje';

  @override
  String get shakeToCustomizeHint => 'ili dugo pritisnite naslov';

  @override
  String get customizeSettings => 'Prilagodi podešavanja';

  @override
  String get customizeSettingsDescription =>
      'Neoznačeni odeljci i redovi se skrivaju sa ekrana podešavanja.';

  @override
  String get calendarSettings => 'Podešavanja kalendara';

  @override
  String get calendarShowMedia => 'Prikaži fotografije i video zapise';

  @override
  String get calendarWeekTitles => 'Naslovi nedelja';

  @override
  String get calendarPlayStories => 'Pusti priče';

  @override
  String get storyBackgroundTweak => 'Pozadina priča';

  @override
  String get storyAnimationOff => 'Isključeno';

  @override
  String get storyAnimationPulse => 'Puls';

  @override
  String get storyAnimationWave => 'Talas';

  @override
  String get storyAnimationEqualizer => 'Ekvilajzer';

  @override
  String get storyAnimationDrift => 'Drift';

  @override
  String get storyAnimationGlow => 'Sjaj';

  @override
  String get viewerCommentHint => 'Komentar…';
}
