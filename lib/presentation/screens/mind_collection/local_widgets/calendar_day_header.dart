import 'package:intl/intl.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/glass_capsule_button.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_empty_state.dart';
import 'package:material_ui/material_ui.dart';

/// The date of a calendar day, centered; the day's frame is drawn around the whole day by the calendar.
/// Empty days show the day screen's empty state.
final class CalendarDayTitle extends StatelessWidget {
  final DateTime date;
  final bool isEmpty;

  const CalendarDayTitle({super.key, required this.date, required this.isEmpty});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String title = toBeginningOfSentenceCase(
      DateFormat.MMMMEEEEd(Localizations.localeOf(context).toString()).format(date),
    );
    return Padding(
      // The empty state's own padding keeps its text midway between the date and "Open day".
      padding: EdgeInsets.only(top: 12.0, bottom: isEmpty ? 0.0 : 12.0),
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isEmpty) const DayEmptyState(),
        ],
      ),
    );
  }
}

/// "Open day" under a calendar day, the way into its day screen.
final class CalendarOpenDayButton extends StatelessWidget {
  final VoidCallback onTap;

  const CalendarOpenDayButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Center(
        child: GlassCapsuleButton(
          onTap: onTap,
          child: Text(context.l10n.calendarOpenDay, style: Theme.of(context).textTheme.labelLarge),
        ),
      ),
    );
  }
}

/// "Week #N", centered, with ▶ for the stories of the whole week.
final class CalendarWeekHeader extends StatelessWidget {
  final int weekNumber;
  final VoidCallback? onPlay;

  const CalendarWeekHeader({super.key, required this.weekNumber, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 4.0,
        children: [
          Text(
            '${context.l10n.week} #$weekNumber',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (onPlay != null)
            IconButton(
              tooltip: context.l10n.calendarPlayStories,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.play_circle_fill_rounded),
              onPressed: onPlay,
            ),
        ],
      ),
    );
  }
}
