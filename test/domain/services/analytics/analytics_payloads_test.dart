import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/domain/services/analytics/analytics_payloads.dart';

void main() {
  group('analyticsTweaksOf', () {
    test('holds only enum names, bools and numbers', () {
      final Map<String, Object> tweaks = analyticsTweaksOf(KeklistSettings.initial());
      for (final Object value in tweaks.values) {
        expect(value is String || value is bool || value is num, isTrue);
      }
    });

    test('never includes hidden media, coordinates or the media folder path', () {
      final KeklistSettings settings = KeklistSettings.initial().copyWith(
        hiddenMediaIds: {'asset_secret'},
        weatherLatitude: 55.75,
        weatherLongitude: 37.61,
        mediaFolderPath: '/private/folder',
      );
      final String all = analyticsTweaksOf(settings).values.join(' ');
      expect(all, isNot(contains('asset_secret')));
      expect(all, isNot(contains('55.75')));
      expect(all, isNot(contains('/private/folder')));
      expect(analyticsTweaksOf(settings)['media_folder_enabled'], isTrue);
    });
  });

  test('changedTweaks returns only the tweaks that differ', () {
    final KeklistSettings before = KeklistSettings.initial();
    final KeklistSettings after = before.copyWith(dayFeed: before.dayFeed.copyWith(grouping: FeedGrouping.timeOfDay));
    expect(changedTweaks(analyticsTweaksOf(before), analyticsTweaksOf(after)), {'day_grouping': 'timeOfDay'});
  });

  test('withoutExceptionMessages keeps the type and stack but drops the message', () {
    final Map<String, Object> properties = withoutExceptionMessages({
      r'$exception_list': [
        {
          'type': 'StateError',
          'value': 'Bad state: my secret note',
          'stacktrace': {'frames': <Object>[]},
        },
      ],
      r'$exception_message': 'my secret note',
      'other': 1,
    });
    final Map<dynamic, dynamic> exception = (properties[r'$exception_list']! as List).single as Map;
    expect(exception['type'], 'StateError');
    expect(exception.containsKey('stacktrace'), isTrue);
    expect(exception.containsKey('value'), isFalse);
    expect(properties.containsKey(r'$exception_message'), isFalse);
    expect(properties['other'], 1);
  });
}
