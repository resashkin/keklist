import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/mind_story_details.dart';

void main() {
  final DateTime date = DateTime(2026, 10, 21, 7, 14);

  setUpAll(() => initializeDateFormatting('en'));

  test('one line joins day, weekday and time', () {
    expect(storyDateLines(date, locale: 'en', layout: StoryDateLayout.oneLine), ['October 21 · Wednesday · 07:14']);
  });

  test('two lines put the day first', () {
    expect(storyDateLines(date, locale: 'en', layout: StoryDateLayout.twoLines), ['October 21', 'Wednesday · 07:14']);
  });

  test('three lines split everything', () {
    expect(
      storyDateLines(date, locale: 'en', layout: StoryDateLayout.threeLines),
      ['October 21', 'Wednesday', '07:14'],
    );
  });
}
