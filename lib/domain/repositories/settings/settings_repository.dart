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
  FutureOr<void> updateUserAvatar(UserAvatar avatar);
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

/// How the mind creator asks for emotions; see `documentation/MIND_CREATOR_EMOTIONS.md`.
enum MindEmotionsPrompt { afterSave, button, never }

/// How the emojis of a mind tile move: a slow diagonal drift, a gentle sway in place, or not at all.
enum TileEmojiMotion { drift, float, still }

/// How a grid changes when a pinch changes its column count.
enum GridResizeAnimation { fly, zoom, crossfade }

final class DayFeedSettings {
  static const int minColumnCount = 2;
  static const int maxColumnCount = 7;
  static const List<int> columnCountOptions = [2, 3, 4, 5, 6, 7];

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

  const CalendarSettings({
    this.columnCount = 4,
    this.isMindTextVisible = true,
    this.isMediaVisible = true,
  });

  CalendarSettings copyWith({int? columnCount, bool? isMindTextVisible, bool? isMediaVisible}) => CalendarSettings(
    columnCount: columnCount ?? this.columnCount,
    isMindTextVisible: isMindTextVisible ?? this.isMindTextVisible,
    isMediaVisible: isMediaVisible ?? this.isMediaVisible,
  );
}

/// How the emotion texture behind a story or viewer page moves with the playing audio/video sound.
enum StoryTextureAnimation { off, pulse, wave, equalizer, drift, glow }

/// The date header of a story or viewer page: "21 October · Wednesday · 07:14" on one, two or three lines.
enum StoryDateLayout { oneLine, twoLines, threeLines }

/// Stories and viewer tweaks: texture animation, date header, sound spectrum around circles and how strongly
/// both react to loudness.
final class StorySettings {
  static const double minSensitivity = 0.5;
  static const double maxSensitivity = 3.0;

  final StoryTextureAnimation textureAnimation;
  final StoryDateLayout dateLayout;
  final bool isSpectrumVisible;
  final double sensitivity;

  const StorySettings({
    this.textureAnimation = StoryTextureAnimation.pulse,
    this.dateLayout = StoryDateLayout.twoLines,
    this.isSpectrumVisible = true,
    this.sensitivity = 1.0,
  });

  StorySettings copyWith({
    StoryTextureAnimation? textureAnimation,
    StoryDateLayout? dateLayout,
    bool? isSpectrumVisible,
    double? sensitivity,
  }) => StorySettings(
    textureAnimation: textureAnimation ?? this.textureAnimation,
    dateLayout: dateLayout ?? this.dateLayout,
    isSpectrumVisible: isSpectrumVisible ?? this.isSpectrumVisible,
    sensitivity: (sensitivity ?? this.sensitivity).clamp(minSensitivity, maxSensitivity),
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

/// The profile picture kept only on this device: a photo in the app folder, an emoji, or neither (the name's initial).
final class UserAvatar {
  final String? emoji;
  final String? imagePath;

  const UserAvatar({this.emoji, this.imagePath});

  @override
  bool operator ==(Object other) => other is UserAvatar && other.emoji == emoji && other.imagePath == imagePath;

  @override
  int get hashCode => Object.hash(emoji, imagePath);
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
  final StorySettings story;
  final UserAvatar avatar;
  final Set<String> hiddenSettingsItemIds;
  final Set<String> shakeDiscoveredScreenIds;
  final MindEmotionsPrompt mindEmotionsPrompt;
  final TileEmojiMotion tileEmojiMotion;
  final GridResizeAnimation gridResizeAnimation;

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
    this.story = const StorySettings(),
    this.avatar = const UserAvatar(),
    this.hiddenSettingsItemIds = const {},
    this.shakeDiscoveredScreenIds = const {},
    this.mindEmotionsPrompt = MindEmotionsPrompt.afterSave,
    this.tileEmojiMotion = TileEmojiMotion.drift,
    this.gridResizeAnimation = GridResizeAnimation.fly,
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
    StorySettings? story,
    UserAvatar? avatar,
    Set<String>? hiddenSettingsItemIds,
    Set<String>? shakeDiscoveredScreenIds,
    MindEmotionsPrompt? mindEmotionsPrompt,
    TileEmojiMotion? tileEmojiMotion,
    GridResizeAnimation? gridResizeAnimation,
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
      story: story ?? this.story,
      avatar: avatar ?? this.avatar,
      hiddenSettingsItemIds: hiddenSettingsItemIds ?? this.hiddenSettingsItemIds,
      shakeDiscoveredScreenIds: shakeDiscoveredScreenIds ?? this.shakeDiscoveredScreenIds,
      mindEmotionsPrompt: mindEmotionsPrompt ?? this.mindEmotionsPrompt,
      tileEmojiMotion: tileEmojiMotion ?? this.tileEmojiMotion,
      gridResizeAnimation: gridResizeAnimation ?? this.gridResizeAnimation,
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
    ..storyTextureAnimationIndex = story.textureAnimation.index
    ..storyDateLayoutIndex = story.dateLayout.index
    ..isStorySpectrumVisible = story.isSpectrumVisible
    ..storySensitivity = story.sensitivity
    ..avatarEmoji = avatar.emoji
    ..avatarImagePath = avatar.imagePath
    ..mindEmotionsPromptIndex = mindEmotionsPrompt.index
    ..tileEmojiMotionIndex = tileEmojiMotion.index
    ..gridResizeAnimationIndex = gridResizeAnimation.index
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
