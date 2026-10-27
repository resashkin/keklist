import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ky.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sr.dart';
import 'app_localizations_uz.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('it'),
    Locale('ja'),
    Locale('kk'),
    Locale('ky'),
    Locale('ru'),
    Locale('sr'),
    Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
    Locale('uz'),
    Locale('zh'),
  ];

  /// Analytics card name in the customize sheet
  ///
  /// In en, this message translates to:
  /// **'Brightest period'**
  String get insightsBrightestPeriod;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get insightsPeriodWeek;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get insightsPeriodMonth;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get insightsPeriodYear;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get insightsPeriodAllTime;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'{delta} vs last week'**
  String insightsVsLastWeek(String delta);

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'{delta} vs last month'**
  String insightsVsLastMonth(String delta);

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'{delta} vs last year'**
  String insightsVsLastYear(String delta);

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get insightsCategorySummary;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Emotions'**
  String get insightsCategoryEmotions;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get insightsCategoryActivity;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get insightsCategoryMemories;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get insightsCategoryMedia;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'In numbers'**
  String get insightsCounters;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Minds'**
  String get insightsMinds;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get insightsActiveDays;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get insightsWords;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Brightest day'**
  String get insightsBrightestDay;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Brightest week'**
  String get insightsBrightestWeek;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Brightest month'**
  String get insightsBrightestMonth;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Brightest year'**
  String get insightsBrightestYear;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'{minds} minds · {emotions} emotions · {media} media'**
  String insightsBrightestDetails(String minds, String emotions, String media);

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Emotions'**
  String get insightsEmotionDistribution;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Emotion trend'**
  String get insightsEmotionTrend;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Emotions together'**
  String get insightsEmotionPairs;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Emotional rhythm'**
  String get insightsEmotionRhythm;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'By weekday'**
  String get insightsByWeekday;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'By time of day'**
  String get insightsByDayPart;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get insightsNight;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get insightsMorning;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get insightsAfternoon;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get insightsEvening;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get insightsStreak;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'days in a row'**
  String get insightsStreakLabel;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Longest: {count}'**
  String insightsLongestStreak(String count);

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Add a mind today to keep it going'**
  String get insightsStreakKeepGoing;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Activity map'**
  String get insightsHeatmap;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Time of day'**
  String get insightsActivityTime;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Most active around {hour}'**
  String insightsPeakHour(String hour);

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Back then'**
  String get insightsOnThisDay;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get insightsMediaCounters;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get insightsPhotos;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get insightsVideos;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Voice notes'**
  String get insightsVoiceNotes;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Round videos'**
  String get insightsRoundVideos;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'No minds in this period yet'**
  String get insightsEmptyPeriod;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Tag minds with emotions to see this'**
  String get insightsEmptyEmotions;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Tag a mind with two emotions to see pairs'**
  String get insightsEmptyPairs;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Nothing from a week, a month, half a year or a year ago yet'**
  String get insightsEmptyOnThisDay;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'No voice notes or round videos in this period'**
  String get insightsEmptyRoundVideos;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Add a mind today to start a streak'**
  String get insightsEmptyStreak;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Customize analytics'**
  String get insightsCustomize;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Turn cards on or off and drag to reorder'**
  String get insightsCustomizeDescription;

  /// Analytics screen
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get insightsResetLayout;

  /// Settings section shown on top while a background job runs
  ///
  /// In en, this message translates to:
  /// **'Active tasks'**
  String get activeTasks;

  /// Settings row for the photo library index
  ///
  /// In en, this message translates to:
  /// **'Gallery index'**
  String get galleryIndex;

  /// Gallery index subtitle when Photos access is missing
  ///
  /// In en, this message translates to:
  /// **'No access to Photos'**
  String get galleryIndexNoAccess;

  /// Gallery index subtitle before the first scan
  ///
  /// In en, this message translates to:
  /// **'Not indexed yet'**
  String get galleryIndexNotIndexed;

  /// Gallery index subtitle while scanning
  ///
  /// In en, this message translates to:
  /// **'Indexing {done} of {total}'**
  String galleryIndexIndexing(String done, String total);

  /// Gallery index subtitle after a scan
  ///
  /// In en, this message translates to:
  /// **'{count} photos and videos · updated {time}'**
  String galleryIndexReady(String count, String time);

  /// Size of the on-disk thumbnail cache
  ///
  /// In en, this message translates to:
  /// **'Thumbnail cache: {size}'**
  String galleryIndexThumbnails(String size);

  /// Confirm dialog title for rebuilding the gallery index
  ///
  /// In en, this message translates to:
  /// **'Rebuild the gallery index?'**
  String get galleryIndexRebuildTitle;

  /// Confirm dialog message for rebuilding the gallery index
  ///
  /// In en, this message translates to:
  /// **'Thumbnails will be cleared and the library scanned again.'**
  String get galleryIndexRebuildMessage;

  /// Confirm button that rebuilds the gallery index
  ///
  /// In en, this message translates to:
  /// **'Rebuild'**
  String get galleryIndexRebuild;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// User data section title
  ///
  /// In en, this message translates to:
  /// **'User Data'**
  String get userData;

  /// Appearance section title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Interface style setting label (Material vs Liquid Glass)
  ///
  /// In en, this message translates to:
  /// **'Interface Style'**
  String get interfaceStyle;

  /// Export to CSV button
  ///
  /// In en, this message translates to:
  /// **'Export to CSV'**
  String get exportToCsv;

  /// Export data button
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportData;

  /// Import data button
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get importData;

  /// Done button
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get done;

  /// Chat with AI action
  ///
  /// In en, this message translates to:
  /// **'Chat with AI'**
  String get chatWithAI;

  /// Photos per day action
  ///
  /// In en, this message translates to:
  /// **'Photos per day'**
  String get photosPerDay;

  /// Extra actions menu
  ///
  /// In en, this message translates to:
  /// **'Extra actions'**
  String get extraActions;

  /// Mind options menu
  ///
  /// In en, this message translates to:
  /// **'Mind options'**
  String get mindOptions;

  /// Edit action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Share action
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Save to files action
  ///
  /// In en, this message translates to:
  /// **'Save to files'**
  String get saveToFiles;

  /// Switch day action
  ///
  /// In en, this message translates to:
  /// **'Switch day'**
  String get switchDay;

  /// Go to date action
  ///
  /// In en, this message translates to:
  /// **'Go to date'**
  String get goToDate;

  /// Show digest action
  ///
  /// In en, this message translates to:
  /// **'Show digest for ...'**
  String get showDigest;

  /// Translate to English action
  ///
  /// In en, this message translates to:
  /// **'Translate to English'**
  String get translateToEnglish;

  /// Convert to standalone action
  ///
  /// In en, this message translates to:
  /// **'Convert to standalone'**
  String get convertToStandalone;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Theme appearance setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Follow system theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Show day dividers setting
  ///
  /// In en, this message translates to:
  /// **'Show day dividers'**
  String get showDayDividers;

  /// Tabs settings navigation
  ///
  /// In en, this message translates to:
  /// **'Tabs settings'**
  String get tabsSettings;

  /// Send feedback navigation
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedback;

  /// Warning when clearing offline data
  ///
  /// In en, this message translates to:
  /// **'All your offline data will be deleted. Make sure that you have already exported it.'**
  String get clearOfflineDataWarning;

  /// Source code navigation
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get sourceCode;

  /// Terms of use navigation
  ///
  /// In en, this message translates to:
  /// **'Terms Of Use'**
  String get termsOfUse;

  /// Privacy policy navigation
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Clear data navigation
  ///
  /// In en, this message translates to:
  /// **'Clear on-device data'**
  String get clearOnDeviceData;

  /// OpenAI token dialog title
  ///
  /// In en, this message translates to:
  /// **'Set Open AI Token'**
  String get setOpenAIToken;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Mind screen title
  ///
  /// In en, this message translates to:
  /// **'Mind'**
  String get mind;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Insights screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get insights;

  /// Calendar title
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// Settings row and screen title of the hidden developer menu
  ///
  /// In en, this message translates to:
  /// **'Developer menu'**
  String get debugMenu;

  /// Discussion screen title
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get discussion;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Danger zone section title
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// Token input hint
  ///
  /// In en, this message translates to:
  /// **'Enter token here'**
  String get enterTokenHere;

  /// Token input label
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get token;

  /// Clear cache button
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// Active tabs section header
  ///
  /// In en, this message translates to:
  /// **'Active tabs'**
  String get activeTabs;

  /// Hidden tabs section header
  ///
  /// In en, this message translates to:
  /// **'Hidden tabs'**
  String get hiddenTabs;

  /// Error dialog title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Start discussion button
  ///
  /// In en, this message translates to:
  /// **'Start discussion'**
  String get startDiscussion;

  /// Send button
  ///
  /// In en, this message translates to:
  /// **'SEND'**
  String get send;

  /// Create button
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Folder name input hint
  ///
  /// In en, this message translates to:
  /// **'Your folder name'**
  String get yourFolderName;

  /// No minds in period message
  ///
  /// In en, this message translates to:
  /// **'No minds in selected period'**
  String get noMindsInSelectedPeriod;

  /// No minds for period message
  ///
  /// In en, this message translates to:
  /// **'No minds for this period'**
  String get noMindsForPeriod;

  /// Select period action
  ///
  /// In en, this message translates to:
  /// **'Select period ...'**
  String get selectPeriod;

  /// Digest title
  ///
  /// In en, this message translates to:
  /// **'Digest'**
  String get digest;

  /// Minds title
  ///
  /// In en, this message translates to:
  /// **'Minds'**
  String get minds;

  /// Search emoji hint
  ///
  /// In en, this message translates to:
  /// **'Search your emoji...'**
  String get searchYourEmoji;

  /// Write something hint
  ///
  /// In en, this message translates to:
  /// **'Write something...'**
  String get writeSomething;

  /// Today minds title
  ///
  /// In en, this message translates to:
  /// **'Today minds'**
  String get todayMinds;

  /// No entries collected message
  ///
  /// In en, this message translates to:
  /// **'You did not collect any entries yet'**
  String get youDidNotCollectAnyEntriesYet;

  /// Confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// Cannot remove main screen error message
  ///
  /// In en, this message translates to:
  /// **'Cannot remove main screen. You will loose option to setup tabs.'**
  String get cannotRemoveMainScreen;

  /// Today period title
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday period title
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// This week period title
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// Last 2 weeks period title
  ///
  /// In en, this message translates to:
  /// **'Last 2 weeks'**
  String get lastTwoWeeks;

  /// This month period title
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// This year period title
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get thisYear;

  /// Calendar tab description
  ///
  /// In en, this message translates to:
  /// **'Main screen with Calendar of entries'**
  String get calendarDescription;

  /// Insights tab description
  ///
  /// In en, this message translates to:
  /// **'You and the statistics of your entries'**
  String get insightsDescription;

  /// Settings tab description
  ///
  /// In en, this message translates to:
  /// **'Screen with all settings (dark mode, sync and etc.)'**
  String get settingsDescription;

  /// Today tab description
  ///
  /// In en, this message translates to:
  /// **'Only today minds'**
  String get todayDescription;

  /// Debug Menu tab description
  ///
  /// In en, this message translates to:
  /// **'Developer tools for toggling experimental features'**
  String get debugMenuDescription;

  /// No minds for this day message
  ///
  /// In en, this message translates to:
  /// **'No minds for this day'**
  String get noMindsForThisDay;

  /// Week label
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// Password label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Archive password label for export
  ///
  /// In en, this message translates to:
  /// **'Archive password'**
  String get archivePassword;

  /// Enter password placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// Confirm password label
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// Re-enter password placeholder
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get reenterPassword;

  /// Passwords do not match error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Export password dialog title
  ///
  /// In en, this message translates to:
  /// **'Export to ZIP'**
  String get exportPassword;

  /// Export password description
  ///
  /// In en, this message translates to:
  /// **'Add a password to encrypt your export. You can skip this for unencrypted export.'**
  String get exportPasswordDescription;

  /// Import password dialog title
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get importPassword;

  /// Import password description
  ///
  /// In en, this message translates to:
  /// **'This file is password-protected. Please enter the password to decrypt.'**
  String get importPasswordDescription;

  /// Skip password button
  ///
  /// In en, this message translates to:
  /// **'Skip (no password)'**
  String get skipPassword;

  /// Continue button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// Incorrect password error title
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get incorrectPassword;

  /// Incorrect password error message
  ///
  /// In en, this message translates to:
  /// **'The password you entered is incorrect. Please try again.'**
  String get incorrectPasswordMessage;

  /// Corrupted file error
  ///
  /// In en, this message translates to:
  /// **'Corrupted file'**
  String get corruptedFile;

  /// Invalid format error
  ///
  /// In en, this message translates to:
  /// **'Invalid format'**
  String get invalidFormat;

  /// Missing audio files warning
  ///
  /// In en, this message translates to:
  /// **'Some audio files are missing'**
  String get missingAudioFiles;

  /// Insufficient storage error
  ///
  /// In en, this message translates to:
  /// **'Insufficient storage'**
  String get insufficientStorage;

  /// Unknown error
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Export success message title
  ///
  /// In en, this message translates to:
  /// **'Export successful'**
  String get exportSuccess;

  /// Export error message title
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportError;

  /// Import success message title
  ///
  /// In en, this message translates to:
  /// **'Import successful'**
  String get importSuccess;

  /// Import error message title
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get importError;

  /// Minds count label for export
  ///
  /// In en, this message translates to:
  /// **'Minds'**
  String get mindsToExport;

  /// Audio files count label for export
  ///
  /// In en, this message translates to:
  /// **'Audio files'**
  String get audioFilesToExport;

  /// Emotions count label for export
  ///
  /// In en, this message translates to:
  /// **'Emotions'**
  String get emotionsToExport;

  /// Minds exported count
  ///
  /// In en, this message translates to:
  /// **'Minds exported'**
  String get mindsExported;

  /// Audio files exported count
  ///
  /// In en, this message translates to:
  /// **'Audio files exported'**
  String get audioFilesExported;

  /// Minds imported count
  ///
  /// In en, this message translates to:
  /// **'Minds imported'**
  String get mindsImported;

  /// Audio files imported count
  ///
  /// In en, this message translates to:
  /// **'Audio files imported'**
  String get audioFilesImported;

  /// First onboarding mind greeting
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get onboardingMind1;

  /// Explanation of what keklist is
  ///
  /// In en, this message translates to:
  /// **'I\'m keklist - a personal diary of short notes'**
  String get onboardingMind2;

  /// Comment explaining commenting feature
  ///
  /// In en, this message translates to:
  /// **'Notes can be commented on'**
  String get onboardingMind2Comment1;

  /// Comment explaining how to open notes
  ///
  /// In en, this message translates to:
  /// **'To open a note, tap on it'**
  String get onboardingMind2Comment2;

  /// Explanation of Calendar tab
  ///
  /// In en, this message translates to:
  /// **'In the \'Calendar\' tab, all notes are displayed by days, weeks, and months'**
  String get onboardingMind3;

  /// Explanation of Analytics tab
  ///
  /// In en, this message translates to:
  /// **'The \'Analytics\' tab shows brief statistics of your entries'**
  String get onboardingMind4;

  /// Privacy explanation
  ///
  /// In en, this message translates to:
  /// **'All notes are stored only on your phone'**
  String get onboardingMind5;

  /// Instruction to create new note
  ///
  /// In en, this message translates to:
  /// **'To create new note tap \'Write\''**
  String get onboardingMind6;

  /// Empty state message when day has no photos
  ///
  /// In en, this message translates to:
  /// **'No photos found for this day'**
  String get noPhotosForDay;

  /// Media files source item title
  ///
  /// In en, this message translates to:
  /// **'Media Files'**
  String get sourcesMediaFolder;

  /// Media folder source item subtitle
  ///
  /// In en, this message translates to:
  /// **'Photos & videos from a custom folder'**
  String get sourcesMediaFolderSubtitle;

  /// Media files settings bottom sheet title
  ///
  /// In en, this message translates to:
  /// **'Media Files'**
  String get mediaFolderSettings;

  /// Licenses menu item
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// Weather source item title
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get sourcesWeather;

  /// Weather source item subtitle
  ///
  /// In en, this message translates to:
  /// **'Local weather conditions for this day'**
  String get sourcesWeatherSubtitle;

  /// Weather settings bottom sheet title
  ///
  /// In en, this message translates to:
  /// **'Weather Settings'**
  String get weatherSettings;

  /// Latitude input label
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get weatherLatitude;

  /// Longitude input label
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get weatherLongitude;

  /// Save location button
  ///
  /// In en, this message translates to:
  /// **'Save location'**
  String get weatherSaveLocation;

  /// Button to detect GPS location automatically
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get weatherUseMyLocation;

  /// Button label while GPS is being read
  ///
  /// In en, this message translates to:
  /// **'Detecting location...'**
  String get weatherDetectingLocation;

  /// Divider label between GPS button and manual input
  ///
  /// In en, this message translates to:
  /// **'or enter manually'**
  String get weatherOrEnterManually;

  /// Generic GPS error
  ///
  /// In en, this message translates to:
  /// **'Could not detect location. Please enter manually.'**
  String get weatherLocationError;

  /// Error when device location services are off
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Please enable them in Settings.'**
  String get weatherLocationServicesDisabled;

  /// Error when location permission is denied
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.'**
  String get weatherLocationPermissionDenied;

  /// Error when location permission is permanently denied
  ///
  /// In en, this message translates to:
  /// **'Location permission is permanently denied. Opening app settings.'**
  String get weatherLocationPermissionPermanentlyDenied;

  /// Title of the audio recorder bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Record audio'**
  String get audioRecordTitle;

  /// Title shown while audio is being recorded
  ///
  /// In en, this message translates to:
  /// **'Recording…'**
  String get audioRecordTitleRecording;

  /// Hint shown while recording is in progress
  ///
  /// In en, this message translates to:
  /// **'Tap Stop to save to your device.'**
  String get audioRecordHint;

  /// Button to start recording
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get audioRecordStart;

  /// Button to stop recording
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get audioRecordStop;

  /// Button to cancel and dismiss the recorder
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get audioRecordCancel;

  /// Error when microphone permission is missing
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required to record audio.'**
  String get audioRecordPermissionError;

  /// Error when recording fails to start
  ///
  /// In en, this message translates to:
  /// **'Unable to start recording. Please try again.'**
  String get audioRecordStartError;

  /// Error when recording fails to stop
  ///
  /// In en, this message translates to:
  /// **'Unable to stop the recording. Please try again.'**
  String get audioRecordStopError;

  /// Footer in APPLICATION settings section when user has active PRO subscription
  ///
  /// In en, this message translates to:
  /// **'You are a PRO user. Next payment {price} will be at {date}.'**
  String proUserFooter(String price, String date);

  /// Emotions feature title
  ///
  /// In en, this message translates to:
  /// **'Emotions'**
  String get emotions;

  /// Title for the archived emotions screen and section
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// Action to archive an emotion
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// Action to restore an archived emotion
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// Action to permanently delete an archived emotion
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deletePermanently;

  /// Title for the create-emotion form
  ///
  /// In en, this message translates to:
  /// **'New emotion'**
  String get newEmotion;

  /// Title for the edit-emotion form
  ///
  /// In en, this message translates to:
  /// **'Edit emotion'**
  String get editEmotion;

  /// Link to create a new emotion at the current level
  ///
  /// In en, this message translates to:
  /// **'Add emotion'**
  String get addEmotion;

  /// Button on a mind card that opens the emotion marking sheet
  ///
  /// In en, this message translates to:
  /// **'Add emotions'**
  String get addEmotionsToMind;

  /// Placeholder for the emotion title field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get emotionNameHint;

  /// Hint link that exits emotion edit mode
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneEditing;

  /// Hint shown while the emotion marking sheet is in edit mode
  ///
  /// In en, this message translates to:
  /// **'Tap to rename · ✕ to remove · drag to reorder'**
  String get emotionEditHint;

  /// Message when removing an emotion used by minds, offering archive or delete
  ///
  /// In en, this message translates to:
  /// **'This emotion is used by some minds. Archive it to keep it there, or delete it everywhere.'**
  String get emotionInUseMessage;

  /// Empty state for the emotions list
  ///
  /// In en, this message translates to:
  /// **'No emotions yet'**
  String get noEmotionsYet;

  /// Empty state for the archived emotions screen
  ///
  /// In en, this message translates to:
  /// **'No archived emotions'**
  String get noArchivedEmotions;

  /// Confirmation when permanently deleting an emotion
  ///
  /// In en, this message translates to:
  /// **'Delete this emotion? It will be removed from any minds using it.'**
  String get deleteEmotionMessage;

  /// Unified day grid (All mode) label
  ///
  /// In en, this message translates to:
  /// **'Tile settings'**
  String get dayFeedTileSettings;

  /// Unified day grid (All mode) label
  ///
  /// In en, this message translates to:
  /// **'Columns'**
  String get dayFeedColumns;

  /// Unified day grid (All mode) label
  ///
  /// In en, this message translates to:
  /// **'Mind tile size'**
  String get dayFeedMindTileSize;

  /// Unified day grid (All mode) label
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get dayFeedMindTileSquare;

  /// Unified day grid (All mode) label
  ///
  /// In en, this message translates to:
  /// **'Wide'**
  String get dayFeedMindTileWide;

  /// Unified day grid (All mode) label
  ///
  /// In en, this message translates to:
  /// **'Show text'**
  String get dayFeedShowMindText;

  /// Banner in the unified day grid when photo access is missing
  ///
  /// In en, this message translates to:
  /// **'Allow photo access to see your photos and videos here'**
  String get dayFeedPhotoAccessHint;

  /// Unified day grid (All mode) label
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get dayFeedAllowAccess;

  /// Banner in the unified day grid on Android when no media folder is chosen
  ///
  /// In en, this message translates to:
  /// **'Choose a media folder to see your photos and videos here'**
  String get dayFeedFolderHint;

  /// Unified day grid (All mode) label
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get dayFeedChooseFolder;

  /// Audio/video mind recording
  ///
  /// In en, this message translates to:
  /// **'Hold to record a voice message'**
  String get holdToRecordAudio;

  /// Audio/video mind recording
  ///
  /// In en, this message translates to:
  /// **'Hold to record a video message'**
  String get holdToRecordVideo;

  /// Audio/video mind recording
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t record the video'**
  String get roundVideoRecordError;

  /// Audio/video mind recording
  ///
  /// In en, this message translates to:
  /// **'Camera is unavailable on this device'**
  String get roundVideoCameraUnavailable;

  /// Audio/video mind recording
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get roundVideoRetake;

  /// Audio/video mind recording
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get roundVideoUse;

  /// Audio/video mind recording
  ///
  /// In en, this message translates to:
  /// **'Remove media'**
  String get removeMedia;

  /// Shake-to-customize: shakeToCustomize
  ///
  /// In en, this message translates to:
  /// **'Shake to customize'**
  String get shakeToCustomize;

  /// Shake-to-customize: shakeToCustomizeHint
  ///
  /// In en, this message translates to:
  /// **'or long-press the title'**
  String get shakeToCustomizeHint;

  /// Shake-to-customize: customizeSettings
  ///
  /// In en, this message translates to:
  /// **'Customize settings'**
  String get customizeSettings;

  /// Shake-to-customize: customizeSettingsDescription
  ///
  /// In en, this message translates to:
  /// **'Unchecked sections and rows are hidden from the Settings screen.'**
  String get customizeSettingsDescription;

  /// Calendar shake sheet title
  ///
  /// In en, this message translates to:
  /// **'Calendar settings'**
  String get calendarSettings;

  /// Calendar setting: show gallery media in day grids
  ///
  /// In en, this message translates to:
  /// **'Show photos and videos'**
  String get calendarShowMedia;

  /// Calendar setting: show week number headers
  ///
  /// In en, this message translates to:
  /// **'Week titles'**
  String get calendarWeekTitles;

  /// Calendar: play the stories of a day or a week
  ///
  /// In en, this message translates to:
  /// **'Play stories'**
  String get calendarPlayStories;

  /// Story/viewer shake sheet title
  ///
  /// In en, this message translates to:
  /// **'Story background'**
  String get storyBackgroundTweak;

  /// Texture animation: none
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get storyAnimationOff;

  /// Texture animation: emojis grow with loudness
  ///
  /// In en, this message translates to:
  /// **'Pulse'**
  String get storyAnimationPulse;

  /// Texture animation: rows sway like a wave
  ///
  /// In en, this message translates to:
  /// **'Wave'**
  String get storyAnimationWave;

  /// Texture animation: columns bounce like bars
  ///
  /// In en, this message translates to:
  /// **'Equalizer'**
  String get storyAnimationEqualizer;

  /// Texture animation: texture slides, faster when louder
  ///
  /// In en, this message translates to:
  /// **'Drift'**
  String get storyAnimationDrift;

  /// Texture animation: opacity and blur follow loudness
  ///
  /// In en, this message translates to:
  /// **'Glow'**
  String get storyAnimationGlow;

  /// Viewer: placeholder of the comment field
  ///
  /// In en, this message translates to:
  /// **'Comment…'**
  String get viewerCommentHint;

  /// Calendar: bubble that scrolls back to the current week
  ///
  /// In en, this message translates to:
  /// **'To current week'**
  String get calendarToCurrentWeek;

  /// Story tweak: how many lines the date header takes
  ///
  /// In en, this message translates to:
  /// **'Date lines'**
  String get storyDateLines;

  /// Story tweak: texture animation section
  ///
  /// In en, this message translates to:
  /// **'Texture'**
  String get storyTextureTitle;

  /// Story tweak: rays around audio/video circles
  ///
  /// In en, this message translates to:
  /// **'Sound spectrum'**
  String get storySpectrum;

  /// Story tweak: how strongly visuals react to loudness
  ///
  /// In en, this message translates to:
  /// **'Sensitivity'**
  String get storySensitivity;

  /// Insights header: number of days with at least one mind
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Mindful for {count} day} other{Mindful for {count} days}}'**
  String profileMindfulDays(int count);

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileName;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get profilePhoto;

  /// No description provided for @profileEmoji.
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get profileEmoji;

  /// No description provided for @profileInitial.
  ///
  /// In en, this message translates to:
  /// **'Letter'**
  String get profileInitial;

  /// No description provided for @webVersion.
  ///
  /// In en, this message translates to:
  /// **'Web version'**
  String get webVersion;

  /// No description provided for @webVersionAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Open in a browser on a computer in the same Wi-Fi; keep keklist open'**
  String get webVersionAddressHint;

  /// No description provided for @webVersionCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get webVersionCopied;

  /// No description provided for @webVersionStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting…'**
  String get webVersionStarting;

  /// No description provided for @webVersionNoWifi.
  ///
  /// In en, this message translates to:
  /// **'Connect to Wi-Fi to open keklist in a browser.'**
  String get webVersionNoWifi;

  /// No description provided for @webVersionNoBundle.
  ///
  /// In en, this message translates to:
  /// **'This build doesn\'t include the web version.'**
  String get webVersionNoBundle;

  /// No description provided for @webVersionPin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get webVersionPin;

  /// No description provided for @webVersionPinSet.
  ///
  /// In en, this message translates to:
  /// **'Each browser asks for it once in 30 days'**
  String get webVersionPinSet;

  /// No description provided for @webVersionPinNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get webVersionPinNotSet;

  /// No description provided for @webVersionPinHint.
  ///
  /// In en, this message translates to:
  /// **'4–8 digits'**
  String get webVersionPinHint;

  /// No description provided for @webVersionRemovePin.
  ///
  /// In en, this message translates to:
  /// **'Remove PIN'**
  String get webVersionRemovePin;

  /// No description provided for @webVersionPort.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get webVersionPort;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get aiTab;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Talk about your records with an AI that runs on your phone'**
  String get aiTabDescription;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Runs on your phone only: your records never leave the device.'**
  String get aiPrivacyNote;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Not a medical service. If you are in danger, contact emergency services.'**
  String get aiDisclaimer;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get aiYesterday;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get aiNoSessions;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'New session'**
  String get aiNewSession;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Choose a role'**
  String get aiChooseRole;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Therapist'**
  String get aiRoleTherapist;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get aiRoleCoach;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get aiRoleFriend;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get aiMessageHint;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'How was my week?'**
  String get aiStarterWeek;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'What has been bothering me lately?'**
  String get aiStarterWorry;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'What brought me joy recently?'**
  String get aiStarterJoy;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Save as mind'**
  String get aiActionSaveAsMind;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Open day'**
  String get aiActionOpenDay;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Week summary'**
  String get aiActionWeekSummary;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Summarize my last 7 days: what happened, how I felt, what stood out.'**
  String get aiWeekSummaryPrompt;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Saved to today'**
  String get aiSavedAsMind;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get aiStop;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Choose a model'**
  String get aiNoModelTitle;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Download a model to start. It runs on your phone, offline.'**
  String get aiNoModelMessage;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Download a model in the phone app: Settings → AI → Models.'**
  String get aiNoModelOnPhone;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Models'**
  String get aiModels;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get aiRoles;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get aiDownloaded;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get aiDownloads;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Google AI Edge Gallery'**
  String get aiGalleryCatalog;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Hugging Face (GGUF)'**
  String get aiHuggingFace;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Search GGUF models'**
  String get aiSearchModels;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get aiDownload;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get aiPause;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get aiPaused;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get aiResume;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get aiDownloadFailed;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Download over mobile data?'**
  String get aiCellularTitle;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'{size} will be downloaded over mobile data.'**
  String aiCellularMessage(String size);

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Delete the model?'**
  String get aiDeleteModel;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'On this phone: {size}'**
  String aiStorageUsed(String size);

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Phone memory: {size}'**
  String aiDeviceMemory(String size);

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the list. Check the connection.'**
  String get aiCatalogFailed;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'None of this model\'s files fit this phone\'s memory.'**
  String get aiNoFilesFit;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get aiBuiltInRole;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Your roles'**
  String get aiOwnRoles;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get aiDuplicate;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'New role'**
  String get aiNewRole;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get aiRoleName;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get aiRoleEmoji;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Prompt'**
  String get aiRolePrompt;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'How the AI should talk and what to focus on'**
  String get aiRolePromptHint;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Built-in roles can\'t be changed. Duplicate one to make your own.'**
  String get aiReadOnlyRole;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Delete the session?'**
  String get aiDeleteSession;

  /// AI tab
  ///
  /// In en, this message translates to:
  /// **'Delete the role?'**
  String get aiDeleteRole;

  /// AI models: badge on the recommended model
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get aiRecommended;

  /// AI models: badge on models under 1B parameters
  ///
  /// In en, this message translates to:
  /// **'Low quality'**
  String get aiLowQuality;

  /// AI chat: the model could not be loaded
  ///
  /// In en, this message translates to:
  /// **'This model doesn\'t fit in your phone\'s memory. Choose a smaller one.'**
  String get aiModelDoesNotFit;

  /// AI chat: button that opens the models screen
  ///
  /// In en, this message translates to:
  /// **'Choose another model'**
  String get aiChooseAnotherModel;

  /// Mind creator tweak sheet: title
  ///
  /// In en, this message translates to:
  /// **'Emotions'**
  String get creatorEmotionsTitle;

  /// Mind creator tweak: ask for emotions after Save
  ///
  /// In en, this message translates to:
  /// **'Ask after saving'**
  String get creatorEmotionsAfterSave;

  /// Mind creator tweak: an emotions button above the keyboard
  ///
  /// In en, this message translates to:
  /// **'Button above the keyboard'**
  String get creatorEmotionsButton;

  /// Mind creator tweak: don't ask for emotions
  ///
  /// In en, this message translates to:
  /// **'Don\'t ask'**
  String get creatorEmotionsNever;

  /// Insights memories: a week ago
  ///
  /// In en, this message translates to:
  /// **'A week ago'**
  String get insightsWeekAgo;

  /// Insights memories: a month ago
  ///
  /// In en, this message translates to:
  /// **'A month ago'**
  String get insightsMonthAgo;

  /// Insights memories: half a year ago
  ///
  /// In en, this message translates to:
  /// **'Half a year ago'**
  String get insightsHalfYearAgo;

  /// Insights memories: a year ago
  ///
  /// In en, this message translates to:
  /// **'A year ago'**
  String get insightsYearAgo;

  /// Insights memories: two years ago
  ///
  /// In en, this message translates to:
  /// **'Two years ago'**
  String get insightsTwoYearsAgo;

  /// Insights card: voice notes and round videos
  ///
  /// In en, this message translates to:
  /// **'Voice and round videos'**
  String get insightsVoiceAndVideos;

  /// Insights brightest week: week number of the year
  ///
  /// In en, this message translates to:
  /// **'Week {number}'**
  String insightsWeekNumber(String number);

  /// Hint under the empty list of chat sessions
  ///
  /// In en, this message translates to:
  /// **'Ask about your week, a worry or a good day: the chat reads your records right on the phone.'**
  String get aiNoSessionsHint;

  /// Context menu item that opens the photo in the system gallery
  ///
  /// In en, this message translates to:
  /// **'Show in Gallery'**
  String get showInGallery;

  /// Tweak: how emojis move on mind tiles
  ///
  /// In en, this message translates to:
  /// **'Emoji motion'**
  String get tileEmojiMotion;

  /// Emoji motion option: slow diagonal drift
  ///
  /// In en, this message translates to:
  /// **'Drift'**
  String get tileEmojiMotionDrift;

  /// Emoji motion option: sway in place
  ///
  /// In en, this message translates to:
  /// **'Float'**
  String get tileEmojiMotionFloat;

  /// Emoji motion option: no motion
  ///
  /// In en, this message translates to:
  /// **'Still'**
  String get tileEmojiMotionStill;

  /// Tweak: animation when a pinch changes the column count
  ///
  /// In en, this message translates to:
  /// **'Pinch animation'**
  String get gridResizeAnimation;

  /// Pinch animation option: tiles fly to new places
  ///
  /// In en, this message translates to:
  /// **'Fly'**
  String get gridResizeFly;

  /// Pinch animation option: live zoom
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get gridResizeZoom;

  /// Pinch animation option: crossfade
  ///
  /// In en, this message translates to:
  /// **'Fade'**
  String get gridResizeCrossfade;

  /// Tweak sheet: order of day tiles
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get feedSortOrder;

  /// Order option: by time
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get feedSortTime;

  /// Order option: notes before photos
  ///
  /// In en, this message translates to:
  /// **'Notes first'**
  String get feedSortMindsFirst;

  /// Order option: photos before notes
  ///
  /// In en, this message translates to:
  /// **'Media first'**
  String get feedSortMediaFirst;

  /// Tweak sheet: grouping of day tiles
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get feedGrouping;

  /// Grouping option: none
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get feedGroupingNone;

  /// Grouping option: notes and gallery
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get feedGroupingType;

  /// Grouping option: morning, afternoon, evening, night
  ///
  /// In en, this message translates to:
  /// **'Time of day'**
  String get feedGroupingTimeOfDay;

  /// Section header over the notes of a day
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get feedSectionMinds;

  /// Section header over the photos and videos of a day
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get feedSectionGallery;

  /// Title of the sheet shown before removing a photo
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhotoTitle;

  /// Title of the sheet shown before removing a video
  ///
  /// In en, this message translates to:
  /// **'Remove video'**
  String get removeVideoTitle;

  /// Hide a photo or video from keklist only
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hideMedia;

  /// Under Hide: the file stays in the gallery
  ///
  /// In en, this message translates to:
  /// **'Only from keklist, it stays in the gallery'**
  String get hideMediaSubtitle;

  /// Delete a photo or video from the phone gallery
  ///
  /// In en, this message translates to:
  /// **'Delete from gallery'**
  String get deleteFromGallery;

  /// Under Delete from gallery
  ///
  /// In en, this message translates to:
  /// **'Moves to Recently Deleted'**
  String get deleteFromGallerySubtitle;

  /// Snackbar after hiding a photo
  ///
  /// In en, this message translates to:
  /// **'Hidden from keklist'**
  String get mediaHidden;

  /// Snackbar after showing a hidden photo again
  ///
  /// In en, this message translates to:
  /// **'Back in keklist'**
  String get mediaShownAgain;

  /// Undo the last action
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Settings row and screen with photos hidden from keklist
  ///
  /// In en, this message translates to:
  /// **'Hidden photos'**
  String get hiddenMedia;

  /// Hint on the hidden photos screen
  ///
  /// In en, this message translates to:
  /// **'Tap a photo to show it in keklist again'**
  String get hiddenMediaHint;

  /// Hidden photos screen without photos
  ///
  /// In en, this message translates to:
  /// **'Nothing is hidden'**
  String get hiddenMediaEmpty;

  /// Settings row and sheet title for sending feedback to the developer
  ///
  /// In en, this message translates to:
  /// **'Leave feedback'**
  String get leaveFeedback;

  /// Placeholder of the feedback field
  ///
  /// In en, this message translates to:
  /// **'What do you like, what\'s broken, what\'s missing?'**
  String get feedbackHint;

  /// Under the feedback field: what is sent
  ///
  /// In en, this message translates to:
  /// **'Only this text, the app version and the platform are sent.'**
  String get feedbackPrivacy;

  /// Send feedback button
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get feedbackSend;

  /// Snackbar after feedback was sent
  ///
  /// In en, this message translates to:
  /// **'Thanks! The developer got your message'**
  String get feedbackSent;

  /// Snackbar when feedback could not be sent
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send. Check the internet and try again'**
  String get feedbackFailed;

  /// Settings row and screen title for anonymous usage analytics
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// Explains what analytics is for on the analytics screen
  ///
  /// In en, this message translates to:
  /// **'Anonymous usage statistics help decide what to improve. Nothing you write ever leaves your device.'**
  String get analyticsDescription;

  /// Shown on the analytics screen in builds that never send analytics (debug, web)
  ///
  /// In en, this message translates to:
  /// **'This build sends nothing: analytics runs only in App Store and Google Play builds.'**
  String get analyticsStoreBuildsOnly;

  /// Heading of the list of data analytics sends
  ///
  /// In en, this message translates to:
  /// **'What is sent'**
  String get analyticsSent;

  /// List of data analytics sends
  ///
  /// In en, this message translates to:
  /// **'Which settings and tweaks you choose, which screens you open, the app version, platform and language, Pro and tip purchases, and crash reports without their messages.'**
  String get analyticsSentItems;

  /// Heading of the list of data analytics never sends
  ///
  /// In en, this message translates to:
  /// **'Never sent'**
  String get analyticsNeverSent;

  /// List of data analytics never sends
  ///
  /// In en, this message translates to:
  /// **'Your minds, their text, emotions and comments, photos, videos and audio, how many of them you have, your name, your location and your IP address.'**
  String get analyticsNeverSentItems;

  /// Button that replaces the anonymous analytics id
  ///
  /// In en, this message translates to:
  /// **'Reset anonymous ID'**
  String get analyticsResetId;

  /// Snackbar after the anonymous analytics id is reset
  ///
  /// In en, this message translates to:
  /// **'A new anonymous ID is used from now on'**
  String get analyticsResetIdDone;

  /// Settings section with the subscription, tips and feedback
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupport;

  /// Button under a calendar day that opens the day screen
  ///
  /// In en, this message translates to:
  /// **'Open day'**
  String get calendarOpenDay;

  /// Switch that turns the phone's web version server on or off
  ///
  /// In en, this message translates to:
  /// **'Serve web version'**
  String get webVersionEnabled;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'it',
    'ja',
    'kk',
    'ky',
    'ru',
    'sr',
    'uz',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'sr':
      {
        switch (locale.scriptCode) {
          case 'Latn':
            return AppLocalizationsSrLatn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'kk':
      return AppLocalizationsKk();
    case 'ky':
      return AppLocalizationsKy();
    case 'ru':
      return AppLocalizationsRu();
    case 'sr':
      return AppLocalizationsSr();
    case 'uz':
      return AppLocalizationsUz();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
