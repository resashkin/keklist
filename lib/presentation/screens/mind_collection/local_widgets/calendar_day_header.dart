import 'package:intl/intl.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_empty_state.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:material_ui/material_ui.dart';

/// The tappable date of a calendar day, centered: a rounded pill with the full date, counters of what the day
/// holds and a chevron, plus a separate round ▶ that plays its stories. Empty days show the day screen's empty state.
final class CalendarDayPill extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final List<DayFeedItem> items;
  final VoidCallback onTap;
  final VoidCallback? onPlay;

  const CalendarDayPill({
    super.key,
    required this.date,
    required this.isToday,
    required this.items,
    required this.onTap,
    required this.onPlay,
  });

  static const double _kMinPillWidth = 200.0;
  static const double _kPillHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final Color background = isToday ? colors.primary : colors.onSurface.withValues(alpha: 0.06);
    final Color foreground = isToday ? colors.onPrimary : colors.onSurface;
    final String title = toBeginningOfSentenceCase(
      DateFormat.MMMMEEEEd(Localizations.localeOf(context).toString()).format(date),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8.0,
            children: [
              Material(
                color: background,
                shape: const StadiumBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onTap,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: _kMinPillWidth, minHeight: _kPillHeight),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 6.0, 12.0, 6.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 4.0,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 2.0,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: foreground,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (items.isNotEmpty)
                                _DayCounters(items: items, color: foreground.withValues(alpha: 0.65)),
                            ],
                          ),
                          Icon(Icons.chevron_right, size: 20.0, color: foreground.withValues(alpha: 0.7)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (onPlay != null)
                Material(
                  color: background,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onPlay,
                    child: SizedBox.square(
                      dimension: _kPillHeight,
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 24.0,
                        color: foreground,
                        semanticLabel: context.l10n.calendarPlayStories,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (items.isEmpty) const DayEmptyState(),
        ],
      ),
    );
  }
}

/// "✎ 6 · 📷 3 · ▶ 1": minds, photos and videos of the day; zero counts are hidden.
final class _DayCounters extends StatelessWidget {
  final List<DayFeedItem> items;
  final Color color;

  const _DayCounters({required this.items, required this.color});

  @override
  Widget build(BuildContext context) {
    final int minds = items.whereType<DayFeedMind>().length;
    final int videos = items
        .where(
          (item) => switch (item) {
            DayFeedAsset() => item.isVideo,
            DayFeedFolderMedia() => item.isVideo,
            DayFeedMind() => false,
          },
        )
        .length;
    final int photos = items.length - minds - videos;
    final TextStyle? style = Theme.of(context).textTheme.labelMedium?.copyWith(color: color);
    final List<(IconData, int)> counters = [
      (Icons.edit_note_rounded, minds),
      (Icons.photo_outlined, photos),
      (Icons.videocam_outlined, videos),
    ].where((counter) => counter.$2 > 0).toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 10.0,
      children: [
        for (final (IconData icon, int count) in counters)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 3.0,
            children: [
              Icon(icon, size: 14.0, color: color),
              Text('$count', style: style),
            ],
          ),
      ],
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
