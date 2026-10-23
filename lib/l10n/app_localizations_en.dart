// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get insightsBrightestPeriod => 'Brightest period';

  @override
  String get insightsPeriodWeek => 'Week';

  @override
  String get insightsPeriodMonth => 'Month';

  @override
  String get insightsPeriodYear => 'Year';

  @override
  String get insightsPeriodAllTime => 'All time';

  @override
  String insightsVsLastWeek(String delta) {
    return '$delta vs last week';
  }

  @override
  String insightsVsLastMonth(String delta) {
    return '$delta vs last month';
  }

  @override
  String insightsVsLastYear(String delta) {
    return '$delta vs last year';
  }

  @override
  String get insightsCategorySummary => 'Summary';

  @override
  String get insightsCategoryEmotions => 'Emotions';

  @override
  String get insightsCategoryActivity => 'Activity';

  @override
  String get insightsCategoryMemories => 'Memories';

  @override
  String get insightsCategoryMedia => 'Media';

  @override
  String get insightsCounters => 'In numbers';

  @override
  String get insightsMinds => 'Minds';

  @override
  String get insightsActiveDays => 'Active days';

  @override
  String get insightsWords => 'Words';

  @override
  String get insightsBrightestDay => 'Brightest day';

  @override
  String get insightsBrightestWeek => 'Brightest week';

  @override
  String get insightsBrightestMonth => 'Brightest month';

  @override
  String get insightsBrightestYear => 'Brightest year';

  @override
  String insightsBrightestDetails(String minds, String emotions, String media) {
    return '$minds minds · $emotions emotions · $media media';
  }

  @override
  String get insightsEmotionDistribution => 'Emotions';

  @override
  String get insightsEmotionTrend => 'Emotion trend';

  @override
  String get insightsEmotionPairs => 'Emotions together';

  @override
  String get insightsEmotionRhythm => 'Emotional rhythm';

  @override
  String get insightsByWeekday => 'By weekday';

  @override
  String get insightsByDayPart => 'By time of day';

  @override
  String get insightsNight => 'Night';

  @override
  String get insightsMorning => 'Morning';

  @override
  String get insightsAfternoon => 'Afternoon';

  @override
  String get insightsEvening => 'Evening';

  @override
  String get insightsStreak => 'Streak';

  @override
  String get insightsStreakLabel => 'days in a row';

  @override
  String insightsLongestStreak(String count) {
    return 'Longest: $count';
  }

  @override
  String get insightsStreakKeepGoing => 'Add a mind today to keep it going';

  @override
  String get insightsHeatmap => 'Activity map';

  @override
  String get insightsActivityTime => 'Time of day';

  @override
  String insightsPeakHour(String hour) {
    return 'Most active around $hour';
  }

  @override
  String get insightsOnThisDay => 'Back then';

  @override
  String get insightsMediaCounters => 'Media';

  @override
  String get insightsPhotos => 'Photos';

  @override
  String get insightsVideos => 'Videos';

  @override
  String get insightsVoiceNotes => 'Voice notes';

  @override
  String get insightsRoundVideos => 'Round videos';

  @override
  String get insightsEmptyPeriod => 'No minds in this period yet';

  @override
  String get insightsEmptyEmotions => 'Tag minds with emotions to see this';

  @override
  String get insightsEmptyPairs => 'Tag a mind with two emotions to see pairs';

  @override
  String get insightsEmptyOnThisDay =>
      'Nothing from a week, a month, half a year or a year ago yet';

  @override
  String get insightsEmptyRoundVideos =>
      'No voice notes or round videos in this period';

  @override
  String get insightsEmptyStreak => 'Add a mind today to start a streak';

  @override
  String get insightsCustomize => 'Customize analytics';

  @override
  String get insightsCustomizeDescription =>
      'Turn cards on or off and drag to reorder';

  @override
  String get insightsResetLayout => 'Reset';

  @override
  String get activeTasks => 'Active tasks';

  @override
  String get galleryIndex => 'Gallery index';

  @override
  String get galleryIndexNoAccess => 'No access to Photos';

  @override
  String get galleryIndexNotIndexed => 'Not indexed yet';

  @override
  String galleryIndexIndexing(String done, String total) {
    return 'Indexing $done of $total';
  }

  @override
  String galleryIndexReady(String count, String time) {
    return '$count photos and videos · updated $time';
  }

  @override
  String galleryIndexThumbnails(String size) {
    return 'Thumbnail cache: $size';
  }

  @override
  String get galleryIndexRebuildTitle => 'Rebuild the gallery index?';

  @override
  String get galleryIndexRebuildMessage =>
      'Thumbnails will be cleared and the library scanned again.';

  @override
  String get galleryIndexRebuild => 'Rebuild';

  @override
  String get settings => 'Settings';

  @override
  String get userData => 'User Data';

  @override
  String get appearance => 'Appearance';

  @override
  String get interfaceStyle => 'Interface Style';

  @override
  String get exportToCsv => 'Export to CSV';

  @override
  String get exportData => 'Export data';

  @override
  String get importData => 'Import data';

  @override
  String get done => 'DONE';

  @override
  String get chatWithAI => 'Chat with AI';

  @override
  String get photosPerDay => 'Photos per day';

  @override
  String get extraActions => 'Extra actions';

  @override
  String get mindOptions => 'Mind options';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get share => 'Share';

  @override
  String get saveToFiles => 'Save to files';

  @override
  String get switchDay => 'Switch day';

  @override
  String get goToDate => 'Go to date';

  @override
  String get showDigest => 'Show digest for ...';

  @override
  String get translateToEnglish => 'Translate to English';

  @override
  String get convertToStandalone => 'Convert to standalone';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get showDayDividers => 'Show day dividers';

  @override
  String get tabsSettings => 'Tabs settings';

  @override
  String get whatsNew => 'What\'s new?';

  @override
  String get releaseNotes => 'Release notes';

  @override
  String get suggestFeature => 'Suggest a feature';

  @override
  String get sendFeedback => 'Send feedback';

  @override
  String get emailUs => 'Email us';

  @override
  String get clearOfflineDataWarning =>
      'All your offline data will be deleted. Make sure that you have already exported it.';

  @override
  String get sourceCode => 'Source code';

  @override
  String get termsOfUse => 'Terms Of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get clearOnDeviceData => 'Clear on-device data';

  @override
  String get setOpenAIToken => 'Set Open AI Token';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get mind => 'Mind';

  @override
  String get profile => 'Profile';

  @override
  String get insights => 'Insights';

  @override
  String get calendar => 'Calendar';

  @override
  String get debugMenu => 'Debug Menu';

  @override
  String get discussion => 'Discussion';

  @override
  String get about => 'About';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get enterTokenHere => 'Enter token here';

  @override
  String get token => 'Token';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get activeTabs => 'Active tabs';

  @override
  String get hiddenTabs => 'Hidden tabs';

  @override
  String get error => 'Error';

  @override
  String get startDiscussion => 'Start discussion';

  @override
  String get send => 'SEND';

  @override
  String get create => 'Create';

  @override
  String get yourFolderName => 'Your folder name';

  @override
  String get noMindsInSelectedPeriod => 'No minds in selected period';

  @override
  String get noMindsForPeriod => 'No minds for this period';

  @override
  String get selectPeriod => 'Select period ...';

  @override
  String get digest => 'Digest';

  @override
  String get minds => 'Minds';

  @override
  String get searchForYourNotes => 'Search for your notes';

  @override
  String get searchYourEmoji => 'Search your emoji...';

  @override
  String get writeSomething => 'Write something...';

  @override
  String get todayMinds => 'Today minds';

  @override
  String get youDidNotCollectAnyEntriesYet =>
      'You did not collect any entries yet';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get cannotRemoveMainScreen =>
      'Cannot remove main screen. You will loose option to setup tabs.';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This week';

  @override
  String get lastTwoWeeks => 'Last 2 weeks';

  @override
  String get thisMonth => 'This month';

  @override
  String get thisYear => 'This year';

  @override
  String get calendarDescription => 'Main screen with Calendar of entries';

  @override
  String get insightsDescription => 'Statistics all yours entries';

  @override
  String get settingsDescription =>
      'Screen with all settings (dark mode, sync and etc.)';

  @override
  String get todayDescription => 'Only today minds';

  @override
  String get debugMenuDescription =>
      'Developer tools for toggling experimental features';

  @override
  String get noMindsForThisDay => 'No minds for this day';

  @override
  String get week => 'Week';

  @override
  String get password => 'Password';

  @override
  String get archivePassword => 'Archive password';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get reenterPassword => 'Re-enter password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get exportPassword => 'Export to ZIP';

  @override
  String get exportPasswordDescription =>
      'Add a password to encrypt your export. You can skip this for unencrypted export.';

  @override
  String get importPassword => 'Enter password';

  @override
  String get importPasswordDescription =>
      'This file is password-protected. Please enter the password to decrypt.';

  @override
  String get skipPassword => 'Skip (no password)';

  @override
  String get continue_ => 'Continue';

  @override
  String get incorrectPassword => 'Incorrect password';

  @override
  String get incorrectPasswordMessage =>
      'The password you entered is incorrect. Please try again.';

  @override
  String get corruptedFile => 'Corrupted file';

  @override
  String get invalidFormat => 'Invalid format';

  @override
  String get missingAudioFiles => 'Some audio files are missing';

  @override
  String get insufficientStorage => 'Insufficient storage';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get retry => 'Retry';

  @override
  String get ok => 'OK';

  @override
  String get exportSuccess => 'Export successful';

  @override
  String get exportError => 'Export failed';

  @override
  String get importSuccess => 'Import successful';

  @override
  String get importError => 'Import failed';

  @override
  String get mindsToExport => 'Minds';

  @override
  String get audioFilesToExport => 'Audio files';

  @override
  String get emotionsToExport => 'Emotions';

  @override
  String get mindsExported => 'Minds exported';

  @override
  String get audioFilesExported => 'Audio files exported';

  @override
  String get mindsImported => 'Minds imported';

  @override
  String get audioFilesImported => 'Audio files imported';

  @override
  String get onboardingMind1 => 'Hello!';

  @override
  String get onboardingMind2 =>
      'I\'m keklist - a personal diary of short notes';

  @override
  String get onboardingMind2Comment1 => 'Notes can be commented on';

  @override
  String get onboardingMind2Comment2 => 'To open a note, tap on it';

  @override
  String get onboardingMind3 =>
      'In the \'Calendar\' tab, all notes are displayed by days, weeks, and months';

  @override
  String get onboardingMind4 =>
      'The \'Analytics\' tab shows brief statistics of your entries';

  @override
  String get onboardingMind5 => 'All notes are stored only on your phone';

  @override
  String get onboardingMind6 => 'To create new note tap \'Write\'';

  @override
  String get noPhotosForDay => 'No photos found for this day';

  @override
  String get sourcesMediaFolder => 'Media Files';

  @override
  String get sourcesMediaFolderSubtitle =>
      'Photos & videos from a custom folder';

  @override
  String get mediaFolderSettings => 'Media Files';

  @override
  String get licenses => 'Licenses';

  @override
  String get sourcesWeather => 'Weather';

  @override
  String get sourcesWeatherSubtitle => 'Local weather conditions for this day';

  @override
  String get weatherSettings => 'Weather Settings';

  @override
  String get weatherLatitude => 'Latitude';

  @override
  String get weatherLongitude => 'Longitude';

  @override
  String get weatherSaveLocation => 'Save location';

  @override
  String get weatherUseMyLocation => 'Use my location';

  @override
  String get weatherDetectingLocation => 'Detecting location...';

  @override
  String get weatherOrEnterManually => 'or enter manually';

  @override
  String get weatherLocationError =>
      'Could not detect location. Please enter manually.';

  @override
  String get weatherLocationServicesDisabled =>
      'Location services are disabled. Please enable them in Settings.';

  @override
  String get weatherLocationPermissionDenied => 'Location permission denied.';

  @override
  String get weatherLocationPermissionPermanentlyDenied =>
      'Location permission is permanently denied. Opening app settings.';

  @override
  String get audioRecordTitle => 'Record audio';

  @override
  String get audioRecordTitleRecording => 'Recording…';

  @override
  String get audioRecordHint => 'Tap Stop to save to your device.';

  @override
  String get audioRecordStart => 'Start';

  @override
  String get audioRecordStop => 'Stop';

  @override
  String get audioRecordCancel => 'Cancel';

  @override
  String get audioRecordPermissionError =>
      'Microphone permission is required to record audio.';

  @override
  String get audioRecordStartError =>
      'Unable to start recording. Please try again.';

  @override
  String get audioRecordStopError =>
      'Unable to stop the recording. Please try again.';

  @override
  String proUserFooter(String price, String date) {
    return 'You are a PRO user. Next payment $price will be at $date.';
  }

  @override
  String get emotions => 'Emotions';

  @override
  String get archived => 'Archived';

  @override
  String get archive => 'Archive';

  @override
  String get restore => 'Restore';

  @override
  String get deletePermanently => 'Delete permanently';

  @override
  String get newEmotion => 'New emotion';

  @override
  String get editEmotion => 'Edit emotion';

  @override
  String get addEmotion => 'Add emotion';

  @override
  String get addEmotionsToMind => 'Add emotions';

  @override
  String get emotionNameHint => 'Name';

  @override
  String get doneEditing => 'Done';

  @override
  String get emotionEditHint => 'Tap to rename · ✕ to remove · drag to reorder';

  @override
  String get emotionInUseMessage =>
      'This emotion is used by some minds. Archive it to keep it there, or delete it everywhere.';

  @override
  String get emotionPickHint => 'Tap to tag';

  @override
  String get emotionDrillHint => 'long-press to go deeper';

  @override
  String get noEmotionsYet => 'No emotions yet';

  @override
  String get noArchivedEmotions => 'No archived emotions';

  @override
  String get deleteEmotionMessage =>
      'Delete this emotion? It will be removed from any minds using it.';

  @override
  String get dayFeedTileSettings => 'Tile settings';

  @override
  String get dayFeedColumns => 'Columns';

  @override
  String get dayFeedMindTileSize => 'Mind tile size';

  @override
  String get dayFeedMindTileSquare => 'Square';

  @override
  String get dayFeedMindTileWide => 'Wide';

  @override
  String get dayFeedShowMindText => 'Show text';

  @override
  String get dayFeedPhotoAccessHint =>
      'Allow photo access to see your photos and videos here';

  @override
  String get dayFeedAllowAccess => 'Allow';

  @override
  String get dayFeedFolderHint =>
      'Choose a media folder to see your photos and videos here';

  @override
  String get dayFeedChooseFolder => 'Choose';

  @override
  String get dayFeedMute => 'Mute';

  @override
  String get dayFeedUnmute => 'Unmute';

  @override
  String get holdToRecordAudio => 'Hold to record a voice message';

  @override
  String get holdToRecordVideo => 'Hold to record a video message';

  @override
  String get roundVideoRecordError => 'Couldn\'t record the video';

  @override
  String get roundVideoCameraUnavailable =>
      'Camera is unavailable on this device';

  @override
  String get roundVideoRetake => 'Retake';

  @override
  String get roundVideoUse => 'Use';

  @override
  String get removeMedia => 'Remove media';

  @override
  String get shakeToCustomize => 'Shake to customize';

  @override
  String get shakeToCustomizeHint => 'or long-press the title';

  @override
  String get customizeSettings => 'Customize settings';

  @override
  String get customizeSettingsDescription =>
      'Unchecked sections and rows are hidden from the Settings screen.';

  @override
  String get calendarSettings => 'Calendar settings';

  @override
  String get calendarShowMedia => 'Show photos and videos';

  @override
  String get calendarWeekTitles => 'Week titles';

  @override
  String get calendarPlayStories => 'Play stories';

  @override
  String get storyBackgroundTweak => 'Story background';

  @override
  String get storyAnimationOff => 'Off';

  @override
  String get storyAnimationPulse => 'Pulse';

  @override
  String get storyAnimationWave => 'Wave';

  @override
  String get storyAnimationEqualizer => 'Equalizer';

  @override
  String get storyAnimationDrift => 'Drift';

  @override
  String get storyAnimationGlow => 'Glow';

  @override
  String get viewerCommentHint => 'Comment…';

  @override
  String get calendarToCurrentWeek => 'To current week';

  @override
  String get storyDateLines => 'Date lines';

  @override
  String get storyTextureTitle => 'Texture';

  @override
  String get storySpectrum => 'Sound spectrum';

  @override
  String get storySensitivity => 'Sensitivity';

  @override
  String profileMindfulDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mindful for $count days',
      one: 'Mindful for $count day',
    );
    return '$_temp0';
  }

  @override
  String get profileName => 'Name';

  @override
  String get profilePhoto => 'Photo';

  @override
  String get profileEmoji => 'Emoji';

  @override
  String get profileInitial => 'Letter';

  @override
  String get webVersion => 'Web version';

  @override
  String get webVersionAddressHint =>
      'Open in a browser on a computer in the same Wi-Fi; keep keklist open';

  @override
  String get webVersionCopied => 'Address copied';

  @override
  String get webVersionNeedsPin =>
      'Set a PIN to open keklist in a browser on a computer in the same Wi-Fi.';

  @override
  String get webVersionStarting => 'Starting…';

  @override
  String get webVersionNoWifi =>
      'Connect to Wi-Fi to open keklist in a browser.';

  @override
  String get webVersionNoBundle =>
      'This build doesn\'t include the web version.';

  @override
  String get webVersionPin => 'PIN';

  @override
  String get webVersionPinSet => 'Each browser asks for it once in 30 days';

  @override
  String get webVersionPinNotSet => 'Not set';

  @override
  String get webVersionPinHint => '4–8 digits';

  @override
  String get webVersionRemovePin => 'Remove PIN';

  @override
  String get webVersionPort => 'Port';

  @override
  String get aiTab => 'Chat';

  @override
  String get aiTabDescription =>
      'Talk about your records with an AI that runs on your phone';

  @override
  String get aiPrivacyNote =>
      'Runs on your phone only: your records never leave the device.';

  @override
  String get aiDisclaimer =>
      'Not a medical service. If you are in danger, contact emergency services.';

  @override
  String get aiYesterday => 'Yesterday';

  @override
  String get aiSessions => 'Sessions';

  @override
  String get aiNoSessions => 'No sessions yet';

  @override
  String get aiNewSession => 'New session';

  @override
  String get aiChooseRole => 'Choose a role';

  @override
  String get aiRoleTherapist => 'Therapist';

  @override
  String get aiRoleCoach => 'Coach';

  @override
  String get aiRoleFriend => 'Friend';

  @override
  String get aiMessageHint => 'Message';

  @override
  String get aiStarterWeek => 'How was my week?';

  @override
  String get aiStarterWorry => 'What has been bothering me lately?';

  @override
  String get aiStarterJoy => 'What brought me joy recently?';

  @override
  String get aiActionSaveAsMind => 'Save as mind';

  @override
  String get aiActionOpenDay => 'Open day';

  @override
  String get aiActionWeekSummary => 'Week summary';

  @override
  String get aiWeekSummaryPrompt =>
      'Summarize my last 7 days: what happened, how I felt, what stood out.';

  @override
  String get aiSavedAsMind => 'Saved to today';

  @override
  String get aiThinking => 'Thinking…';

  @override
  String get aiStop => 'Stop';

  @override
  String get aiNoModelTitle => 'Choose a model';

  @override
  String get aiNoModelMessage =>
      'Download a model to start. It runs on your phone, offline.';

  @override
  String get aiNoModelOnPhone =>
      'Download a model in the phone app: Settings → AI → Models.';

  @override
  String get aiModels => 'Models';

  @override
  String get aiRoles => 'Roles';

  @override
  String get aiDownloaded => 'Downloaded';

  @override
  String get aiDownloads => 'Downloading';

  @override
  String get aiGalleryCatalog => 'Google AI Edge Gallery';

  @override
  String get aiHuggingFace => 'Hugging Face (GGUF)';

  @override
  String get aiSearchModels => 'Search GGUF models';

  @override
  String get aiDownload => 'Download';

  @override
  String get aiPause => 'Pause';

  @override
  String get aiPaused => 'Paused';

  @override
  String get aiResume => 'Resume';

  @override
  String get aiDownloadFailed => 'Download failed';

  @override
  String get aiCellularTitle => 'Download over mobile data?';

  @override
  String aiCellularMessage(String size) {
    return '$size will be downloaded over mobile data.';
  }

  @override
  String get aiDeleteModel => 'Delete the model?';

  @override
  String aiStorageUsed(String size) {
    return 'On this phone: $size';
  }

  @override
  String aiDeviceMemory(String size) {
    return 'Phone memory: $size';
  }

  @override
  String get aiCatalogFailed =>
      'Couldn\'t load the list. Check the connection.';

  @override
  String get aiNoFilesFit =>
      'None of this model\'s files fit this phone\'s memory.';

  @override
  String get aiBuiltInRole => 'Built-in';

  @override
  String get aiOwnRoles => 'Your roles';

  @override
  String get aiDuplicate => 'Duplicate';

  @override
  String get aiNewRole => 'New role';

  @override
  String get aiRoleName => 'Name';

  @override
  String get aiRoleEmoji => 'Emoji';

  @override
  String get aiRolePrompt => 'Prompt';

  @override
  String get aiRolePromptHint => 'How the AI should talk and what to focus on';

  @override
  String get aiReadOnlyRole =>
      'Built-in roles can\'t be changed. Duplicate one to make your own.';

  @override
  String get aiDeleteSession => 'Delete the session?';

  @override
  String get aiDeleteRole => 'Delete the role?';

  @override
  String get aiRecommended => 'Recommended';

  @override
  String get aiLowQuality => 'Low quality';

  @override
  String get aiModelDoesNotFit =>
      'This model doesn\'t fit in your phone\'s memory. Choose a smaller one.';

  @override
  String get aiChooseAnotherModel => 'Choose another model';

  @override
  String get creatorEmotionsTitle => 'Emotions';

  @override
  String get creatorEmotionsAfterSave => 'Ask after saving';

  @override
  String get creatorEmotionsButton => 'Button above the keyboard';

  @override
  String get creatorEmotionsNever => 'Don\'t ask';

  @override
  String get insightsWeekAgo => 'A week ago';

  @override
  String get insightsMonthAgo => 'A month ago';

  @override
  String get insightsHalfYearAgo => 'Half a year ago';

  @override
  String get insightsYearAgo => 'A year ago';

  @override
  String get insightsTwoYearsAgo => 'Two years ago';

  @override
  String get insightsVoiceAndVideos => 'Voice and round videos';

  @override
  String insightsWeekNumber(String number) {
    return 'Week $number';
  }
}
