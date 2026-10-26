import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/presentation/screens/settings/settings_layout.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  SettingsRowModel row(String id) => SettingsRowModel(id: id, title: id, tile: const SizedBox.shrink());

  final List<SettingsSectionModel> sections = [
    SettingsSectionModel(
      id: SettingsItemIds.userDataSection,
      title: 'User data',
      rows: [row(SettingsItemIds.exportData), row(SettingsItemIds.importData)],
    ),
    SettingsSectionModel(
      id: SettingsItemIds.aboutSection,
      title: 'About',
      rows: [row(SettingsItemIds.sourceCode), row(SettingsItemIds.licenses)],
    ),
  ];

  List<String> sectionIds(List<SettingsSectionModel> result) => result.map((section) => section.id).toList();
  List<String> rowIds(SettingsSectionModel section) => section.rows.map((row) => row.id).toList();

  test('nothing hidden keeps everything in order', () {
    final List<SettingsSectionModel> result = sections.visibleExcept({});
    expect(sectionIds(result), [SettingsItemIds.userDataSection, SettingsItemIds.aboutSection]);
    expect(rowIds(result.first), [SettingsItemIds.exportData, SettingsItemIds.importData]);
  });

  test('hidden row is removed from its section', () {
    final List<SettingsSectionModel> result = sections.visibleExcept({SettingsItemIds.importData});
    expect(rowIds(result.first), [SettingsItemIds.exportData]);
    expect(rowIds(result.last), [SettingsItemIds.sourceCode, SettingsItemIds.licenses]);
  });

  test('hidden section is removed with its rows', () {
    final List<SettingsSectionModel> result = sections.visibleExcept({SettingsItemIds.userDataSection});
    expect(sectionIds(result), [SettingsItemIds.aboutSection]);
  });

  test('section with every row hidden is removed', () {
    final List<SettingsSectionModel> result = sections.visibleExcept({
      SettingsItemIds.sourceCode,
      SettingsItemIds.licenses,
    });
    expect(sectionIds(result), [SettingsItemIds.userDataSection]);
  });

  test('unknown ids are ignored', () {
    expect(sections.visibleExcept({'row.removedLongAgo'}).length, sections.length);
  });

  test('every id is unique', () {
    final List<String> ids = [
      SettingsItemIds.userDataSection,
      SettingsItemIds.applicationSection,
      SettingsItemIds.appearanceSection,
      SettingsItemIds.aboutSection,
      SettingsItemIds.dangerZoneSection,
      SettingsItemIds.exportData,
      SettingsItemIds.importData,
      SettingsItemIds.pro,
      SettingsItemIds.proStatus,
      SettingsItemIds.language,
      SettingsItemIds.appearance,
      SettingsItemIds.tabsSettings,
      SettingsItemIds.debugMenu,
      SettingsItemIds.sourceCode,
      SettingsItemIds.termsOfUse,
      SettingsItemIds.privacyPolicy,
      SettingsItemIds.licenses,
      SettingsItemIds.clearOnDeviceData,
    ];
    expect(ids.toSet().length, ids.length);
  });
}
