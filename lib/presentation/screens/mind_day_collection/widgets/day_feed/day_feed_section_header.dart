import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_layout.dart';
import 'package:material_ui/material_ui.dart';

/// The small caption over a group of tiles: "Notes", "Gallery", "Morning"…
final class DayFeedSectionHeader extends StatelessWidget {
  final DayFeedSectionKind kind;

  const DayFeedSectionHeader({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final (IconData icon, String title) = switch (kind) {
      DayFeedSectionKind.minds => (Icons.edit_note_rounded, context.l10n.feedSectionMinds),
      DayFeedSectionKind.gallery => (Icons.photo_library_outlined, context.l10n.feedSectionGallery),
      DayFeedSectionKind.night => (Icons.nightlight_outlined, context.l10n.insightsNight),
      DayFeedSectionKind.morning => (Icons.wb_twilight_rounded, context.l10n.insightsMorning),
      DayFeedSectionKind.afternoon => (Icons.wb_sunny_outlined, context.l10n.insightsAfternoon),
      DayFeedSectionKind.evening => (Icons.nights_stay_outlined, context.l10n.insightsEvening),
    };
    final Color color = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4.0, 10.0, 4.0, 6.0),
      child: Row(
        spacing: 6.0,
        children: [
          Icon(icon, size: 15.0, color: color),
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
