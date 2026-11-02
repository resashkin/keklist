import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/tile_motion_tweaks.dart';
import 'package:material_ui/material_ui.dart';

/// Order and grouping of a day's tiles, for the day and calendar sheets which keep their own values.
final class FeedArrangementTweaks extends StatelessWidget {
  final FeedSortOrder sortOrder;
  final FeedGrouping grouping;
  final void Function({FeedSortOrder? sortOrder, FeedGrouping? grouping}) onChanged;

  const FeedArrangementTweaks({super.key, required this.sortOrder, required this.grouping, required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TweakChoice<FeedSortOrder>(
        title: context.l10n.feedSortOrder,
        options: {
          FeedSortOrder.time: context.l10n.feedSortTime,
          FeedSortOrder.mindsFirst: context.l10n.feedSortMindsFirst,
          FeedSortOrder.mediaFirst: context.l10n.feedSortMediaFirst,
        },
        selected: sortOrder,
        onChanged: (value) => onChanged(sortOrder: value),
      ),
      TweakChoice<FeedGrouping>(
        title: context.l10n.feedGrouping,
        options: {
          FeedGrouping.none: context.l10n.feedGroupingNone,
          FeedGrouping.type: context.l10n.feedGroupingType,
          FeedGrouping.timeOfDay: context.l10n.feedGroupingTimeOfDay,
        },
        selected: grouping,
        onChanged: (value) => onChanged(grouping: value),
      ),
    ],
  );
}
