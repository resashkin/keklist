import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:material_ui/material_ui.dart';

/// "No minds for this day", shared by the day screen and the calendar.
final class DayEmptyState extends StatelessWidget {
  const DayEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Text(
        context.l10n.noMindsForThisDay,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
      ),
    );
  }
}
