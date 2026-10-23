import 'package:keklist/presentation/core/widgets/resizable_tile_grid.dart';
import 'package:material_ui/material_ui.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_layout.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_tile_menu.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_tiles.dart';

/// A day's feed as a plain box of square tiles, for lists such as the calendar.
final class DayFeedGrid extends StatelessWidget {
  final List<DayFeedItem> items;
  final int columnCount;
  final bool isMindTextVisible;
  final ValueChanged<int> onOpenItem;

  const DayFeedGrid({
    super.key,
    required this.items,
    required this.columnCount,
    required this.isMindTextVisible,
    required this.onOpenItem,
  });

  @override
  Widget build(BuildContext context) => ResizableTileGrid(
    columnCount: columnCount,
    spacing: DayFeedLayout.cellSpacing,
    cells: [
      for (final (int index, DayFeedItem item) in items.indexed)
        (
          key: ValueKey(item.id),
          span: 1,
          builder: (cellSize) => DayFeedTileMenu(
            item: item,
            child: GestureDetector(
              onTap: () => onOpenItem(index),
              child: DayFeedItemTile(item: item, isMindTextVisible: isMindTextVisible, size: cellSize),
            ),
          ),
        ),
    ],
  );
}
