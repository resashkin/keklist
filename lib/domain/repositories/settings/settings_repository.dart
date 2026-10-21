import 'dart:async';
import 'dart:ui';

import 'package:keklist/domain/repositories/settings/keklist_interface_style.dart';
import 'package:keklist/domain/repositories/settings/keklist_theme_mode.dart';
import 'package:keklist/domain/repositories/settings/object/settings_object.dart';
import 'package:keklist/domain/services/language_manager.dart';

abstract class SettingsRepository {
  KeklistSettings get value;
  Stream<KeklistSettings> get stream;
  FutureOr<void> updateUserName(String string);
  FutureOr<void> updateSettings(KeklistSettings settings);
  FutureOr<void> updateThemePreference(KeklistThemeMode themeMode);
  FutureOr<void> updateInterfaceStyle(KeklistInterfaceStyle style);
  FutureOr<void> updateShouldShowTitles(bool shouldShowTitles);
  FutureOr<void> updatePreviousAppVersion(String? previousAppVersion);
  FutureOr<void> updateLanguage(SupportedLanguage language);
  FutureOr<void> updateWeatherSettings({bool? isEnabled, double? latitude, double? longitude});
  FutureOr<void> updateMediaFolderSource({String? folderPath, bool? isRecursive});
  FutureOr<void> updateHasSeededEmotions(bool value);
  FutureOr<void> updateDayFeedSettings({
    int? columnCount,
    int? mindCellSpan,
    bool? isMindTextVisible,
  });
  FutureOr<void> updateSettingsItemHidden(String id, {required bool isHidden});
  FutureOr<void> markShakeDiscovered(String screenId);
}

final class DayFeedSettings {
  static const List<int> columnCountOptions = [3, 4, 5];

  final int columnCount;
  final int mindCellSpan;
  final bool isMindTextVisible;

  const DayFeedSettings({
    this.columnCount = 4,
    this.mindCellSpan = 1,
    this.isMindTextVisible = true,
  });
}

/// Calendar day grids; week titles stay in `KeklistSettings.shouldShowTitles`.
final class CalendarSettings {
  final int columnCount;
  final bool isMindTextVisible;
  final bool isMediaVisible;
  final bool hidesEmptyDays;

  const CalendarSettings({
    this.columnCount = 4,
    this.isMindTextVisible = true,
    this.isMediaVisible = true,
    this.hidesEmptyDays = false,
  });

  CalendarSettings copyWith({int? columnCount, bool? isMindTextVisible, bool? isMediaVisible, bool? hidesEmptyDays}) =>
      CalendarSettings(
        columnCount: columnCount ?? this.columnCount,
        isMindTextVisible: isMindTextVisible ?? this.isMindTextVisible,
        isMediaVisible: isMediaVisible ?? this.isMediaVisible,
        hidesEmptyDays: hidesEmptyDays ?? this.hidesEmptyDays,
      );
}

/// Analytics screen layout: widget order (unknown ids ignored), hidden widgets and the period.
final class InsightsSettings {
  final List<String> widgetOrder;
  final Set<String> hiddenWidgetIds;
  final int periodIndex;

  const InsightsSettings({this.widgetOrder = const [], this.hiddenWidgetIds = const {}, this.periodIndex = 1});

  InsightsSettings copyWith({List<String>? widgetOrder, Set<String>? hiddenWidgetIds, int? periodIndex}) =>
      InsightsSettings(
        widgetOrder: widgetOrder ?? this.widgetOrder,
        hiddenWidgetIds: hiddenWidgetIds ?? this.hiddenWidgetIds,
        periodIndex: periodIndex ?? this.periodIndex,
      );
}

final class KeklistSettings {
  final String? previousAppVersion;
  final KeklistThemeMode themePreference;
  final KeklistInterfaceStyle interfaceStyle;
  final bool shouldShowTitles;
  final String? userName;
  final SupportedLanguage language;
  final int dataSchemaVersion;
  final bool hasSeenLazyOnboarding;
  final bool isDebugMenuVisible;
  final bool isWeatherSourceEnabled;
  final double? weatherLatitude;
  final double? weatherLongitude;
  final String? mediaFolderPath;
  final bool isMediaFolderRecursive;

  /// Set once the starter emotions have been created, so they are never seeded
  /// twice — including after the user deletes them all. See ADR-0003.
  final bool hasSeededEmotions;

  final DayFeedSettings dayFeed;
  final InsightsSettings insights;
  final CalendarSettings calendar;
  final Set<String> hiddenSettingsItemIds;
  final Set<String> shakeDiscoveredScreenIds;

  KeklistSettings({
    required this.previousAppVersion,
    required this.themePreference,
    required this.interfaceStyle,
    required this.shouldShowTitles,
    required this.userName,
    required this.language,
    required this.dataSchemaVersion,
    required this.hasSeenLazyOnboarding,
    required this.isDebugMenuVisible,
    this.isWeatherSourceEnabled = false,
    this.weatherLatitude,
    this.weatherLongitude,
    this.mediaFolderPath,
    this.isMediaFolderRecursive = false,
    this.hasSeededEmotions = false,
    this.dayFeed = const DayFeedSettings(),
    this.insights = const InsightsSettings(),
    this.calendar = const CalendarSettings(),
    this.hiddenSettingsItemIds = const {},
    this.shakeDiscoveredScreenIds = const {},
  });

