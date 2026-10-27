import 'package:material_ui/material_ui.dart';

abstract final class SettingsItemIds {
  static const String activeTasksSection = 'section.activeTasks';
  static const String userDataSection = 'section.userData';
  static const String webVersionSection = 'section.webVersion';
  static const String aiSection = 'section.ai';
  static const String supportSection = 'section.support';
  static const String appearanceSection = 'section.appearance';
  static const String aboutSection = 'section.about';
  static const String dangerZoneSection = 'section.dangerZone';
  static const String developerSection = 'section.developer';

  static const String exportData = 'row.exportData';
  static const String importData = 'row.importData';
  static const String galleryIndex = 'row.galleryIndex';
  static const String hiddenMedia = 'row.hiddenMedia';
  static const String pro = 'row.pro';
  static const String proStatus = 'row.proStatus';
  static const String tips = 'row.tips';
  static const String leaveFeedback = 'row.leaveFeedback';
  static const String analytics = 'row.analytics';
  static const String language = 'row.language';
  static const String appearance = 'row.appearance';
  static const String tabsSettings = 'row.tabsSettings';
  static const String debugMenu = 'row.debugMenu';
  static const String sourceCode = 'row.sourceCode';
  static const String termsOfUse = 'row.termsOfUse';
  static const String privacyPolicy = 'row.privacyPolicy';
  static const String licenses = 'row.licenses';
  static const String clearOnDeviceData = 'row.clearOnDeviceData';
  static const String webVersionEnabled = 'row.webVersionEnabled';
  static const String webVersionAddress = 'row.webVersionAddress';
  static const String webVersionPin = 'row.webVersionPin';
  static const String webVersionPort = 'row.webVersionPort';
  static const String aiModels = 'row.aiModels';
  static const String aiRoles = 'row.aiRoles';
}

final class SettingsRowModel {
  final String id;
  final String title;
  final Widget? leading;
  final Widget tile;

  const SettingsRowModel({required this.id, required this.title, required this.tile, this.leading});
}

final class SettingsSectionModel {
  final String id;
  final String title;
  final List<SettingsRowModel> rows;

  const SettingsSectionModel({required this.id, required this.title, required this.rows});
}

extension SettingsSectionsVisibility on List<SettingsSectionModel> {
  List<SettingsSectionModel> visibleExcept(Set<String> hiddenIds) => [
    for (final SettingsSectionModel section in this)
      if (!hiddenIds.contains(section.id))
        SettingsSectionModel(
          id: section.id,
          title: section.title,
          rows: section.rows.where((row) => !hiddenIds.contains(row.id)).toList(),
        ),
  ].where((section) => section.rows.isNotEmpty).toList();
}
