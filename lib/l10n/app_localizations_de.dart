// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get insightsBrightestPeriod => 'Intensivster Zeitraum';

  @override
  String get insightsPeriodWeek => 'Woche';

  @override
  String get insightsPeriodMonth => 'Monat';

  @override
  String get insightsPeriodYear => 'Jahr';

  @override
  String get insightsPeriodAllTime => 'Gesamt';

  @override
  String insightsVsLastWeek(String delta) {
    return '$delta ggü. letzter Woche';
  }

  @override
  String insightsVsLastMonth(String delta) {
    return '$delta ggü. letztem Monat';
  }

  @override
  String insightsVsLastYear(String delta) {
    return '$delta ggü. letztem Jahr';
  }

  @override
  String get insightsCategorySummary => 'Übersicht';

  @override
  String get insightsCategoryEmotions => 'Emotionen';

  @override
  String get insightsCategoryActivity => 'Aktivität';

  @override
  String get insightsCategoryMemories => 'Erinnerungen';

  @override
  String get insightsCategoryMedia => 'Medien';

  @override
  String get insightsCounters => 'In Zahlen';

  @override
  String get insightsMinds => 'Notizen';

  @override
  String get insightsActiveDays => 'Aktive Tage';

  @override
  String get insightsWords => 'Wörter';

  @override
  String get insightsBrightestDay => 'Intensivster Tag';

  @override
  String get insightsBrightestWeek => 'Intensivste Woche';

  @override
  String get insightsBrightestMonth => 'Intensivster Monat';

  @override
  String get insightsBrightestYear => 'Intensivstes Jahr';

  @override
  String insightsBrightestDetails(String minds, String emotions, String media) {
    return '$minds Notizen · $emotions Emotionen · $media Medien';
  }

  @override
  String get insightsEmotionDistribution => 'Emotionen';

  @override
  String get insightsEmotionTrend => 'Emotionsverlauf';

  @override
  String get insightsEmotionPairs => 'Emotionen zusammen';

  @override
  String get insightsEmotionRhythm => 'Emotionaler Rhythmus';

  @override
  String get insightsByWeekday => 'Nach Wochentag';

  @override
  String get insightsByDayPart => 'Nach Tageszeit';

  @override
  String get insightsNight => 'Nacht';

  @override
  String get insightsMorning => 'Morgen';

  @override
  String get insightsAfternoon => 'Nachmittag';

  @override
  String get insightsEvening => 'Abend';

  @override
  String get insightsStreak => 'Serie';

  @override
  String get insightsStreakLabel => 'Tage in Folge';

  @override
  String insightsLongestStreak(String count) {
    return 'Rekord: $count';
  }

  @override
  String get insightsStreakKeepGoing =>
      'Füge heute eine Notiz hinzu, um weiterzumachen';

  @override
  String get insightsHeatmap => 'Aktivitätskarte';

  @override
  String get insightsActivityTime => 'Tageszeit';

  @override
  String insightsPeakHour(String hour) {
    return 'Am aktivsten gegen $hour';
  }

  @override
  String get insightsOnThisDay => 'An diesem Tag';

  @override
  String get insightsMediaCounters => 'Medien';

  @override
  String get insightsPhotos => 'Fotos';

  @override
  String get insightsVideos => 'Videos';

  @override
  String get insightsVoiceNotes => 'Sprachnotizen';

  @override
  String get insightsRoundVideos => 'Rundvideos';

  @override
  String get insightsEmptyPeriod => 'Noch keine Notizen in diesem Zeitraum';

  @override
  String get insightsEmptyEmotions =>
      'Markiere Notizen mit Emotionen, um das zu sehen';

  @override
  String get insightsEmptyPairs =>
      'Markiere eine Notiz mit zwei Emotionen, um Paare zu sehen';

  @override
  String get insightsEmptyOnThisDay =>
      'Noch nichts von diesem Tag aus früheren Jahren';

  @override
  String get insightsEmptyRoundVideos => 'Keine Rundvideos in diesem Zeitraum';

  @override
  String get insightsEmptyStreak =>
      'Füge heute eine Notiz hinzu, um eine Serie zu starten';

  @override
  String get insightsCustomize => 'Analysen anpassen';

  @override
  String get insightsCustomizeDescription =>
      'Karten ein- oder ausschalten und zum Sortieren ziehen';

  @override
  String get insightsResetLayout => 'Zurücksetzen';

  @override
  String get activeTasks => 'Aktive Aufgaben';

  @override
  String get galleryIndex => 'Galerie-Index';

  @override
  String get galleryIndexNoAccess => 'Kein Zugriff auf Fotos';

  @override
  String get galleryIndexNotIndexed => 'Noch nicht indexiert';

  @override
  String galleryIndexIndexing(String done, String total) {
    return 'Indexiere $done von $total';
  }

  @override
  String galleryIndexReady(String count, String time) {
    return '$count Fotos und Videos · aktualisiert $time';
  }

  @override
  String galleryIndexThumbnails(String size) {
    return 'Miniaturen-Cache: $size';
  }

  @override
  String get galleryIndexRebuildTitle => 'Galerie-Index neu aufbauen?';

  @override
  String get galleryIndexRebuildMessage =>
      'Miniaturen werden gelöscht und die Mediathek neu durchsucht.';

  @override
  String get galleryIndexRebuild => 'Neu aufbauen';

  @override
  String get allEmotions => 'Alle…';

  @override
  String get settings => 'Einstellungen';

  @override
  String get userData => 'Benutzerdaten';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get interfaceStyle => 'Oberflächenstil';

  @override
  String get exportToCsv => 'In CSV exportieren';

  @override
  String get exportData => 'Daten exportieren';

  @override
  String get importData => 'Daten importieren';

  @override
  String get done => 'FERTIG';

  @override
  String get chatWithAI => 'Mit KI chatten';

  @override
  String get photosPerDay => 'Fotos pro Tag';

  @override
  String get extraActions => 'Zusätzliche Aktionen';

  @override
  String get mindOptions => 'Notiz-Optionen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get share => 'Teilen';

  @override
  String get saveToFiles => 'In Dateien speichern';

  @override
  String get switchDay => 'Tag wechseln';

  @override
  String get goToDate => 'Zu Datum gehen';

  @override
  String get showDigest => 'Zusammenfassung anzeigen für ...';

  @override
  String get translateToEnglish => 'Ins Englische übersetzen';

  @override
  String get convertToStandalone => 'In eigenständig konvertieren';

  @override
  String get language => 'Sprache';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get theme => 'Erscheinungsbild';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeSystem => 'System';

  @override
  String get showDayDividers => 'Tages-Trennlinien anzeigen';

  @override
  String get tabsSettings => 'Tab-Einstellungen';

  @override
  String get whatsNew => 'Was ist neu?';

  @override
  String get releaseNotes => 'Versionshinweise';

  @override
  String get suggestFeature => 'Funktion vorschlagen';

  @override
  String get sendFeedback => 'Feedback senden';

  @override
  String get emailUs => 'Schreib uns eine E-Mail';

  @override
  String get clearOfflineDataWarning =>
      'Alle deine Offline-Daten werden gelöscht. Stelle sicher, dass du sie bereits exportiert hast.';

  @override
  String get sourceCode => 'Quellcode';

  @override
  String get termsOfUse => 'Nutzungsbedingungen';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get clearOnDeviceData => 'Gerätedaten löschen';

  @override
  String get setOpenAIToken => 'Open AI Token setzen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get mind => 'Notiz';

  @override
  String get profile => 'Profil';

  @override
  String get insights => 'Einblicke';

  @override
  String get calendar => 'Kalender';

  @override
  String get debugMenu => 'Debug-Menü';

  @override
  String get discussion => 'Diskussion';

  @override
  String get about => 'Über';

  @override
  String get dangerZone => 'Gefahrenzone';

  @override
  String get enterTokenHere => 'Token hier eingeben';

  @override
  String get token => 'Token';

  @override
  String get clearCache => 'Cache leeren';

  @override
  String get activeTabs => 'Aktive Tabs';

  @override
  String get hiddenTabs => 'Versteckte Tabs';

  @override
  String get error => 'Fehler';

  @override
  String get startDiscussion => 'Diskussion beginnen';

  @override
  String get send => 'SENDEN';

  @override
  String get create => 'Erstellen';

  @override
  String get yourFolderName => 'Ihr Ordnername';

  @override
  String get noMindsInSelectedPeriod =>
      'Keine Notizen im ausgewählten Zeitraum';

  @override
  String get noMindsForPeriod => 'Keine Notizen für diesen Zeitraum';

  @override
  String get selectPeriod => 'Zeitraum auswählen ...';

  @override
  String get digest => 'Zusammenfassung';

  @override
  String get minds => 'Notizen';

  @override
  String get searchForYourNotes => 'Suchen Sie nach Ihren Notizen';

  @override
  String get searchYourEmoji => 'Suchen Sie nach Ihrem Emoji...';

  @override
  String get writeSomething => 'Schreiben Sie etwas...';

  @override
  String get todayMinds => 'Heutige Notizen';

  @override
  String get youDidNotCollectAnyEntriesYet =>
      'Sie haben noch keine Einträge gesammelt';

  @override
  String get areYouSure => 'Sind Sie sicher?';

  @override
  String get cannotRemoveMainScreen =>
      'Hauptbildschirm kann nicht entfernt werden. Sie verlieren die Option, Tabs einzurichten.';

  @override
  String get today => 'Heute';

  @override
  String get yesterday => 'Gestern';

  @override
  String get thisWeek => 'Diese Woche';

  @override
  String get lastTwoWeeks => 'Letzte 2 Wochen';

  @override
  String get thisMonth => 'Dieser Monat';

  @override
  String get thisYear => 'Dieses Jahr';

  @override
  String get calendarDescription => 'Hauptbildschirm mit Kalender der Einträge';

  @override
  String get insightsDescription => 'Statistiken aller Ihrer Einträge';

  @override
  String get settingsDescription =>
      'Bildschirm mit allen Einstellungen (Dunkler Modus, Synchronisierung usw.)';

  @override
  String get todayDescription => 'Nur heutige Notizen';

  @override
  String get debugMenuDescription =>
      'Entwickler-Tools zum Umschalten experimenteller Funktionen';

  @override
  String get noMindsForThisDay => 'Keine Notizen für diesen Tag';

  @override
  String get week => 'Woche';

  @override
  String get password => 'Passwort';

  @override
  String get archivePassword => 'Archiv-Passwort';

  @override
  String get enterPassword => 'Passwort eingeben';

  @override
  String get confirmPassword => 'Passwort bestätigen';

  @override
  String get reenterPassword => 'Passwort erneut eingeben';

  @override
  String get passwordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get exportPassword => 'In ZIP exportieren';

  @override
  String get exportPasswordDescription =>
      'Fügen Sie ein Passwort hinzu, um Ihren Export zu verschlüsseln. Sie können dies für einen unverschlüsselten Export überspringen.';

  @override
  String get importPassword => 'Passwort eingeben';

  @override
  String get importPasswordDescription =>
      'Diese Datei ist passwortgeschützt. Bitte geben Sie das Passwort zur Entschlüsselung ein.';

  @override
  String get skipPassword => 'Überspringen (kein Passwort)';

  @override
  String get continue_ => 'Weiter';

  @override
  String get incorrectPassword => 'Falsches Passwort';

  @override
  String get incorrectPasswordMessage =>
      'Das eingegebene Passwort ist falsch. Bitte versuchen Sie es erneut.';

  @override
  String get corruptedFile => 'Beschädigte Datei';

  @override
  String get invalidFormat => 'Ungültiges Format';

  @override
  String get missingAudioFiles => 'Einige Audiodateien fehlen';

  @override
  String get insufficientStorage => 'Unzureichender Speicherplatz';

  @override
  String get unknownError => 'Unbekannter Fehler';

  @override
  String get retry => 'Wiederholen';

  @override
  String get ok => 'OK';

  @override
  String get exportSuccess => 'Export erfolgreich';

  @override
  String get exportError => 'Export fehlgeschlagen';

  @override
  String get importSuccess => 'Import erfolgreich';

  @override
  String get importError => 'Import fehlgeschlagen';

  @override
  String get mindsToExport => 'Notizen';

  @override
  String get audioFilesToExport => 'Audiodateien';

  @override
  String get emotionsToExport => 'Emotionen';

  @override
  String get mindsExported => 'Notizen exportiert';

  @override
  String get audioFilesExported => 'Audiodateien exportiert';

  @override
  String get mindsImported => 'Notizen importiert';

  @override
  String get audioFilesImported => 'Audiodateien importiert';

  @override
  String get onboardingMind1 => 'Hallo!';

  @override
  String get onboardingMind2 =>
      'Ich bin keklist - ein persönliches Tagebuch für kurze Notizen';

  @override
  String get onboardingMind2Comment1 => 'Notizen können kommentiert werden';

  @override
  String get onboardingMind2Comment2 =>
      'Um eine Notiz zu öffnen, tippen Sie darauf';

  @override
  String get onboardingMind3 =>
      'Im Tab \'Kalender\' werden alle Notizen nach Tagen, Wochen und Monaten angezeigt';

  @override
  String get onboardingMind4 =>
      'Der Tab \'Analytik\' zeigt eine kurze Statistik Ihrer Einträge';

  @override
  String get onboardingMind5 =>
      'Alle Notizen werden nur auf Ihrem Telefon gespeichert';

  @override
  String get onboardingMind6 =>
      'Um eine neue Notiz zu erstellen, tippen Sie auf \'Schreiben\'';

  @override
  String get noPhotosForDay => 'Keine Fotos für diesen Tag gefunden';

  @override
  String get sourcesMediaFolder => 'Mediendateien';

  @override
  String get sourcesMediaFolderSubtitle =>
      'Fotos und Videos aus einem benutzerdefinierten Ordner';

  @override
  String get mediaFolderSettings => 'Mediendateien';

  @override
  String get licenses => 'Lizenzen';

  @override
  String get sourcesWeather => 'Wetter';

  @override
  String get sourcesWeatherSubtitle =>
      'Lokale Wetterbedingungen für diesen Tag';

  @override
  String get weatherSettings => 'Wettereinstellungen';

  @override
  String get weatherLatitude => 'Breitengrad';

  @override
  String get weatherLongitude => 'Längengrad';

  @override
  String get weatherSaveLocation => 'Standort speichern';

  @override
  String get weatherUseMyLocation => 'Meinen Standort verwenden';

  @override
  String get weatherDetectingLocation => 'Standort wird erkannt...';

  @override
  String get weatherOrEnterManually => 'oder manuell eingeben';

  @override
  String get weatherLocationError =>
      'Standort konnte nicht erkannt werden. Bitte manuell eingeben.';

  @override
  String get weatherLocationServicesDisabled =>
      'Standortdienste sind deaktiviert. Bitte in den Einstellungen aktivieren.';

  @override
  String get weatherLocationPermissionDenied =>
      'Standortberechtigung verweigert.';

  @override
  String get weatherLocationPermissionPermanentlyDenied =>
      'Standortberechtigung dauerhaft verweigert. App-Einstellungen werden geöffnet.';

  @override
  String get audioRecordTitle => 'Audio aufnehmen';

  @override
  String get audioRecordTitleRecording => 'Aufnahme läuft…';

  @override
  String get audioRecordHint =>
      'Tippe auf Stopp, um die Aufnahme zu speichern.';

  @override
  String get audioRecordStart => 'Starten';

  @override
  String get audioRecordStop => 'Stopp';

  @override
  String get audioRecordCancel => 'Abbrechen';

  @override
  String get audioRecordPermissionError =>
      'Mikrofonberechtigung ist erforderlich, um Audio aufzunehmen.';

  @override
  String get audioRecordStartError =>
      'Aufnahme konnte nicht gestartet werden. Bitte versuche es erneut.';

  @override
  String get audioRecordStopError =>
      'Aufnahme konnte nicht gestoppt werden. Bitte versuche es erneut.';

  @override
  String proUserFooter(String price, String date) {
    return 'Du bist PRO-Nutzer. Die nächste Zahlung von $price erfolgt am $date.';
  }

  @override
  String get emotions => 'Emotionen';

  @override
  String get archived => 'Archiviert';

  @override
  String get archive => 'Archivieren';

  @override
  String get restore => 'Wiederherstellen';

  @override
  String get deletePermanently => 'Endgültig löschen';

  @override
  String get newEmotion => 'Neue Emotion';

  @override
  String get editEmotion => 'Emotion bearbeiten';

  @override
  String get addEmotion => 'Emotion hinzufügen';

  @override
  String get addEmotionsToMind => 'Emotionen hinzufügen';

  @override
  String get emotionNameHint => 'Name';

  @override
  String get doneEditing => 'Fertig';

  @override
  String get emotionEditHint =>
      'Tippen zum Umbenennen · ✕ zum Entfernen · ziehen zum Sortieren';

  @override
  String get emotionInUseMessage =>
      'Diese Emotion wird von einigen Minds verwendet. Archiviere sie, um sie dort zu behalten, oder lösche sie überall.';

  @override
  String get emotionPickHint => 'Tippen zum Markieren';

  @override
  String get emotionDrillHint => 'lange drücken für mehr Tiefe';

  @override
  String get noEmotionsYet => 'Noch keine Emotionen';

  @override
  String get noArchivedEmotions => 'Keine archivierten Emotionen';

  @override
  String get deleteEmotionMessage =>
      'Diese Emotion löschen? Sie wird aus allen Minds entfernt, die sie verwenden.';

  @override
  String get dayFeedTileSettings => 'Kachel-Einstellungen';

  @override
  String get dayFeedColumns => 'Spalten';

  @override
  String get dayFeedMindTileSize => 'Kachelgröße';

  @override
  String get dayFeedMindTileSquare => 'Quadrat';

  @override
  String get dayFeedMindTileWide => 'Breit';

  @override
  String get dayFeedShowMindText => 'Text anzeigen';

  @override
  String get dayFeedPhotoAccessHint =>
      'Erlaube den Fotozugriff, um hier deine Fotos und Videos zu sehen';

  @override
  String get dayFeedAllowAccess => 'Erlauben';

  @override
  String get dayFeedFolderHint =>
      'Wähle einen Medienordner, um hier deine Fotos und Videos zu sehen';

  @override
  String get dayFeedChooseFolder => 'Wählen';

  @override
  String get dayFeedMute => 'Stummschalten';

  @override
  String get dayFeedUnmute => 'Ton an';

  @override
  String get holdToRecordAudio => 'Gedrückt halten für eine Sprachnachricht';

  @override
  String get holdToRecordVideo => 'Gedrückt halten für eine Videonachricht';

  @override
  String get roundVideoRecordError => 'Video konnte nicht aufgenommen werden';

  @override
  String get roundVideoCameraUnavailable =>
      'Kamera auf diesem Gerät nicht verfügbar';

  @override
  String get roundVideoRetake => 'Neu aufnehmen';

  @override
  String get roundVideoUse => 'Verwenden';

  @override
  String get removeMedia => 'Medien entfernen';

  @override
  String get shakeToCustomize => 'Schütteln zum Anpassen';

  @override
  String get shakeToCustomizeHint => 'oder Titel lange drücken';

  @override
  String get customizeSettings => 'Einstellungen anpassen';

  @override
  String get customizeSettingsDescription =>
      'Abgewählte Bereiche und Zeilen werden in den Einstellungen ausgeblendet.';

  @override
  String get calendarSettings => 'Kalendereinstellungen';

  @override
  String get calendarShowMedia => 'Fotos und Videos anzeigen';

  @override
  String get calendarWeekTitles => 'Wochentitel';

  @override
  String get calendarPlayStories => 'Storys abspielen';

  @override
  String get storyBackgroundTweak => 'Story-Hintergrund';

  @override
  String get storyAnimationOff => 'Aus';

  @override
  String get storyAnimationPulse => 'Puls';

  @override
  String get storyAnimationWave => 'Welle';

  @override
  String get storyAnimationEqualizer => 'Equalizer';

  @override
  String get storyAnimationDrift => 'Treiben';

  @override
  String get storyAnimationGlow => 'Leuchten';

  @override
  String get viewerCommentHint => 'Kommentar…';

  @override
  String get calendarToCurrentWeek => 'Zur aktuellen Woche';

  @override
  String get storyDateLines => 'Datumszeilen';

  @override
  String get storyTextureTitle => 'Textur';

  @override
  String get storySpectrum => 'Klangspektrum';

  @override
  String get storySensitivity => 'Empfindlichkeit';

  @override
  String profileMindfulDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Achtsam an $count Tagen',
      one: 'Achtsam an $count Tag',
    );
    return '$_temp0';
  }

  @override
  String get profileName => 'Name';

  @override
  String get profilePhoto => 'Foto';

  @override
  String get profileEmoji => 'Emoji';

  @override
  String get profileInitial => 'Buchstabe';

  @override
  String get webVersion => 'Webversion';

  @override
  String get webVersionAddressHint =>
      'Im Browser eines Computers im selben WLAN öffnen; keklist muss offen bleiben';

  @override
  String get webVersionCopied => 'Adresse kopiert';

  @override
  String get webVersionNeedsPin =>
      'Lege eine PIN fest, um keklist im Browser eines Computers im selben WLAN zu öffnen.';

  @override
  String get webVersionStarting => 'Wird gestartet…';

  @override
  String get webVersionNoWifi =>
      'Verbinde dich mit einem WLAN, um keklist im Browser zu öffnen.';

  @override
  String get webVersionNoBundle => 'Dieser Build enthält keine Webversion.';

  @override
  String get webVersionPin => 'PIN';

  @override
  String get webVersionPinSet =>
      'Jeder Browser fragt alle 30 Tage einmal danach';

  @override
  String get webVersionPinNotSet => 'Nicht festgelegt';

  @override
  String get webVersionPinHint => '4–8 Ziffern';

  @override
  String get webVersionRemovePin => 'PIN entfernen';

  @override
  String get webVersionPort => 'Port';

  @override
  String get aiTab => 'KI';

  @override
  String get aiTabDescription =>
      'Sprich mit einer KI auf deinem Handy über deine Einträge';

  @override
  String get aiPrivacyNote =>
      'Läuft nur auf deinem Handy: deine Einträge verlassen das Gerät nie.';

  @override
  String get aiDisclaimer =>
      'Kein medizinischer Dienst. Wenn du in Gefahr bist, wende dich an den Notruf.';

  @override
  String get aiDaySummaries => 'Tageszusammenfassungen';

  @override
  String get aiSummarize => 'Tippen zum Zusammenfassen';

  @override
  String get aiSummaryOutdated =>
      'Einträge geändert — tippen zum Aktualisieren';

  @override
  String get aiRegenerate => 'Neu schreiben';

  @override
  String get aiYesterday => 'Gestern';

  @override
  String get aiSessions => 'Sitzungen';

  @override
  String get aiNoSessions => 'Noch keine Sitzungen';

  @override
  String get aiNewSession => 'Neue Sitzung';

  @override
  String get aiChooseRole => 'Wähle eine Rolle';

  @override
  String get aiRoleTherapist => 'Therapeut';

  @override
  String get aiRoleCoach => 'Coach';

  @override
  String get aiRoleFriend => 'Freund';

  @override
  String get aiMessageHint => 'Nachricht';

  @override
  String get aiStarterWeek => 'Wie war meine Woche?';

  @override
  String get aiStarterWorry => 'Was beschäftigt mich in letzter Zeit?';

  @override
  String get aiStarterJoy => 'Was hat mir zuletzt Freude gemacht?';

  @override
  String get aiActionSaveAsMind => 'Als Eintrag speichern';

  @override
  String get aiActionOpenDay => 'Tag öffnen';

  @override
  String get aiActionWeekSummary => 'Wochenzusammenfassung';

  @override
  String get aiWeekSummaryPrompt =>
      'Fasse meine letzten 7 Tage zusammen: was passiert ist, wie ich mich gefühlt habe, was herausstach.';

  @override
  String get aiSavedAsMind => 'In Heute gespeichert';

  @override
  String get aiThinking => 'Denke nach…';

  @override
  String get aiStop => 'Stopp';

  @override
  String get aiNoModelTitle => 'Wähle ein Modell';

  @override
  String get aiNoModelMessage =>
      'Lade ein Modell herunter, um zu starten. Es läuft auf deinem Handy, offline.';

  @override
  String get aiNoModelOnPhone =>
      'Lade ein Modell in der App auf dem Handy: Einstellungen → KI → Modelle.';

  @override
  String get aiModels => 'Modelle';

  @override
  String get aiRoles => 'Rollen';

  @override
  String get aiDownloaded => 'Heruntergeladen';

  @override
  String get aiDownloads => 'Wird geladen';

  @override
  String get aiGalleryCatalog => 'Google AI Edge Gallery';

  @override
  String get aiHuggingFace => 'Hugging Face (GGUF)';

  @override
  String get aiSearchModels => 'GGUF-Modelle suchen';

  @override
  String get aiFastest => 'Am schnellsten';

  @override
  String get aiDownload => 'Herunterladen';

  @override
  String get aiPause => 'Pause';

  @override
  String get aiPaused => 'Pausiert';

  @override
  String get aiResume => 'Fortsetzen';

  @override
  String get aiDownloadFailed => 'Download fehlgeschlagen';

  @override
  String get aiCellularTitle => 'Über mobile Daten laden?';

  @override
  String aiCellularMessage(String size) {
    return '$size werden über mobile Daten geladen.';
  }

  @override
  String get aiDeleteModel => 'Modell löschen?';

  @override
  String aiStorageUsed(String size) {
    return 'Auf diesem Handy: $size';
  }

  @override
  String aiDeviceMemory(String size) {
    return 'Arbeitsspeicher: $size';
  }

  @override
  String get aiCatalogFailed =>
      'Liste konnte nicht geladen werden. Prüfe die Verbindung.';

  @override
  String get aiNoFilesFit =>
      'Keine Datei dieses Modells passt in den Speicher dieses Handys.';

  @override
  String get aiBuiltInRole => 'Integriert';

  @override
  String get aiOwnRoles => 'Deine Rollen';

  @override
  String get aiDuplicate => 'Duplizieren';

  @override
  String get aiNewRole => 'Neue Rolle';

  @override
  String get aiRoleName => 'Name';

  @override
  String get aiRoleEmoji => 'Emoji';

  @override
  String get aiRolePrompt => 'Prompt';

  @override
  String get aiRolePromptHint =>
      'Wie die KI sprechen und worauf sie achten soll';

  @override
  String get aiReadOnlyRole =>
      'Integrierte Rollen können nicht geändert werden. Dupliziere eine, um deine eigene zu erstellen.';

  @override
  String get aiDeleteSession => 'Sitzung löschen?';

  @override
  String get aiDeleteRole => 'Rolle löschen?';
}