  KeklistSettings copyWith({
    String? previousAppVersion,
    KeklistThemeMode? themePreference,
    KeklistInterfaceStyle? interfaceStyle,
    bool? shouldShowTitles,
    String? userName,
    SupportedLanguage? language,
    int? dataSchemaVersion,
    bool? hasSeenLazyOnboarding,
    bool? isDebugMenuVisible,
    bool? isWeatherSourceEnabled,
    double? weatherLatitude,
    double? weatherLongitude,
    String? mediaFolderPath,
    bool? isMediaFolderRecursive,
    bool? hasSeededEmotions,
    DayFeedSettings? dayFeed,
    InsightsSettings? insights,
    CalendarSettings? calendar,
    Set<String>? hiddenSettingsItemIds,
    Set<String>? shakeDiscoveredScreenIds,
  }) {
    return KeklistSettings(
      previousAppVersion: previousAppVersion ?? this.previousAppVersion,
      themePreference: themePreference ?? this.themePreference,
      interfaceStyle: interfaceStyle ?? this.interfaceStyle,
      shouldShowTitles: shouldShowTitles ?? this.shouldShowTitles,
      userName: userName ?? this.userName,
      language: language ?? this.language,
      dataSchemaVersion: dataSchemaVersion ?? this.dataSchemaVersion,
      hasSeenLazyOnboarding: hasSeenLazyOnboarding ?? this.hasSeenLazyOnboarding,
      isDebugMenuVisible: isDebugMenuVisible ?? this.isDebugMenuVisible,
      isWeatherSourceEnabled: isWeatherSourceEnabled ?? this.isWeatherSourceEnabled,
      weatherLatitude: weatherLatitude ?? this.weatherLatitude,
      weatherLongitude: weatherLongitude ?? this.weatherLongitude,
      mediaFolderPath: mediaFolderPath ?? this.mediaFolderPath,
      isMediaFolderRecursive: isMediaFolderRecursive ?? this.isMediaFolderRecursive,
      hasSeededEmotions: hasSeededEmotions ?? this.hasSeededEmotions,
      dayFeed: dayFeed ?? this.dayFeed,
      insights: insights ?? this.insights,
      calendar: calendar ?? this.calendar,
      hiddenSettingsItemIds: hiddenSettingsItemIds ?? this.hiddenSettingsItemIds,
      shakeDiscoveredScreenIds: shakeDiscoveredScreenIds ?? this.shakeDiscoveredScreenIds,
    );
  }

  SettingsObject toObject() => SettingsObject()
    ..previousAppVersion = previousAppVersion
    ..isDarkMode = themePreference == KeklistThemeMode.dark
    ..themePreferenceIndex = themePreference.index
    ..interfaceStyleIndex = interfaceStyle.index
    ..shouldShowTitles = shouldShowTitles
    ..userName = userName
    ..language = language.code
    ..dataSchemaVersion = dataSchemaVersion
    ..hasSeenLazyOnboarding = hasSeenLazyOnboarding
    ..isDebugMenuVisible = isDebugMenuVisible
    ..isWeatherSourceEnabled = isWeatherSourceEnabled
    ..weatherLatitude = weatherLatitude
    ..weatherLongitude = weatherLongitude
    ..mediaFolderPath = mediaFolderPath
    ..isMediaFolderRecursive = isMediaFolderRecursive
    ..hasSeededEmotions = hasSeededEmotions
    ..dayFeedColumnCount = dayFeed.columnCount
    ..dayFeedMindCellSpan = dayFeed.mindCellSpan
    ..isDayFeedMindTextVisible = dayFeed.isMindTextVisible
    ..insightsWidgetOrder = insights.widgetOrder
    ..hiddenInsightsWidgetIds = insights.hiddenWidgetIds.toList()
    ..insightsPeriodIndex = insights.periodIndex
    ..calendarColumnCount = calendar.columnCount
    ..isCalendarMindTextVisible = calendar.isMindTextVisible
    ..isCalendarMediaVisible = calendar.isMediaVisible
    ..calendarHidesEmptyDays = calendar.hidesEmptyDays
    ..hiddenSettingsItemIds = hiddenSettingsItemIds.toList()
    ..shakeDiscoveredScreenIds = shakeDiscoveredScreenIds.toList();

  factory KeklistSettings.initial() => KeklistSettings(
        previousAppVersion: null,
        themePreference: KeklistThemeMode.system,
        interfaceStyle: KeklistInterfaceStyle.liquidGlass,
        shouldShowTitles: true,
        userName: null,
        language: _detectDeviceLocale(),
        dataSchemaVersion: 0,
        hasSeenLazyOnboarding: false,
        isDebugMenuVisible: false,
        isWeatherSourceEnabled: false,
        weatherLatitude: null,
        weatherLongitude: null,
        mediaFolderPath: null,
        isMediaFolderRecursive: false,
        hasSeededEmotions: false,
      );

  /// Detect device locale and return supported language or fallback to English
  static SupportedLanguage _detectDeviceLocale() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    final deviceLanguageCode = deviceLocale.languageCode;
    final deviceScriptCode = deviceLocale.scriptCode;

    // Special handling for Serbian with script detection
    if (deviceLanguageCode == 'sr') {
      if (deviceScriptCode == 'Latn') {
        return SupportedLanguage.serbianLatin;
      } else {
        return SupportedLanguage.serbian;
      }
    }

    // Try to find exact match
    for (final language in SupportedLanguage.values) {
      if (language.code == deviceLanguageCode) {
        return language;
      }
    }

    // Try to find partial match (e.g., 'zh-CN' -> 'zh')
    for (final language in SupportedLanguage.values) {
      if (deviceLanguageCode.startsWith(language.code)) {
        return language;
      }
    }

    // Fallback to English
    return SupportedLanguage.english;
  }
}
