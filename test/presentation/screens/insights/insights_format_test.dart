import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/presentation/core/helpers/date_utils.dart';
import 'package:keklist/presentation/screens/insights/widgets/insights_format.dart';

int _day(int year, int month, int day) => DateUtils.getDayIndex(from: DateTime.utc(year, month, day));

void main() {
  test('Monday weeks follow ISO 8601', () {
    expect(InsightsFormat.weekOfYear(_day(2026, 10, 20), DateTime.monday), 43);
    expect(InsightsFormat.weekOfYear(_day(2026, 1, 1), DateTime.monday), 1);
    expect(InsightsFormat.weekOfYear(_day(2021, 1, 3), DateTime.monday), 53);
  });

  test('Sunday weeks count from the week with January 1', () {
    expect(InsightsFormat.weekOfYear(_day(2026, 1, 1), DateTime.sunday), 1);
    expect(InsightsFormat.weekOfYear(_day(2026, 1, 4), DateTime.sunday), 2);
    expect(InsightsFormat.weekOfYear(_day(2025, 12, 31), DateTime.sunday), 1);
  });
}
