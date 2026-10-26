import 'package:keklist/presentation/core/widgets/resizable_tile_grid.dart';
import 'package:material_ui/material_ui.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_layout.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_section_header.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_tile_menu.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_tiles.dart';

/// A day's feed as a plain box of square tiles, for lists such as the calendar; a section header goes over each
/// group of tiles when there are headers.
final class DayFeedGrid extends StatelessWidget {
  final List<DayFeedSection> sections;
  final int columnCount;
  final bool isMindTextVisible;

  /// Gets the index of the item across all [sections].
  final ValueChanged<int> onOpenItem;

  const DayFeedGrid({
    super.key,
    required this.sections,
    required this.columnCount,
    required this.isMindTextVisible,
    required this.onOpenItem,
  });

  @override
  Widget build(BuildContext context) {
    final List<int> offsets = [0];
    for (final DayFeedSection section in sections) {
      offsets.add(offsets.last + section.items.length);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (int index, DayFeedSection section) in sections.indexed) ...[
          if (section.kind case final DayFeedSectionKind kind) DayFeedSectionHeader(kind: kind),
          _grid(section.items, offsets[index]),
        ],
      ],
    );
  }

  Widget _grid(List<DayFeedItem> items, int offset) => ResizableTileGrid(
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
              onTap: () => onOpenItem(offset + index),
              child: DayFeedItemTile(item: item, isMindTextVisible: isMindTextVisible, size: cellSize),
            ),
          ),
        ),
    ],
  );
}
