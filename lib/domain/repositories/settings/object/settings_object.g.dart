// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_object.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsObjectAdapter extends TypeAdapter<SettingsObject> {
  @override
  final typeId = 0;

  @override
  SettingsObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsObject()
      ..previousAppVersion = fields[1] as String?
      ..isDarkMode = fields[3] == null ? true : fields[3] as bool
      ..shouldShowTitles = fields[5] == null ? true : fields[5] as bool
      ..userName = fields[6] as String?
      ..language = fields[7] == null ? 'en' : fields[7] as String
      ..dataSchemaVersion = fields[8] == null ? 0 : (fields[8] as num).toInt()
      ..hasSeenLazyOnboarding = fields[9] == null ? false : fields[9] as bool
      ..isDebugMenuVisible = fields[10] == null ? false : fields[10] as bool
      ..isWeatherSourceEnabled = fields[12] == null ? false : fields[12] as bool
      ..weatherLatitude = (fields[13] as num?)?.toDouble()
      ..weatherLongitude = (fields[14] as num?)?.toDouble()
      ..mediaFolderPath = fields[16] as String?
      ..isMediaFolderRecursive = fields[17] == null ? false : fields[17] as bool
      ..themePreferenceIndex = fields[18] == null
          ? -1
          : (fields[18] as num).toInt()
      ..interfaceStyleIndex = fields[19] == null
          ? 1
          : (fields[19] as num).toInt()
      ..hasSeededEmotions = fields[20] == null ? false : fields[20] as bool
      ..dayFeedColumnCount = fields[22] == null
          ? 4
          : (fields[22] as num).toInt()
      ..dayFeedMindCellSpan = fields[23] == null
          ? 1
          : (fields[23] as num).toInt()
      ..isDayFeedMindTextVisible = fields[24] == null
          ? true
          : fields[24] as bool
      ..hiddenSettingsItemIds = fields[26] == null
          ? []
          : (fields[26] as List).cast<String>()
      ..shakeDiscoveredScreenIds = fields[27] == null
          ? []
          : (fields[27] as List).cast<String>()
      ..insightsWidgetOrder = fields[28] == null
          ? []
          : (fields[28] as List).cast<String>()
      ..hiddenInsightsWidgetIds = fields[29] == null
          ? []
          : (fields[29] as List).cast<String>()
      ..insightsPeriodIndex = fields[30] == null
          ? 1
          : (fields[30] as num).toInt()
      ..calendarColumnCount = fields[31] == null
          ? 4
          : (fields[31] as num).toInt()
      ..isCalendarMindTextVisible = fields[32] == null
          ? true
          : fields[32] as bool
      ..isCalendarMediaVisible = fields[33] == null ? true : fields[33] as bool
      ..storyTextureAnimationIndex = fields[35] == null
          ? 1
          : (fields[35] as num).toInt()
      ..storyDateLayoutIndex = fields[36] == null
          ? 1
          : (fields[36] as num).toInt()
      ..isStorySpectrumVisible = fields[37] == null ? true : fields[37] as bool
      ..storySensitivity = fields[38] == null
          ? 1.0
          : (fields[38] as num).toDouble()
      ..avatarEmoji = fields[39] as String?
      ..avatarImagePath = fields[40] as String?
      ..mindEmotionsPromptIndex = fields[41] == null
          ? 0
          : (fields[41] as num).toInt()
      ..tileEmojiMotionIndex = fields[42] == null
          ? 0
          : (fields[42] as num).toInt()
      ..gridResizeAnimationIndex = fields[43] == null
          ? 0
          : (fields[43] as num).toInt()
      ..dayFeedSortOrderIndex = fields[44] == null
          ? 0
          : (fields[44] as num).toInt()
      ..dayFeedGroupingIndex = fields[45] == null
          ? 0
          : (fields[45] as num).toInt()
      ..calendarSortOrderIndex = fields[46] == null
          ? 0
          : (fields[46] as num).toInt()
      ..calendarGroupingIndex = fields[47] == null
          ? 0
          : (fields[47] as num).toInt()
      ..hiddenMediaIds = fields[48] == null
          ? []
          : (fields[48] as List).cast<String>()
      ..isAnalyticsEnabled = fields[49] == null ? true : fields[49] as bool;
  }

  @override
  void write(BinaryWriter writer, SettingsObject obj) {
    writer
      ..writeByte(42)
      ..writeByte(1)
      ..write(obj.previousAppVersion)
      ..writeByte(3)
      ..write(obj.isDarkMode)
      ..writeByte(5)
      ..write(obj.shouldShowTitles)
      ..writeByte(6)
      ..write(obj.userName)
      ..writeByte(7)
      ..write(obj.language)
      ..writeByte(8)
      ..write(obj.dataSchemaVersion)
      ..writeByte(9)
      ..write(obj.hasSeenLazyOnboarding)
      ..writeByte(10)
      ..write(obj.isDebugMenuVisible)
      ..writeByte(12)
      ..write(obj.isWeatherSourceEnabled)
      ..writeByte(13)
      ..write(obj.weatherLatitude)
      ..writeByte(14)
      ..write(obj.weatherLongitude)
      ..writeByte(16)
      ..write(obj.mediaFolderPath)
      ..writeByte(17)
      ..write(obj.isMediaFolderRecursive)
      ..writeByte(18)
      ..write(obj.themePreferenceIndex)
      ..writeByte(19)
      ..write(obj.interfaceStyleIndex)
      ..writeByte(20)
      ..write(obj.hasSeededEmotions)
      ..writeByte(22)
      ..write(obj.dayFeedColumnCount)
      ..writeByte(23)
      ..write(obj.dayFeedMindCellSpan)
      ..writeByte(24)
      ..write(obj.isDayFeedMindTextVisible)
      ..writeByte(26)
      ..write(obj.hiddenSettingsItemIds)
      ..writeByte(27)
      ..write(obj.shakeDiscoveredScreenIds)
      ..writeByte(28)
      ..write(obj.insightsWidgetOrder)
      ..writeByte(29)
      ..write(obj.hiddenInsightsWidgetIds)
      ..writeByte(30)
      ..write(obj.insightsPeriodIndex)
      ..writeByte(31)
      ..write(obj.calendarColumnCount)
      ..writeByte(32)
      ..write(obj.isCalendarMindTextVisible)
      ..writeByte(33)
      ..write(obj.isCalendarMediaVisible)
      ..writeByte(35)
      ..write(obj.storyTextureAnimationIndex)
      ..writeByte(36)
      ..write(obj.storyDateLayoutIndex)
      ..writeByte(37)
      ..write(obj.isStorySpectrumVisible)
      ..writeByte(38)
      ..write(obj.storySensitivity)
      ..writeByte(39)
      ..write(obj.avatarEmoji)
      ..writeByte(40)
      ..write(obj.avatarImagePath)
      ..writeByte(41)
      ..write(obj.mindEmotionsPromptIndex)
      ..writeByte(42)
      ..write(obj.tileEmojiMotionIndex)
      ..writeByte(43)
      ..write(obj.gridResizeAnimationIndex)
      ..writeByte(44)
      ..write(obj.dayFeedSortOrderIndex)
      ..writeByte(45)
      ..write(obj.dayFeedGroupingIndex)
      ..writeByte(46)
      ..write(obj.calendarSortOrderIndex)
      ..writeByte(47)
      ..write(obj.calendarGroupingIndex)
      ..writeByte(48)
      ..write(obj.hiddenMediaIds)
      ..writeByte(49)
      ..write(obj.isAnalyticsEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
