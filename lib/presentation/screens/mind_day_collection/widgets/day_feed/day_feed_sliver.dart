import 'package:material_ui/material_ui.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/core/extensions/localization_extensions.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_cubit.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_layout.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_tiles.dart';

const double _kCellSpacing = 4.0;
const double _kHorizontalPadding = 8.0;

sealed class _DayFeedCell {
  const _DayFeedCell();
}

final class _ItemCell extends _DayFeedCell {
  final int itemIndex;
  const _ItemCell(this.itemIndex);
}

final class _SkeletonCell extends _DayFeedCell {
  const _SkeletonCell();
}

final class DayFeedSliver extends StatelessWidget {
  final DayFeedState state;
  final DayFeedSettings settings;
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
    final List<_DayFeedCell> cells = _buildCells();
    final List<List<int>> rows = DayFeedLayout.packIntoRows(
      spans: cells.map(_spanOf).toList(),
      columnCount: settings.columnCount,
    );
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
          SliverLayoutBuilder(
            builder: (context, constraints) {
              final double cellSize = _cellSize(constraints.crossAxisExtent);
              return SliverList.builder(
                itemCount: rows.length,
                itemBuilder: (context, rowIndex) => Padding(
                  padding: const EdgeInsets.only(bottom: _kCellSpacing),
                  child: Row(
                    spacing: _kCellSpacing,
                    children: rows[rowIndex]
                        .map((cellIndex) => _buildCell(cells[cellIndex], cellSize))
                        .toList(),
                  ),
                ),
              );
            },
          ),
          if (isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  context.l10n.noMindsForThisDay,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<_DayFeedCell> _buildCells() => [
        for (int index = 0; index < state.items.length; index++) _ItemCell(index),
        if (state.isMediaLoading)
          for (int index = 0; index < settings.columnCount * 2; index++) const _SkeletonCell(),
      ];

  int _spanOf(_DayFeedCell cell) => switch (cell) {
        _ItemCell(:final itemIndex) when state.items[itemIndex] is DayFeedMind => settings.mindCellSpan,
        _ => 1,
      };

  double _cellSize(double rowWidth) =>
      (rowWidth - _kCellSpacing * (settings.columnCount - 1)) / settings.columnCount;

  Widget _buildCell(_DayFeedCell cell, double cellSize) {
    final int span = _spanOf(cell);
    final double width = cellSize * span + _kCellSpacing * (span - 1);
    return SizedBox(width: width, height: cellSize, child: _buildCellContent(cell, cellSize, span));
  }

  Widget _buildCellContent(_DayFeedCell cell, double cellSize, int span) => switch (cell) {
        _SkeletonCell() => const DayFeedSkeletonTile(),
        _ItemCell(:final itemIndex) => GestureDetector(
            onTap: () => onOpenItem(itemIndex),
            child: _buildItemTile(state.items[itemIndex], cellSize, span),
          ),
      };

  Widget _buildItemTile(DayFeedItem item, double cellSize, int span) => switch (item) {
        DayFeedMind() => DayFeedMindTile(
            item: item,
            isTextVisible: settings.isMindTextVisible,
            size: cellSize,
          ),
        DayFeedAsset() => DayFeedAssetTile(item: item),
        DayFeedFolderMedia() => DayFeedFolderMediaTile(item: item),
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
