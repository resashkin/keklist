import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:keklist/domain/repositories/settings/keklist_interface_style.dart';
import 'package:keklist/domain/repositories/settings/keklist_theme_mode.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/language_manager.dart';

part 'settings_object.g.dart';

@HiveType(typeId: 0)
final class SettingsObject extends HiveObject {
  // @HiveField(0, defaultValue: true)

  @HiveField(1, defaultValue: null)
  late String? previousAppVersion;

  // @HiveField(2, defaultValue: false)

  @HiveField(3, defaultValue: true)
  late bool isDarkMode;

  @HiveField(5, defaultValue: true)
  late bool shouldShowTitles;

  @HiveField(6, defaultValue: null)
  late String? userName;

  @HiveField(7, defaultValue: 'en')
  late String language;

  @HiveField(8, defaultValue: 0)
  late int dataSchemaVersion;

  @HiveField(9, defaultValue: false)
  late bool hasSeenLazyOnboarding;

  @HiveField(10, defaultValue: false)
  late bool isDebugMenuVisible;

  // @HiveField(11, defaultValue: false)

  @HiveField(12, defaultValue: false)
  late bool isWeatherSourceEnabled;

  @HiveField(13, defaultValue: null)
  late double? weatherLatitude;

  @HiveField(14, defaultValue: null)
  late double? weatherLongitude;

  // @HiveField(15, defaultValue: false)

  @HiveField(16, defaultValue: null)
  late String? mediaFolderPath;

  @HiveField(17, defaultValue: false)
  late bool isMediaFolderRecursive;

  // -1 = not yet migrated (fall back to isDarkMode); >= 0 = KeklistThemeMode.index
  @HiveField(18, defaultValue: -1)
  late int themePreferenceIndex;

  // Default 1 = Liquid Glass; platform gating forces Material on non-iOS at read time.
  @HiveField(19, defaultValue: 1)
  late int interfaceStyleIndex;

  @HiveField(20, defaultValue: false)
  late bool hasSeededEmotions;

  // @HiveField(21, defaultValue: false)

  @HiveField(22, defaultValue: 4)
  late int dayFeedColumnCount;

  @HiveField(23, defaultValue: 1)
  late int dayFeedMindCellSpan;

  @HiveField(24, defaultValue: true)
  late bool isDayFeedMindTextVisible;

  // @HiveField(25, defaultValue: true)

  @HiveField(26, defaultValue: <String>[])
  late List<String> hiddenSettingsItemIds;

  @HiveField(27, defaultValue: <String>[])
  late List<String> shakeDiscoveredScreenIds;

  @HiveField(28, defaultValue: <String>[])
  late List<String> insightsWidgetOrder;

  @HiveField(29, defaultValue: <String>[])
  late List<String> hiddenInsightsWidgetIds;

  @HiveField(30, defaultValue: 1)
  late int insightsPeriodIndex;

  @HiveField(31, defaultValue: 4)
  late int calendarColumnCount;

  @HiveField(32, defaultValue: true)
  late bool isCalendarMindTextVisible;

  @HiveField(33, defaultValue: true)
  late bool isCalendarMediaVisible;

  // @HiveField(34) held the removed "hide empty days" flag; never reuse it.
  @HiveField(35, defaultValue: 1)
  late int storyTextureAnimationIndex;

  @HiveField(36, defaultValue: 1)
  late int storyDateLayoutIndex;

  @HiveField(37, defaultValue: true)
  late bool isStorySpectrumVisible;

  @HiveField(38, defaultValue: 1.0)
  late double storySensitivity;

  @HiveField(39)
  late String? avatarEmoji;

  @HiveField(40)
  late String? avatarImagePath;

  @HiveField(41, defaultValue: 0)
  late int mindEmotionsPromptIndex;

  @HiveField(42, defaultValue: 0)
  late int tileEmojiMotionIndex;

  @HiveField(43, defaultValue: 0)
  late int gridResizeAnimationIndex;

