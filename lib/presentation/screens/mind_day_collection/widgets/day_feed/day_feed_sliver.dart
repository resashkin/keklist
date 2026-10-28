import 'package:material_ui/material_ui.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/core/widgets/resizable_tile_grid.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_cubit.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_empty_state.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_layout.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_section_header.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_tile_menu.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_tiles.dart';

const double _kCellSpacing = DayFeedLayout.cellSpacing;
const double _kHorizontalPadding = DayFeedLayout.horizontalPadding;

sealed class _DayFeedCell {
  const _DayFeedCell();
}

final class _ItemCell extends _DayFeedCell {
  final DayFeedItem item;
  final int itemIndex;
  const _ItemCell(this.item, this.itemIndex);
}

final class _SkeletonCell extends _DayFeedCell {
  const _SkeletonCell();
}

final class DayFeedSliver extends StatelessWidget {
  final DayFeedState state;
  final DayFeedSettings settings;

  /// Gets the index in [DayFeedLayout.arrangedItems] of the state's items.
  final ValueChanged<int> onOpenItem;
  final ValueChanged<DayFeedMediaIssue> onResolveMediaIssue;

  const DayFeedSliver({
    super.key,
    required this.state,
    required this.settings,
    required this.onOpenItem,
    required this.onResolveMediaIssue,
  });

  @override
  Widget build(BuildContext context) {
    final List<(DayFeedSectionKind?, List<_DayFeedCell>)> sections = _buildSections();
    final DayFeedMediaIssue? mediaIssue = state.mediaIssue;
    final bool isEmpty = state.items.isEmpty && !state.isMediaLoading;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: _kHorizontalPadding, vertical: _kCellSpacing),
      sliver: SliverMainAxisGroup(
        slivers: [
          if (mediaIssue != null)
            SliverToBoxAdapter(
              child: _MediaIssueBanner(issue: mediaIssue, onResolve: () => onResolveMediaIssue(mediaIssue)),
            ),
          for (final (DayFeedSectionKind? kind, List<_DayFeedCell> cells) in sections)
            SliverToBoxAdapter(
              key: ValueKey(kind),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (kind != null) DayFeedSectionHeader(kind: kind),
                  ResizableTileGrid(
                    columnCount: settings.columnCount,
                    spacing: _kCellSpacing,
                    cells: [
                      for (final (int index, _DayFeedCell cell) in cells.indexed)
                        (
                          key: switch (cell) {
                            _ItemCell(:final item) => ValueKey(item.id),
                            _SkeletonCell() => ValueKey('skeleton-$index'),
                          },
                          span: _spanOf(cell),
                          builder: (cellSize) => _buildCellContent(cell, cellSize),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          if (isEmpty) const SliverToBoxAdapter(child: DayEmptyState()),
        ],
      ),
    );
  }

  List<(DayFeedSectionKind?, List<_DayFeedCell>)> _buildSections() {
    int itemIndex = 0;
    final List<(DayFeedSectionKind?, List<_DayFeedCell>)> sections = [
      for (final DayFeedSection section in DayFeedLayout.arrange(
        state.items,
        sortOrder: settings.sortOrder,
        grouping: settings.grouping,
      ))
        (section.kind, [for (final DayFeedItem item in section.items) _ItemCell(item, itemIndex++)]),
    ];
    if (!state.isMediaLoading) return sections;
    final List<_DayFeedCell> skeletons = [
      for (int index = 0; index < settings.columnCount * 2; index++) const _SkeletonCell(),
    ];
    if (sections.isEmpty || settings.grouping != FeedGrouping.none) return [...sections, (null, skeletons)];
    return [(sections.first.$1, [...sections.first.$2, ...skeletons])];
  }

  int _spanOf(_DayFeedCell cell) => switch (cell) {
        _ItemCell(:final item) when item is DayFeedMind => settings.mindCellSpan,
        _ => 1,
      };

  Widget _buildCellContent(_DayFeedCell cell, double cellSize) => switch (cell) {
        _SkeletonCell() => const DayFeedSkeletonTile(),
        _ItemCell(:final item, :final itemIndex) => DayFeedTileMenu(
            item: item,
            child: GestureDetector(
              onTap: () => onOpenItem(itemIndex),
              child: DayFeedItemTile(item: item, isMindTextVisible: settings.isMindTextVisible, size: cellSize),
            ),
          ),
      };
}

final class _MediaIssueBanner extends StatelessWidget {
  final DayFeedMediaIssue issue;
  final VoidCallback onResolve;

  const _MediaIssueBanner({required this.issue, required this.onResolve});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final (String hint, String action, IconData icon) = switch (issue) {
      DayFeedMediaIssue.photoAccessDenied => (
          context.l10n.dayFeedPhotoAccessHint,
          context.l10n.dayFeedAllowAccess,
          Icons.photo_library_outlined,
        ),
      DayFeedMediaIssue.folderNotChosen => (
          context.l10n.dayFeedFolderHint,
          context.l10n.dayFeedChooseFolder,
          Icons.folder_open,
        ),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12.0, 4.0, 4.0, 4.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8.0),
            Expanded(child: Text(hint, style: theme.textTheme.bodySmall)),
            TextButton(onPressed: onResolve, child: Text(action)),
          ],
        ),
      ),
    );
  }
}
