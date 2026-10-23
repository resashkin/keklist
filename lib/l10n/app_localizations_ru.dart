// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get insightsBrightestPeriod => 'Самый яркий период';

  @override
  String get insightsPeriodWeek => 'Неделя';

  @override
  String get insightsPeriodMonth => 'Месяц';

  @override
  String get insightsPeriodYear => 'Год';

  @override
  String get insightsPeriodAllTime => 'Всё время';

  @override
  String insightsVsLastWeek(String delta) {
    return '$delta к прошлой неделе';
  }

  @override
  String insightsVsLastMonth(String delta) {
    return '$delta к прошлому месяцу';
  }

  @override
  String insightsVsLastYear(String delta) {
    return '$delta к прошлому году';
  }

  @override
  String get insightsCategorySummary => 'Сводка';

  @override
  String get insightsCategoryEmotions => 'Эмоции';

  @override
  String get insightsCategoryActivity => 'Активность';

  @override
  String get insightsCategoryMemories => 'Воспоминания';

  @override
  String get insightsCategoryMedia => 'Медиа';

  @override
  String get insightsCounters => 'В цифрах';

  @override
  String get insightsMinds => 'Заметки';

  @override
  String get insightsActiveDays => 'Активные дни';

  @override
  String get insightsWords => 'Слова';

  @override
  String get insightsBrightestDay => 'Самый яркий день';

  @override
  String get insightsBrightestWeek => 'Самая яркая неделя';

  @override
  String get insightsBrightestMonth => 'Самый яркий месяц';

  @override
  String get insightsBrightestYear => 'Самый яркий год';

  @override
  String insightsBrightestDetails(String minds, String emotions, String media) {
    return 'заметок: $minds · эмоций: $emotions · медиа: $media';
  }

  @override
  String get insightsEmotionDistribution => 'Эмоции';

  @override
  String get insightsEmotionTrend => 'Динамика эмоций';

  @override
  String get insightsEmotionPairs => 'Эмоции вместе';

  @override
  String get insightsEmotionRhythm => 'Эмоциональный ритм';

  @override
  String get insightsByWeekday => 'По дням недели';

  @override
  String get insightsByDayPart => 'По времени суток';

  @override
  String get insightsNight => 'Ночь';

  @override
  String get insightsMorning => 'Утро';

  @override
  String get insightsAfternoon => 'День';

  @override
  String get insightsEvening => 'Вечер';

  @override
  String get insightsStreak => 'Серия';

  @override
  String get insightsStreakLabel => 'дней подряд';

  @override
  String insightsLongestStreak(String count) {
    return 'Рекорд: $count';
  }

  @override
  String get insightsStreakKeepGoing =>
      'Добавьте заметку сегодня, чтобы не прервать серию';

  @override
  String get insightsHeatmap => 'Карта активности';

  @override
  String get insightsActivityTime => 'Время суток';

  @override
  String insightsPeakHour(String hour) {
    return 'Чаще всего около $hour';
  }

  @override
  String get insightsOnThisDay => 'Что было тогда';

  @override
  String get insightsMediaCounters => 'Медиа';

  @override
  String get insightsPhotos => 'Фото';

  @override
  String get insightsVideos => 'Видео';

  @override
  String get insightsVoiceNotes => 'Голосовые';

  @override
  String get insightsRoundVideos => 'Кружочки';

  @override
  String get insightsEmptyPeriod => 'В этом периоде пока нет заметок';

  @override
  String get insightsEmptyEmotions =>
      'Отмечайте эмоции в заметках, чтобы увидеть это';

  @override
  String get insightsEmptyPairs =>
      'Отметьте в заметке две эмоции, чтобы увидеть пары';

  @override
  String get insightsEmptyOnThisDay =>
      'Неделю, месяц, полгода и год назад пока ничего нет';

  @override
  String get insightsEmptyRoundVideos =>
      'За этот период нет голосовых и кружков';

  @override
  String get insightsEmptyStreak =>
      'Добавьте заметку сегодня, чтобы начать серию';

  @override
  String get insightsCustomize => 'Настроить аналитику';

  @override
  String get insightsCustomizeDescription =>
      'Включайте и выключайте карточки, перетаскивайте для порядка';

  @override
  String get insightsResetLayout => 'Сбросить';

  @override
  String get activeTasks => 'Активные задачи';

  @override
  String get galleryIndex => 'Индекс галереи';

  @override
  String get galleryIndexNoAccess => 'Нет доступа к Фото';

  @override
  String get galleryIndexNotIndexed => 'Ещё не проиндексировано';

  @override
  String galleryIndexIndexing(String done, String total) {
    return 'Индексация $done из $total';
  }

  @override
  String galleryIndexReady(String count, String time) {
    return '$count фото и видео · обновлено $time';
  }

  @override
  String galleryIndexThumbnails(String size) {
    return 'Кеш миниатюр: $size';
  }

  @override
  String get galleryIndexRebuildTitle => 'Пересобрать индекс галереи?';

  @override
  String get galleryIndexRebuildMessage =>
      'Миниатюры будут удалены, а медиатека просканирована заново.';

  @override
  String get galleryIndexRebuild => 'Пересобрать';

  @override
  String get settings => 'Настройки';

  @override
  String get userData => 'Данные пользователя';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get interfaceStyle => 'Стиль интерфейса';

  @override
  String get exportToCsv => 'Экспорт в CSV';

  @override
  String get exportData => 'Экспорт данных';

  @override
  String get importData => 'Импорт данных';

  @override
  String get done => 'ГОТОВО';

  @override
  String get chatWithAI => 'Чат с ИИ';

  @override
  String get photosPerDay => 'Фото в день';

  @override
  String get extraActions => 'Дополнительные действия';

  @override
  String get mindOptions => 'Параметры заметки';

  @override
  String get edit => 'Редактировать';

  @override
  String get delete => 'Удалить';

  @override
  String get share => 'Поделиться';

  @override
  String get saveToFiles => 'Сохранить в файлы';

  @override
  String get switchDay => 'Поменять день';

  @override
  String get goToDate => 'Перейти к дате';

  @override
  String get showDigest => 'Показать сводку для ...';

  @override
  String get translateToEnglish => 'Перевести на английский';

  @override
  String get convertToStandalone => 'Преобразовать в отдельную';

  @override
  String get language => 'Язык';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get theme => 'Тема';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeSystem => 'Система';

  @override
  String get showDayDividers => 'Показывать разделители дней';

  @override
  String get tabsSettings => 'Настройки вкладок';

  @override
  String get whatsNew => 'Что нового?';

  @override
  String get releaseNotes => 'История версий';

  @override
  String get suggestFeature => 'Предложить функцию';

  @override
  String get sendFeedback => 'Отправить отзыв';

  @override
  String get emailUs => 'Напишите нам на email';

  @override
  String get clearOfflineDataWarning =>
      'Все ваши офлайн данные будут удалены. Убедитесь, что вы уже экспортировали их.';

  @override
  String get sourceCode => 'Исходный код';

  @override
  String get termsOfUse => 'Условия использования';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get clearOnDeviceData => 'Очистить данные на устройстве';

  @override
  String get setOpenAIToken => 'Установить токен Open AI';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get mind => 'Заметка';

  @override
  String get profile => 'Профиль';

  @override
  String get insights => 'Профиль';

  @override
  String get calendar => 'Календарь';

  @override
  String get debugMenu => 'Меню отладки';

  @override
  String get discussion => 'Обсуждение';

  @override
  String get about => 'О программе';

  @override
  String get dangerZone => 'Опасная зона';

  @override
  String get enterTokenHere => 'Введите токен здесь';

  @override
  String get token => 'Токен';

  @override
  String get clearCache => 'Очистить кэш';

  @override
  String get activeTabs => 'Активные вкладки';

  @override
  String get hiddenTabs => 'Скрытые вкладки';

  @override
  String get error => 'Ошибка';

  @override
  String get startDiscussion => 'Начать обсуждение';

  @override
  String get send => 'ОТПРАВИТЬ';

  @override
  String get create => 'Создать';

  @override
  String get yourFolderName => 'Название вашей папки';

  @override
  String get noMindsInSelectedPeriod => 'Нет заметок в выбранном периоде';

  @override
  String get noMindsForPeriod => 'Нет заметок за этот период';

  @override
  String get selectPeriod => 'Выберите период ...';

  @override
  String get digest => 'Сводка';

  @override
  String get minds => 'Заметки';

  @override
  String get searchYourEmoji => 'Поиск вашего эмодзи...';

  @override
  String get writeSomething => 'Напишите что-нибудь...';

  @override
  String get todayMinds => 'Сегодняшние заметки';

  @override
  String get youDidNotCollectAnyEntriesYet =>
      'Вы еще не собрали ни одной записи';

  @override
  String get areYouSure => 'Вы уверены?';

  @override
  String get cannotRemoveMainScreen =>
      'Невозможно удалить главный экран. Вы потеряете возможность настраивать вкладки.';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String get thisWeek => 'Эта неделя';

  @override
  String get lastTwoWeeks => 'Последние 2 недели';

  @override
  String get thisMonth => 'Этот месяц';

  @override
  String get thisYear => 'Этот год';

  @override
  String get calendarDescription => 'Главный экран с календарем записей';

  @override
  String get insightsDescription => 'Вы и статистика ваших записей';

  @override
  String get settingsDescription =>
      'Экран со всеми настройками (темный режим, синхронизация и т.д.)';

  @override
  String get todayDescription => 'Только сегодняшние заметки';

  @override
  String get debugMenuDescription =>
      'Инструменты разработчика для переключения экспериментальных функций';

  @override
  String get noMindsForThisDay => 'Нет заметок за этот день';

  @override
  String get week => 'Неделя';

  @override
  String get password => 'Пароль';

  @override
  String get archivePassword => 'Пароль архива';

  @override
  String get enterPassword => 'Введите пароль';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get reenterPassword => 'Введите пароль повторно';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get exportPassword => 'Экспорт в ZIP';

  @override
  String get exportPasswordDescription =>
      'Добавьте пароль для шифрования экспорта. Вы можете пропустить это для незашифрованного экспорта.';

  @override
  String get importPassword => 'Введите пароль';

  @override
  String get importPasswordDescription =>
      'Этот файл защищен паролем. Пожалуйста, введите пароль для расшифровки.';

  @override
  String get skipPassword => 'Пропустить (без пароля)';

  @override
  String get continue_ => 'Продолжить';

  @override
  String get incorrectPassword => 'Неверный пароль';

  @override
  String get incorrectPasswordMessage =>
      'Введенный пароль неверен. Пожалуйста, попробуйте снова.';

  @override
  String get corruptedFile => 'Поврежденный файл';

  @override
  String get invalidFormat => 'Неверный формат';

  @override
  String get missingAudioFiles => 'Некоторые аудиофайлы отсутствуют';

  @override
  String get insufficientStorage => 'Недостаточно памяти';

  @override
  String get unknownError => 'Неизвестная ошибка';

  @override
  String get retry => 'Повторить';

  @override
  String get ok => 'OK';

  @override
  String get exportSuccess => 'Экспорт выполнен успешно';

  @override
  String get exportError => 'Экспорт не удался';

  @override
  String get importSuccess => 'Импорт выполнен успешно';

  @override
  String get importError => 'Импорт не удался';

  @override
  String get mindsToExport => 'Заметки';

  @override
  String get audioFilesToExport => 'Аудиофайлы';

  @override
  String get emotionsToExport => 'Эмоции';

  @override
  String get mindsExported => 'Заметки экспортированы';

  @override
  String get audioFilesExported => 'Аудиофайлы экспортированы';

  @override
  String get mindsImported => 'Заметки импортированы';

  @override
  String get audioFilesImported => 'Аудиофайлы импортированы';

  @override
  String get onboardingMind1 => 'Привет!';

  @override
  String get onboardingMind2 => 'Я keklist - личный дневник коротких заметок';

  @override
  String get onboardingMind2Comment1 => 'Заметки можно комментировать';

  @override
  String get onboardingMind2Comment2 => 'Чтобы открыть заметку, нажмите на неё';

  @override
  String get onboardingMind3 =>
      'На вкладке \'Календарь\' все заметки отображаются по дням, неделям и месяцам';

  @override
  String get onboardingMind4 =>
      'Вкладка \'Аналитика\' показывает краткую статистику ваших записей';

  @override
  String get onboardingMind5 => 'Все заметки хранятся только на вашем телефоне';

  @override
  String get onboardingMind6 =>
      'Чтобы создать новую заметку, нажмите \'Написать\'';

  @override
  String get noPhotosForDay => 'Нет фотографий за этот день';

  @override
  String get sourcesMediaFolder => 'Медиафайлы';

  @override
  String get sourcesMediaFolderSubtitle => 'Фото и видео из выбранной папки';

  @override
  String get mediaFolderSettings => 'Медиафайлы';

  @override
  String get licenses => 'Лицензии';

  @override
  String get sourcesWeather => 'Погода';

  @override
  String get sourcesWeatherSubtitle => 'Местные погодные условия за этот день';

  @override
  String get weatherSettings => 'Настройки погоды';

  @override
  String get weatherLatitude => 'Широта';

  @override
  String get weatherLongitude => 'Долгота';

  @override
  String get weatherSaveLocation => 'Сохранить местоположение';

  @override
  String get weatherUseMyLocation => 'Использовать моё местоположение';

  @override
  String get weatherDetectingLocation => 'Определение местоположения...';

  @override
  String get weatherOrEnterManually => 'или введите вручную';

  @override
  String get weatherLocationError =>
      'Не удалось определить местоположение. Введите вручную.';

  @override
  String get weatherLocationServicesDisabled =>
      'Службы геолокации отключены. Включите их в настройках.';

  @override
  String get weatherLocationPermissionDenied =>
      'Разрешение на геолокацию отклонено.';

  @override
  String get weatherLocationPermissionPermanentlyDenied =>
      'Доступ к геолокации заблокирован. Открываю настройки приложения.';

  @override
  String get audioRecordTitle => 'Запись аудио';

  @override
  String get audioRecordTitleRecording => 'Запись…';

  @override
  String get audioRecordHint => 'Нажмите «Стоп», чтобы сохранить запись.';

  @override
  String get audioRecordStart => 'Начать';

  @override
  String get audioRecordStop => 'Стоп';

  @override
  String get audioRecordCancel => 'Отмена';

  @override
  String get audioRecordPermissionError =>
      'Для записи аудио необходимо разрешение на использование микрофона.';

  @override
  String get audioRecordStartError =>
      'Не удалось начать запись. Попробуйте ещё раз.';

  @override
  String get audioRecordStopError =>
      'Не удалось остановить запись. Попробуйте ещё раз.';

  @override
  String proUserFooter(String price, String date) {
    return 'Вы PRO пользователь. Следующий платёж $price будет $date.';
  }

  @override
  String get emotions => 'Эмоции';

  @override
  String get archived => 'Архив';

  @override
  String get archive => 'Архивировать';

  @override
  String get restore => 'Восстановить';

  @override
  String get deletePermanently => 'Удалить навсегда';

  @override
  String get newEmotion => 'Новая эмоция';

  @override
  String get editEmotion => 'Изменить эмоцию';

  @override
  String get addEmotion => 'Добавить эмоцию';

  @override
  String get addEmotionsToMind => 'Добавить эмоции';

  @override
  String get emotionNameHint => 'Название';

  @override
  String get doneEditing => 'Готово';

  @override
  String get emotionEditHint =>
      'Нажмите, чтобы переименовать · ✕ чтобы удалить · перетащите, чтобы упорядочить';

  @override
  String get emotionInUseMessage =>
      'Эта эмоция используется в некоторых миндах. Архивируйте, чтобы сохранить её там, или удалите везде.';

  @override
  String get noEmotionsYet => 'Пока нет эмоций';

  @override
  String get noArchivedEmotions => 'Нет архивных эмоций';

  @override
  String get deleteEmotionMessage =>
      'Удалить эту эмоцию? Она будет удалена из всех минд, где используется.';

  @override
  String get dayFeedTileSettings => 'Настройки плиток';

  @override
  String get dayFeedColumns => 'Колонки';

  @override
  String get dayFeedMindTileSize => 'Размер плитки минда';

  @override
  String get dayFeedMindTileSquare => 'Квадрат';

  @override
  String get dayFeedMindTileWide => 'Широкая';

  @override
  String get dayFeedShowMindText => 'Показывать текст';

  @override
  String get dayFeedPhotoAccessHint =>
      'Разрешите доступ к фото, чтобы видеть здесь фото и видео';

  @override
  String get dayFeedAllowAccess => 'Разрешить';

  @override
  String get dayFeedFolderHint =>
      'Выберите папку с медиа, чтобы видеть здесь фото и видео';

  @override
  String get dayFeedChooseFolder => 'Выбрать';

  @override
  String get holdToRecordAudio => 'Удерживайте, чтобы записать голосовое';

  @override
  String get holdToRecordVideo => 'Удерживайте, чтобы записать видеосообщение';

  @override
  String get roundVideoRecordError => 'Не удалось записать видео';

  @override
  String get roundVideoCameraUnavailable =>
      'Камера недоступна на этом устройстве';

  @override
  String get roundVideoRetake => 'Переснять';

  @override
  String get roundVideoUse => 'Использовать';

  @override
  String get removeMedia => 'Удалить медиа';

  @override
  String get shakeToCustomize => 'Встряхните, чтобы настроить';

  @override
  String get shakeToCustomizeHint => 'или удерживайте заголовок';

  @override
  String get customizeSettings => 'Настройка экрана';

  @override
  String get customizeSettingsDescription =>
      'Снятые разделы и пункты скрываются с экрана настроек.';

  @override
  String get calendarSettings => 'Настройки календаря';

  @override
  String get calendarShowMedia => 'Показывать фото и видео';

  @override
  String get calendarWeekTitles => 'Заголовки недель';

  @override
  String get calendarPlayStories => 'Смотреть истории';

  @override
  String get storyBackgroundTweak => 'Фон историй';

  @override
  String get storyAnimationOff => 'Выкл';

  @override
  String get storyAnimationPulse => 'Пульс';

  @override
  String get storyAnimationWave => 'Волна';

  @override
  String get storyAnimationEqualizer => 'Эквалайзер';

  @override
  String get storyAnimationDrift => 'Дрейф';

  @override
  String get storyAnimationGlow => 'Свечение';

  @override
  String get viewerCommentHint => 'Комментарий…';

  @override
  String get calendarToCurrentWeek => 'К текущей неделе';

  @override
  String get storyDateLines => 'Строки даты';

  @override
  String get storyTextureTitle => 'Текстура';

  @override
  String get storySpectrum => 'Спектр звука';

  @override
  String get storySensitivity => 'Чувствительность';

  @override
  String profileMindfulDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Осознанно $count дня',
      many: 'Осознанно $count дней',
      few: 'Осознанно $count дня',
      one: 'Осознанно $count день',
    );
    return '$_temp0';
  }

  @override
  String get profileName => 'Имя';

  @override
  String get profilePhoto => 'Фото';

  @override
  String get profileEmoji => 'Эмодзи';

  @override
  String get profileInitial => 'Буква';

  @override
  String get webVersion => 'Веб-версия';

  @override
  String get webVersionAddressHint =>
      'Откройте в браузере компьютера в той же Wi‑Fi; keklist должен быть открыт';

  @override
  String get webVersionCopied => 'Адрес скопирован';

  @override
  String get webVersionNeedsPin =>
      'Задайте PIN, чтобы открыть keklist в браузере компьютера в той же Wi‑Fi.';

  @override
  String get webVersionStarting => 'Запуск…';

  @override
  String get webVersionNoWifi =>
      'Подключитесь к Wi‑Fi, чтобы открыть keklist в браузере.';

  @override
  String get webVersionNoBundle => 'В эту сборку не входит веб-версия.';

  @override
  String get webVersionPin => 'PIN';

  @override
  String get webVersionPinSet => 'Каждый браузер спрашивает его раз в 30 дней';

  @override
  String get webVersionPinNotSet => 'Не задан';

  @override
  String get webVersionPinHint => '4–8 цифр';

  @override
  String get webVersionRemovePin => 'Удалить PIN';

  @override
  String get webVersionPort => 'Порт';

  @override
  String get aiTab => 'Чат';

  @override
  String get aiTabDescription =>
      'Обсуждайте свои записи с AI, который работает на телефоне';

  @override
  String get aiPrivacyNote =>
      'Работает только на телефоне: записи не покидают устройство.';

  @override
  String get aiDisclaimer =>
      'Это не медицинская помощь. Если вы в опасности, обратитесь в экстренные службы.';

  @override
  String get aiYesterday => 'Вчера';

  @override
  String get aiNoSessions => 'Сессий пока нет';

  @override
  String get aiNewSession => 'Новая сессия';

  @override
  String get aiChooseRole => 'Выберите роль';

  @override
  String get aiRoleTherapist => 'Терапевт';

  @override
  String get aiRoleCoach => 'Коуч';

  @override
  String get aiRoleFriend => 'Друг';

  @override
  String get aiMessageHint => 'Сообщение';

  @override
  String get aiStarterWeek => 'Как прошла моя неделя?';

  @override
  String get aiStarterWorry => 'Что меня тревожит в последнее время?';

  @override
  String get aiStarterJoy => 'Что меня радовало в последнее время?';

  @override
  String get aiActionSaveAsMind => 'Сохранить как майнд';

  @override
  String get aiActionOpenDay => 'Открыть день';

  @override
  String get aiActionWeekSummary => 'Сводка недели';

  @override
  String get aiWeekSummaryPrompt =>
      'Подведи итог моих последних 7 дней: что происходило, что я чувствовал, что выделялось.';

  @override
  String get aiSavedAsMind => 'Сохранено в сегодня';

  @override
  String get aiStop => 'Стоп';

  @override
  String get aiNoModelTitle => 'Выберите модель';

  @override
  String get aiNoModelMessage =>
      'Скачайте модель, чтобы начать. Она работает на телефоне, без интернета.';

  @override
  String get aiNoModelOnPhone =>
      'Скачайте модель в приложении на телефоне: Настройки → AI → Модели.';

  @override
  String get aiModels => 'Модели';

  @override
  String get aiRoles => 'Роли';

  @override
  String get aiDownloaded => 'Скачанные';

  @override
  String get aiDownloads => 'Скачиваются';

  @override
  String get aiGalleryCatalog => 'Google AI Edge Gallery';

  @override
  String get aiHuggingFace => 'Hugging Face (GGUF)';

  @override
  String get aiSearchModels => 'Поиск GGUF-моделей';

  @override
  String get aiDownload => 'Скачать';

  @override
  String get aiPause => 'Пауза';

  @override
  String get aiPaused => 'На паузе';

  @override
  String get aiResume => 'Продолжить';

  @override
  String get aiDownloadFailed => 'Не удалось скачать';

  @override
  String get aiCellularTitle => 'Скачать через мобильную сеть?';

  @override
  String aiCellularMessage(String size) {
    return '$size будет скачано через мобильную сеть.';
  }

  @override
  String get aiDeleteModel => 'Удалить модель?';

  @override
  String aiStorageUsed(String size) {
    return 'На телефоне: $size';
  }

  @override
  String aiDeviceMemory(String size) {
    return 'Память телефона: $size';
  }

  @override
  String get aiCatalogFailed =>
      'Не удалось загрузить список. Проверьте подключение.';

  @override
  String get aiNoFilesFit =>
      'Ни один файл этой модели не помещается в память телефона.';

  @override
  String get aiBuiltInRole => 'Встроенные';

  @override
  String get aiOwnRoles => 'Ваши роли';

  @override
  String get aiDuplicate => 'Дублировать';

  @override
  String get aiNewRole => 'Новая роль';

  @override
  String get aiRoleName => 'Название';

  @override
  String get aiRoleEmoji => 'Эмодзи';

  @override
  String get aiRolePrompt => 'Промпт';

  @override
  String get aiRolePromptHint =>
      'Как AI должен разговаривать и на чём сосредоточиться';

  @override
  String get aiReadOnlyRole =>
      'Встроенные роли нельзя менять. Продублируйте роль, чтобы сделать свою.';

  @override
  String get aiDeleteSession => 'Удалить сессию?';

  @override
  String get aiDeleteRole => 'Удалить роль?';

  @override
  String get aiRecommended => 'Рекомендуем';

  @override
  String get aiLowQuality => 'Слабое качество';

  @override
  String get aiModelDoesNotFit =>
      'Эта модель не помещается в память телефона. Выберите модель поменьше.';

  @override
  String get aiChooseAnotherModel => 'Выбрать другую модель';

  @override
  String get creatorEmotionsTitle => 'Эмоции';

  @override
  String get creatorEmotionsAfterSave => 'Спросить после сохранения';

  @override
  String get creatorEmotionsButton => 'Кнопка над клавиатурой';

  @override
  String get creatorEmotionsNever => 'Не спрашивать';

  @override
  String get insightsWeekAgo => 'Неделю назад';

  @override
  String get insightsMonthAgo => 'Месяц назад';

  @override
  String get insightsHalfYearAgo => 'Полгода назад';

  @override
  String get insightsYearAgo => 'Год назад';

  @override
  String get insightsTwoYearsAgo => '2 года назад';

  @override
  String get insightsVoiceAndVideos => 'Голосовые и кружки';

  @override
  String insightsWeekNumber(String number) {
    return 'Неделя $number';
  }

  @override
  String get aiNoSessionsHint =>
      'Спросите о своей неделе, тревоге или хорошем дне: чат читает ваши записи прямо на телефоне.';
}