  @HiveField(44, defaultValue: 0)
  late int dayFeedSortOrderIndex;

  @HiveField(45, defaultValue: 0)
  late int dayFeedGroupingIndex;

  @HiveField(46, defaultValue: 0)
  late int calendarSortOrderIndex;

  @HiveField(47, defaultValue: 0)
  late int calendarGroupingIndex;

  @HiveField(48, defaultValue: <String>[])
  late List<String> hiddenMediaIds;

  SettingsObject();

  KeklistSettings toSettings() => KeklistSettings(
        previousAppVersion: previousAppVersion,
        shouldShowTitles: shouldShowTitles,
        themePreference: themePreferenceIndex < 0
            ? (isDarkMode ? KeklistThemeMode.dark : KeklistThemeMode.light)
            : KeklistThemeMode.fromIndex(themePreferenceIndex),
        interfaceStyle: KeklistInterfaceStyle.fromIndex(interfaceStyleIndex),
        userName: userName,
        language: SupportedLanguage.fromCode(language),
        dataSchemaVersion: dataSchemaVersion,
        hasSeenLazyOnboarding: hasSeenLazyOnboarding,
        isDebugMenuVisible: isDebugMenuVisible,
        isWeatherSourceEnabled: isWeatherSourceEnabled,
        weatherLatitude: weatherLatitude,
        weatherLongitude: weatherLongitude,
        mediaFolderPath: mediaFolderPath,
        isMediaFolderRecursive: isMediaFolderRecursive,
        hasSeededEmotions: hasSeededEmotions,
        dayFeed: DayFeedSettings(
          columnCount: dayFeedColumnCount,
          mindCellSpan: dayFeedMindCellSpan,
          isMindTextVisible: isDayFeedMindTextVisible,
          sortOrder: FeedSortOrder.values.elementAtOrNull(dayFeedSortOrderIndex) ?? FeedSortOrder.time,
          grouping: FeedGrouping.values.elementAtOrNull(dayFeedGroupingIndex) ?? FeedGrouping.none,
        ),
        hiddenSettingsItemIds: hiddenSettingsItemIds.toSet(),
        hiddenMediaIds: hiddenMediaIds.toSet(),
        shakeDiscoveredScreenIds: shakeDiscoveredScreenIds.toSet(),
        insights: InsightsSettings(
          widgetOrder: insightsWidgetOrder,
          hiddenWidgetIds: hiddenInsightsWidgetIds.toSet(),
          periodIndex: insightsPeriodIndex,
        ),
        calendar: CalendarSettings(
          columnCount: calendarColumnCount,
          isMindTextVisible: isCalendarMindTextVisible,
          isMediaVisible: isCalendarMediaVisible,
          sortOrder: FeedSortOrder.values.elementAtOrNull(calendarSortOrderIndex) ?? FeedSortOrder.time,
          grouping: FeedGrouping.values.elementAtOrNull(calendarGroupingIndex) ?? FeedGrouping.none,
        ),
        story: StorySettings(
          textureAnimation:
              StoryTextureAnimation.values.elementAtOrNull(storyTextureAnimationIndex) ?? StoryTextureAnimation.pulse,
          dateLayout: StoryDateLayout.values.elementAtOrNull(storyDateLayoutIndex) ?? StoryDateLayout.twoLines,
          isSpectrumVisible: isStorySpectrumVisible,
          sensitivity: storySensitivity,
        ),
        avatar: UserAvatar(emoji: avatarEmoji, imagePath: avatarImagePath),
        mindEmotionsPrompt:
            MindEmotionsPrompt.values.elementAtOrNull(mindEmotionsPromptIndex) ?? MindEmotionsPrompt.afterSave,
        tileEmojiMotion: TileEmojiMotion.values.elementAtOrNull(tileEmojiMotionIndex) ?? TileEmojiMotion.drift,
        gridResizeAnimation:
            GridResizeAnimation.values.elementAtOrNull(gridResizeAnimationIndex) ?? GridResizeAnimation.fly,
      );
}
