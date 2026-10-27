import 'package:intl/intl.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 12.0),
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

/// "Open day" under a calendar day, the way into its day screen: a small glass capsule. It draws the glass
/// itself rather than blurring, since the plain card behind it has nothing to blur and the list is long.
final class CalendarOpenDayButton extends StatelessWidget {
  final VoidCallback onTap;

  const CalendarOpenDayButton({super.key, required this.onTap});

  static const double _height = 34.0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final BorderRadius radius = BorderRadius.circular(_height / 2);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(colors.surface, Colors.white, isDark ? 0.14 : 1.0)!.withValues(alpha: 0.9),
                Color.lerp(colors.surface, colors.onSurface, isDark ? 0.04 : 0.05)!.withValues(alpha: 0.9),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: isDark ? 0.18 : 0.9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 12.0,
                offset: const Offset(0.0, 3.0),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                height: _height,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Center(
                    widthFactor: 1.0,
                    child: Text(
                      context.l10n.calendarOpenDay,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
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
