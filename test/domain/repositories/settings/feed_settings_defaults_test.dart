import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/repositories/settings/object/settings_object.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';

void main() {
  test('the day feed is grouped by type by default, the calendar is not', () {
    expect(const DayFeedSettings().grouping, FeedGrouping.type);
    expect(const CalendarSettings().grouping, FeedGrouping.none);
    expect(KeklistSettings.initial().dayFeed.grouping, FeedGrouping.type);
  });

  test('a stored day grouping out of range falls back to type', () {
    final SettingsObject object = KeklistSettings.initial().toObject()..dayFeedGroupingIndex = 99;
    expect(object.toSettings().dayFeed.grouping, FeedGrouping.type);
  });
}
