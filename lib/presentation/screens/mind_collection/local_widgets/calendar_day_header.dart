import 'package:intl/intl.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:material_ui/material_ui.dart';

/// The tappable date of a calendar day, centered: a rounded pill with a chevron and, when the day
/// has anything, a ▶ segment that plays its stories.
final class CalendarDayPill extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool isEmpty;
  final VoidCallback onTap;
  final VoidCallback? onPlay;

  const CalendarDayPill({
    super.key,
    required this.date,
    required this.isToday,
    required this.isEmpty,
    required this.onTap,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final Color background = isToday ? colors.primary : colors.onSurface.withValues(alpha: 0.06);
    final Color foreground = isToday ? colors.onPrimary : colors.onSurface;
    final String title = DateFormat.MMMEd(Localizations.localeOf(context).toString()).format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Center(
        child: Material(
          color: background,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: onTap,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 6.0, onPlay == null ? 10.0 : 6.0, 6.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 2.0,
                    children: [
                      Column(
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(color: foreground, fontWeight: FontWeight.w600),
                          ),
                          if (isEmpty)
                            Text(
                              context.l10n.calendarNoActivity,
                              style: theme.textTheme.labelSmall?.copyWith(color: foreground.withValues(alpha: 0.6)),
                            ),
                        ],
                      ),
                      Icon(Icons.chevron_right, size: 20.0, color: foreground.withValues(alpha: 0.7)),
                    ],
                  ),
                ),
              ),
              if (onPlay != null) ...[
                Container(width: 1.0, height: 20.0, color: foreground.withValues(alpha: 0.2)),
                InkWell(
                  onTap: onPlay,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 6.0, 12.0, 6.0),
                    child: Icon(Icons.play_arrow_rounded, size: 22.0, color: foreground),
                  ),
                ),
              ],
            ],
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
