import 'package:material_ui/material_ui.dart';
import 'package:keklist/domain/services/entities/weather_data.dart';

const double _kRainyPrecipitationMm = 1.0;
const double _kSunnyUvIndex = 3.0;

final class DayWeatherBackdrop extends StatelessWidget {
  final WeatherData data;

  const DayWeatherBackdrop({super.key, required this.data});

  IconData get _icon {
    if (data.precipitation >= _kRainyPrecipitationMm) return Icons.water_drop_outlined;
    if (data.uvIndex >= _kSunnyUvIndex) return Icons.wb_sunny_outlined;
    return Icons.cloud_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.09);
    final String? locationName = data.locationName;
    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(_icon, size: 56.0, color: color),
          Text(
            '${data.temperature.round()}°',
            style: TextStyle(fontSize: 120.0, height: 1.0, fontWeight: FontWeight.w200, color: color),
          ),
          if (locationName != null)
            Text(
              locationName,
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: color),
            ),
        ],
      ),
    );
  }
}
