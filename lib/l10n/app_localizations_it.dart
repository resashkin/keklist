// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get insightsBrightestPeriod => 'Periodo più intenso';

  @override
  String get insightsPeriodWeek => 'Settimana';

  @override
  String get insightsPeriodMonth => 'Mese';

  @override
  String get insightsPeriodYear => 'Anno';

  @override
  String get insightsPeriodAllTime => 'Sempre';

  @override
  String insightsVsLastWeek(String delta) {
    return '$delta rispetto alla settimana scorsa';
  }

  @override
  String insightsVsLastMonth(String delta) {
    return '$delta rispetto al mese scorso';
  }

  @override
  String insightsVsLastYear(String delta) {
    return '$delta rispetto all\'anno scorso';
  }

  @override
  String get insightsCategorySummary => 'Riepilogo';

  @override
  String get insightsCategoryEmotions => 'Emozioni';

  @override
  String get insightsCategoryActivity => 'Attività';

  @override
  String get insightsCategoryMemories => 'Ricordi';

  @override
  String get insightsCategoryMedia => 'Media';

  @override
  String get insightsCounters => 'In numeri';

  @override
  String get insightsMinds => 'Note';

  @override
  String get insightsActiveDays => 'Giorni attivi';

  @override
  String get insightsWords => 'Parole';

  @override
  String get insightsBrightestDay => 'Giorno più intenso';

  @override
  String get insightsBrightestWeek => 'Settimana più intensa';

  @override
  String get insightsBrightestMonth => 'Mese più intenso';

  @override
  String get insightsBrightestYear => 'Anno più intenso';

  @override
  String insightsBrightestDetails(String minds, String emotions, String media) {
    return '$minds note · $emotions emozioni · $media media';
  }

  @override
  String get insightsEmotionDistribution => 'Emozioni';

  @override
  String get insightsEmotionTrend => 'Andamento delle emozioni';

  @override
  String get insightsEmotionPairs => 'Emozioni insieme';

  @override
  String get insightsEmotionRhythm => 'Ritmo emotivo';

  @override
  String get insightsByWeekday => 'Per giorno della settimana';

  @override
  String get insightsByDayPart => 'Per momento della giornata';

  @override
  String get insightsNight => 'Notte';

  @override
  String get insightsMorning => 'Mattina';

  @override
  String get insightsAfternoon => 'Pomeriggio';

  @override
  String get insightsEvening => 'Sera';

  @override
  String get insightsStreak => 'Serie';

  @override
  String get insightsStreakLabel => 'giorni di fila';

  @override
  String insightsLongestStreak(String count) {
    return 'Record: $count';
  }

  @override
  String get insightsStreakKeepGoing => 'Aggiungi una nota oggi per continuare';

  @override
  String get insightsHeatmap => 'Mappa dell\'attività';

  @override
  String get insightsActivityTime => 'Momento della giornata';

  @override
  String insightsPeakHour(String hour) {
    return 'Più attivo verso le $hour';
  }

  @override
  String get insightsOnThisDay => 'A quel tempo';

  @override
  String get insightsMediaCounters => 'Media';

  @override
  String get insightsPhotos => 'Foto';

  @override
  String get insightsVideos => 'Video';

  @override
  String get insightsVoiceNotes => 'Note vocali';

  @override
  String get insightsRoundVideos => 'Video circolari';

  @override
  String get insightsEmptyPeriod => 'Ancora nessuna nota in questo periodo';

  @override
  String get insightsEmptyEmotions => 'Tagga le note con emozioni per vederlo';

  @override
  String get insightsEmptyPairs =>
      'Tagga una nota con due emozioni per vedere le coppie';

  @override
  String get insightsEmptyOnThisDay =>
      'Ancora niente di una settimana, un mese, sei mesi o un anno fa';

  @override
  String get insightsEmptyRoundVideos =>
      'Nessun vocale o video circolare in questo periodo';

  @override
  String get insightsEmptyStreak =>
      'Aggiungi una nota oggi per iniziare una serie';

  @override
  String get insightsCustomize => 'Personalizza analisi';

  @override
  String get insightsCustomizeDescription =>
      'Attiva o disattiva le schede e trascinale per riordinarle';

  @override
  String get insightsResetLayout => 'Ripristina';

  @override
  String get activeTasks => 'Attività in corso';

  @override
  String get galleryIndex => 'Indice della galleria';

  @override
  String get galleryIndexNoAccess => 'Nessun accesso a Foto';

  @override
  String get galleryIndexNotIndexed => 'Non ancora indicizzato';

  @override
  String galleryIndexIndexing(String done, String total) {
    return 'Indicizzazione $done di $total';
  }

  @override
  String galleryIndexReady(String count, String time) {
    return '$count foto e video · aggiornato $time';
  }

  @override
  String galleryIndexThumbnails(String size) {
    return 'Cache miniature: $size';
  }

  @override
  String get galleryIndexRebuildTitle =>
      'Ricostruire l\'indice della galleria?';

  @override
  String get galleryIndexRebuildMessage =>
      'Le miniature verranno eliminate e la libreria analizzata di nuovo.';

  @override
  String get galleryIndexRebuild => 'Ricostruisci';

  @override
  String get settings => 'Impostazioni';

  @override
  String get userData => 'Dati utente';

  @override
  String get appearance => 'Aspetto';

  @override
  String get interfaceStyle => 'Stile interfaccia';

  @override
  String get exportToCsv => 'Esporta in CSV';

  @override
  String get exportData => 'Esporta dati';

  @override
  String get importData => 'Importa dati';

  @override
  String get done => 'FATTO';

  @override
  String get chatWithAI => 'Chatta con AI';

  @override
  String get photosPerDay => 'Foto al giorno';

  @override
  String get extraActions => 'Azioni extra';

  @override
  String get mindOptions => 'Opzioni mente';

  @override
  String get edit => 'Modifica';

  @override
  String get delete => 'Elimina';

  @override
  String get share => 'Condividi';

  @override
  String get saveToFiles => 'Salva in file';

  @override
  String get switchDay => 'Cambia giorno';

  @override
  String get goToDate => 'Vai alla data';

  @override
  String get showDigest => 'Mostra riassunto per ...';

  @override
  String get translateToEnglish => 'Traduci in inglese';

  @override
  String get convertToStandalone => 'Converti in standalone';

  @override
  String get language => 'Lingua';

  @override
  String get selectLanguage => 'Seleziona Lingua';

  @override
  String get theme => 'Tema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get showDayDividers => 'Mostra divisori giorno';

  @override
  String get tabsSettings => 'Impostazioni tab';

  @override
  String get whatsNew => 'Cosa c\'è di nuovo?';

  @override
  String get releaseNotes => 'Note di rilascio';

  @override
  String get suggestFeature => 'Suggerisci una funzione';

  @override
  String get sendFeedback => 'Invia feedback';

  @override
  String get emailUs => 'Inviaci un\'email';

  @override
  String get clearOfflineDataWarning =>
      'Tutti i tuoi dati offline verranno eliminati. Assicurati di averli già esportati.';

  @override
  String get sourceCode => 'Codice sorgente';

  @override
  String get termsOfUse => 'Termini di Utilizzo';

  @override
  String get privacyPolicy => 'Politica sulla Privacy';

  @override
  String get clearOnDeviceData => 'Cancella dati sul dispositivo';

  @override
  String get setOpenAIToken => 'Imposta Token Open AI';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get mind => 'Mente';

  @override
  String get profile => 'Profilo';

  @override
  String get insights => 'Profilo';

  @override
  String get calendar => 'Calendario';

  @override
  String get debugMenu => 'Menu Debug';

  @override
  String get discussion => 'Discussione';

  @override
  String get about => 'Informazioni';

  @override
  String get dangerZone => 'Zona Pericolo';

  @override
  String get enterTokenHere => 'Inserisci token qui';

  @override
  String get token => 'Token';

  @override
  String get clearCache => 'Cancella cache';

  @override
  String get activeTabs => 'Tab attivi';

  @override
  String get hiddenTabs => 'Tab nascosti';

  @override
  String get error => 'Errore';

  @override
  String get startDiscussion => 'Avvia discussione';

  @override
  String get send => 'INVIA';

  @override
  String get create => 'Crea';

  @override
  String get yourFolderName => 'Nome della tua cartella';

  @override
  String get noMindsInSelectedPeriod => 'Nessuna mente nel periodo selezionato';

  @override
  String get noMindsForPeriod => 'Nessuna mente per questo periodo';

  @override
  String get selectPeriod => 'Seleziona periodo ...';

  @override
  String get digest => 'Riassunto';

  @override
  String get minds => 'Menti';

  @override
  String get searchYourEmoji => 'Cerca il tuo emoji...';

  @override
  String get writeSomething => 'Scrivi qualcosa...';

  @override
  String get todayMinds => 'Menti di oggi';

  @override
  String get youDidNotCollectAnyEntriesYet =>
      'Non hai ancora raccolto nessuna voce';

  @override
  String get areYouSure => 'Sei sicuro?';

  @override
  String get cannotRemoveMainScreen =>
      'Non puoi rimuovere la schermata principale. Perderai l\'opzione per configurare i tab.';

  @override
  String get today => 'Oggi';

  @override
  String get yesterday => 'Ieri';

  @override
  String get thisWeek => 'Questa settimana';

  @override
  String get lastTwoWeeks => 'Ultime 2 settimane';

  @override
  String get thisMonth => 'Questo mese';

  @override
  String get thisYear => 'Quest\'anno';

  @override
  String get calendarDescription =>
      'Schermata principale con Calendario delle voci';

  @override
  String get insightsDescription => 'Tu e le statistiche delle tue note';

  @override
  String get settingsDescription =>
      'Schermata con tutte le impostazioni (modalità scura, sincronizzazione e altro)';

  @override
  String get todayDescription => 'Solo menti di oggi';

  @override
  String get debugMenuDescription =>
      'Strumenti per sviluppatori per attivare funzionalità sperimentali';

  @override
  String get noMindsForThisDay => 'Nessuna mente per questo giorno';

  @override
  String get week => 'Settimana';

  @override
  String get password => 'Password';

  @override
  String get archivePassword => 'Password archivio';

  @override
  String get enterPassword => 'Inserisci password';

  @override
  String get confirmPassword => 'Conferma password';

  @override
  String get reenterPassword => 'Reinserisci password';

  @override
  String get passwordsDoNotMatch => 'Le password non corrispondono';

  @override
  String get exportPassword => 'Proteggere esportazione con password?';

  @override
  String get exportPasswordDescription =>
      'Aggiungi una password per crittografare la tua esportazione. Puoi saltare questo per esportazione non crittografata.';

  @override
  String get importPassword => 'Inserisci password';

  @override
  String get importPasswordDescription =>
      'Questo file è protetto da password. Per favore inserisci la password per decifrare.';

  @override
  String get skipPassword => 'Salta (senza password)';

  @override
  String get continue_ => 'Continua';

  @override
  String get incorrectPassword => 'Password errata';

  @override
  String get incorrectPasswordMessage =>
      'La password inserita è errata. Per favore riprova.';

  @override
  String get corruptedFile => 'File danneggiato';

  @override
  String get invalidFormat => 'Formato non valido';

  @override
  String get missingAudioFiles => 'Alcuni file audio mancano';

  @override
  String get insufficientStorage => 'Spazio di archiviazione insufficiente';

  @override
  String get unknownError => 'Errore sconosciuto';

  @override
  String get retry => 'Riprova';

  @override
  String get ok => 'OK';

  @override
  String get exportSuccess => 'Esportazione riuscita';

  @override
  String get exportError => 'Esportazione fallita';

  @override
  String get importSuccess => 'Importazione riuscita';

  @override
  String get importError => 'Importazione fallita';

  @override
  String get mindsToExport => 'Mind';

  @override
  String get audioFilesToExport => 'File audio';

  @override
  String get emotionsToExport => 'Emozioni';

  @override
  String get mindsExported => 'Mind esportate';

  @override
  String get audioFilesExported => 'File audio esportati';

  @override
  String get mindsImported => 'Mind importate';

  @override
  String get audioFilesImported => 'File audio importati';

  @override
  String get onboardingMind1 => 'Ciao!';

  @override
  String get onboardingMind2 =>
      'Sono keklist - un diario personale di note brevi';

  @override
  String get onboardingMind2Comment1 => 'Le note possono essere commentate';

  @override
  String get onboardingMind2Comment2 => 'Per aprire una nota, toccala';

  @override
  String get onboardingMind3 =>
      'Nella scheda \'Calendario\', tutte le note sono visualizzate per giorni, settimane e mesi';

  @override
  String get onboardingMind4 =>
      'La scheda \'Statistiche\' mostra brevi statistiche delle tue voci';

  @override
  String get onboardingMind5 =>
      'Tutte le note sono memorizzate solo sul tuo telefono';

  @override
  String get onboardingMind6 => 'Per creare una nuova nota, tocca \'Scrivi\'';

  @override
  String get noPhotosForDay => 'Nessuna foto trovata per questo giorno';

  @override
  String get sourcesMediaFolder => 'File multimediali';

  @override
  String get sourcesMediaFolderSubtitle =>
      'Foto e video da una cartella personalizzata';

  @override
  String get mediaFolderSettings => 'File multimediali';

  @override
  String get licenses => 'Licenze';

  @override
  String get sourcesWeather => 'Meteo';

  @override
  String get sourcesWeatherSubtitle =>
      'Condizioni meteorologiche locali per questo giorno';

  @override
  String get weatherSettings => 'Impostazioni meteo';

  @override
  String get weatherLatitude => 'Latitudine';

  @override
  String get weatherLongitude => 'Longitudine';

  @override
  String get weatherSaveLocation => 'Salva posizione';

  @override
  String get weatherUseMyLocation => 'Usa la mia posizione';

  @override
  String get weatherDetectingLocation => 'Rilevamento posizione...';

  @override
  String get weatherOrEnterManually => 'o inserisci manualmente';

  @override
  String get weatherLocationError =>
      'Impossibile rilevare la posizione. Inserisci manualmente.';

  @override
  String get weatherLocationServicesDisabled =>
      'I servizi di localizzazione sono disabilitati. Attivali nelle impostazioni.';

  @override
  String get weatherLocationPermissionDenied =>
      'Autorizzazione di localizzazione negata.';

  @override
  String get weatherLocationPermissionPermanentlyDenied =>
      'Autorizzazione di localizzazione negata in modo permanente. Apertura impostazioni app.';

  @override
  String get audioRecordTitle => 'Registra audio';

  @override
  String get audioRecordTitleRecording => 'Registrazione…';

  @override
  String get audioRecordHint => 'Tocca Stop per salvare sul tuo dispositivo.';

  @override
  String get audioRecordStart => 'Avvia';

  @override
  String get audioRecordStop => 'Ferma';

  @override
  String get audioRecordCancel => 'Annulla';

  @override
  String get audioRecordPermissionError =>
      'Il permesso per il microfono è necessario per registrare audio.';

  @override
  String get audioRecordStartError =>
      'Impossibile avviare la registrazione. Riprova.';

  @override
  String get audioRecordStopError =>
      'Impossibile fermare la registrazione. Riprova.';

  @override
  String proUserFooter(String price, String date) {
    return 'Sei un utente PRO. Il prossimo pagamento di $price sarà il $date.';
  }

  @override
  String get emotions => 'Emozioni';

  @override
  String get archived => 'Archiviate';

  @override
  String get archive => 'Archivia';

  @override
  String get restore => 'Ripristina';

  @override
  String get deletePermanently => 'Elimina definitivamente';

  @override
  String get newEmotion => 'Nuova emozione';

  @override
  String get editEmotion => 'Modifica emozione';

  @override
  String get addEmotion => 'Aggiungi emozione';

  @override
  String get addEmotionsToMind => 'Aggiungi emozioni';

  @override
  String get emotionNameHint => 'Nome';

  @override
  String get doneEditing => 'Fatto';

  @override
  String get emotionEditHint =>
      'Tocca per rinominare · ✕ per rimuovere · trascina per riordinare';

  @override
  String get emotionInUseMessage =>
      'Questa emozione è usata in alcune menti. Archiviala per mantenerla lì, o eliminala ovunque.';

  @override
  String get noEmotionsYet => 'Ancora nessuna emozione';

  @override
  String get noArchivedEmotions => 'Nessuna emozione archiviata';

  @override
  String get deleteEmotionMessage =>
      'Eliminare questa emozione? Verrà rimossa da tutte le menti che la usano.';

  @override
  String get dayFeedTileSettings => 'Impostazioni riquadri';

  @override
  String get dayFeedColumns => 'Colonne';

  @override
  String get dayFeedMindTileSize => 'Dimensione riquadro';

  @override
  String get dayFeedMindTileSquare => 'Quadrato';

  @override
  String get dayFeedMindTileWide => 'Largo';

  @override
  String get dayFeedShowMindText => 'Mostra testo';

  @override
  String get dayFeedPhotoAccessHint =>
      'Consenti l\'accesso alle foto per vedere qui foto e video';

  @override
  String get dayFeedAllowAccess => 'Consenti';

  @override
  String get dayFeedFolderHint =>
      'Scegli una cartella multimediale per vedere qui foto e video';

  @override
  String get dayFeedChooseFolder => 'Scegli';

  @override
  String get dayFeedMute => 'Disattiva audio';

  @override
  String get dayFeedUnmute => 'Attiva audio';

  @override
  String get holdToRecordAudio =>
      'Tieni premuto per registrare un messaggio vocale';

  @override
  String get holdToRecordVideo =>
      'Tieni premuto per registrare un videomessaggio';

  @override
  String get roundVideoRecordError => 'Impossibile registrare il video';

  @override
  String get roundVideoCameraUnavailable =>
      'Fotocamera non disponibile su questo dispositivo';

  @override
  String get roundVideoRetake => 'Rifai';

  @override
  String get roundVideoUse => 'Usa';

  @override
  String get removeMedia => 'Rimuovi media';

  @override
  String get shakeToCustomize => 'Scuoti per personalizzare';

  @override
  String get shakeToCustomizeHint => 'o tieni premuto il titolo';

  @override
  String get customizeSettings => 'Personalizza impostazioni';

  @override
  String get customizeSettingsDescription =>
      'Le sezioni e le righe deselezionate vengono nascoste nelle Impostazioni.';

  @override
  String get calendarSettings => 'Impostazioni calendario';

  @override
  String get calendarShowMedia => 'Mostra foto e video';

  @override
  String get calendarWeekTitles => 'Titoli delle settimane';

  @override
  String get calendarPlayStories => 'Guarda le storie';

  @override
  String get storyBackgroundTweak => 'Sfondo delle storie';

  @override
  String get storyAnimationOff => 'Disattivato';

  @override
  String get storyAnimationPulse => 'Pulsazione';

  @override
  String get storyAnimationWave => 'Onda';

  @override
  String get storyAnimationEqualizer => 'Equalizzatore';

  @override
  String get storyAnimationDrift => 'Deriva';

  @override
  String get storyAnimationGlow => 'Bagliore';

  @override
  String get viewerCommentHint => 'Commento…';

  @override
  String get calendarToCurrentWeek => 'Alla settimana corrente';

  @override
  String get storyDateLines => 'Righe della data';

  @override
  String get storyTextureTitle => 'Texture';

  @override
  String get storySpectrum => 'Spettro del suono';

  @override
  String get storySensitivity => 'Sensibilità';

  @override
  String profileMindfulDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Consapevole da $count giorni',
      one: 'Consapevole da $count giorno',
    );
    return '$_temp0';
  }

  @override
  String get profileName => 'Nome';

  @override
  String get profilePhoto => 'Foto';

  @override
  String get profileEmoji => 'Emoji';

  @override
  String get profileInitial => 'Lettera';

  @override
  String get webVersion => 'Versione web';

  @override
  String get webVersionAddressHint =>
      'Aprila nel browser di un computer sulla stessa Wi‑Fi; tieni keklist aperto';

  @override
  String get webVersionCopied => 'Indirizzo copiato';

  @override
  String get webVersionNeedsPin =>
      'Imposta un PIN per aprire keklist nel browser di un computer sulla stessa Wi‑Fi.';

  @override
  String get webVersionStarting => 'Avvio…';

  @override
  String get webVersionNoWifi =>
      'Connettiti a una Wi‑Fi per aprire keklist in un browser.';

  @override
  String get webVersionNoBundle => 'Questa build non include la versione web.';

  @override
  String get webVersionPin => 'PIN';

  @override
  String get webVersionPinSet =>
      'Ogni browser lo chiede una volta ogni 30 giorni';

  @override
  String get webVersionPinNotSet => 'Non impostato';

  @override
  String get webVersionPinHint => '4–8 cifre';

  @override
  String get webVersionRemovePin => 'Rimuovi PIN';

  @override
  String get webVersionPort => 'Porta';

  @override
  String get aiTab => 'Chat';

  @override
  String get aiTabDescription =>
      'Parla delle tue note con un\'IA che funziona sul telefono';

  @override
  String get aiPrivacyNote =>
      'Funziona solo sul telefono: le tue note non lasciano mai il dispositivo.';

  @override
  String get aiDisclaimer =>
      'Non è un servizio medico. Se sei in pericolo, contatta i servizi di emergenza.';

  @override
  String get aiYesterday => 'Ieri';

  @override
  String get aiNoSessions => 'Ancora nessuna sessione';

  @override
  String get aiNewSession => 'Nuova sessione';

  @override
  String get aiChooseRole => 'Scegli un ruolo';

  @override
  String get aiRoleTherapist => 'Terapeuta';

  @override
  String get aiRoleCoach => 'Coach';

  @override
  String get aiRoleFriend => 'Amico';

  @override
  String get aiMessageHint => 'Messaggio';

  @override
  String get aiStarterWeek => 'Com\'è andata la mia settimana?';

  @override
  String get aiStarterWorry => 'Cosa mi preoccupa ultimamente?';

  @override
  String get aiStarterJoy => 'Cosa mi ha reso felice di recente?';

  @override
  String get aiActionSaveAsMind => 'Salva come nota';

  @override
  String get aiActionOpenDay => 'Apri giorno';

  @override
  String get aiActionWeekSummary => 'Riepilogo della settimana';

  @override
  String get aiWeekSummaryPrompt =>
      'Riassumi i miei ultimi 7 giorni: cosa è successo, come mi sono sentito, cosa è emerso.';

  @override
  String get aiSavedAsMind => 'Salvato in oggi';

  @override
  String get aiStop => 'Ferma';

  @override
  String get aiNoModelTitle => 'Scegli un modello';

  @override
  String get aiNoModelMessage =>
      'Scarica un modello per iniziare. Funziona sul telefono, offline.';

  @override
  String get aiNoModelOnPhone =>
      'Scarica un modello nell\'app sul telefono: Impostazioni → IA → Modelli.';

  @override
  String get aiModels => 'Modelli';

  @override
  String get aiRoles => 'Ruoli';

  @override
  String get aiDownloaded => 'Scaricati';

  @override
  String get aiDownloads => 'In download';

  @override
  String get aiGalleryCatalog => 'Google AI Edge Gallery';

  @override
  String get aiHuggingFace => 'Hugging Face (GGUF)';

  @override
  String get aiSearchModels => 'Cerca modelli GGUF';

  @override
  String get aiDownload => 'Scarica';

  @override
  String get aiPause => 'Pausa';

  @override
  String get aiPaused => 'In pausa';

  @override
  String get aiResume => 'Riprendi';

  @override
  String get aiDownloadFailed => 'Download non riuscito';

  @override
  String get aiCellularTitle => 'Scaricare con i dati mobili?';

  @override
  String aiCellularMessage(String size) {
    return 'Verranno scaricati $size con i dati mobili.';
  }

  @override
  String get aiDeleteModel => 'Eliminare il modello?';

  @override
  String aiStorageUsed(String size) {
    return 'Su questo telefono: $size';
  }

  @override
  String aiDeviceMemory(String size) {
    return 'Memoria del telefono: $size';
  }

  @override
  String get aiCatalogFailed =>
      'Impossibile caricare l\'elenco. Controlla la connessione.';

  @override
  String get aiNoFilesFit =>
      'Nessun file di questo modello entra nella memoria del telefono.';

  @override
  String get aiBuiltInRole => 'Integrati';

  @override
  String get aiOwnRoles => 'I tuoi ruoli';

  @override
  String get aiDuplicate => 'Duplica';

  @override
  String get aiNewRole => 'Nuovo ruolo';

  @override
  String get aiRoleName => 'Nome';

  @override
  String get aiRoleEmoji => 'Emoji';

  @override
  String get aiRolePrompt => 'Prompt';

  @override
  String get aiRolePromptHint =>
      'Come deve parlare l\'IA e su cosa concentrarsi';

  @override
  String get aiReadOnlyRole =>
      'I ruoli integrati non si possono modificare. Duplicane uno per crearne uno tuo.';

  @override
  String get aiDeleteSession => 'Eliminare la sessione?';

  @override
  String get aiDeleteRole => 'Eliminare il ruolo?';

  @override
  String get aiRecommended => 'Consigliato';

  @override
  String get aiLowQuality => 'Bassa qualità';

  @override
  String get aiModelDoesNotFit =>
      'Questo modello non entra nella memoria del telefono. Scegline uno più piccolo.';

  @override
  String get aiChooseAnotherModel => 'Scegli un altro modello';

  @override
  String get creatorEmotionsTitle => 'Emozioni';

  @override
  String get creatorEmotionsAfterSave => 'Chiedi dopo il salvataggio';

  @override
  String get creatorEmotionsButton => 'Pulsante sopra la tastiera';

  @override
  String get creatorEmotionsNever => 'Non chiedere';

  @override
  String get insightsWeekAgo => 'Una settimana fa';

  @override
  String get insightsMonthAgo => 'Un mese fa';

  @override
  String get insightsHalfYearAgo => 'Sei mesi fa';

  @override
  String get insightsYearAgo => 'Un anno fa';

  @override
  String get insightsTwoYearsAgo => 'Due anni fa';

  @override
  String get insightsVoiceAndVideos => 'Vocali e video circolari';

  @override
  String insightsWeekNumber(String number) {
    return 'Settimana $number';
  }

  @override
  String get aiNoSessionsHint =>
      'Chiedi della tua settimana, di una preoccupazione o di una bella giornata: la chat legge le tue note sul telefono.';
}
