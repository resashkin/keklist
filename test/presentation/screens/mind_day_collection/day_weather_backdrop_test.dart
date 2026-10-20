import 'package:flutter_test/flutter_test.dart';
import 'package:keklist/domain/services/entities/weather_data.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_weather_backdrop.dart';
import 'package:material_ui/material_ui.dart';

WeatherData _weather({double precipitation = 0.0, double uvIndex = 0.0, String? locationName}) => WeatherData(
  dayIndex: 0,
  temperature: 14.6,
  uvIndex: uvIndex,
  humidity: 60.0,
  windSpeed: 3.0,
  precipitation: precipitation,
  fetchedAt: DateTime(2026, 10, 20),
  hourlyTemperatures: const [],
  hourlyUvIndex: const [],
  hourlyHumidity: const [],
  hourlyWindSpeed: const [],
  hourlyPrecipitation: const [],
  locationName: locationName,
);

Future<void> _pump(WidgetTester tester, WeatherData data) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(body: DayWeatherBackdrop(data: data)),
  ),
);

void main() {
  testWidgets('shows rounded temperature and place name', (tester) async {
    await _pump(tester, _weather(locationName: 'Almaty'));
    expect(find.text('15°'), findsOneWidget);
    expect(find.text('Almaty'), findsOneWidget);
  });

  testWidgets('picks the icon from precipitation, then UV index', (tester) async {
    await _pump(tester, _weather(precipitation: 2.0, uvIndex: 8.0));
    expect(find.byIcon(Icons.water_drop_outlined), findsOneWidget);

    await _pump(tester, _weather(uvIndex: 8.0));
    expect(find.byIcon(Icons.wb_sunny_outlined), findsOneWidget);

    await _pump(tester, _weather());
    expect(find.byIcon(Icons.cloud_outlined), findsOneWidget);
  });

  testWidgets('never takes touches from the grid above it', (tester) async {
    await _pump(tester, _weather());
    expect(find.descendant(of: find.byType(DayWeatherBackdrop), matching: find.byType(IgnorePointer)), findsOneWidget);
  });
}
