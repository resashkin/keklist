import 'package:material_ui/material_ui.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_item.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_layout.dart';
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = DayFeedLayout.cellSpacing;
        final double cellSize = (constraints.maxWidth - spacing * (columnCount - 1)) / columnCount;
        final int rowCount = (items.length / columnCount).ceil();
        return Column(
          spacing: spacing,
          children: [
            for (int row = 0; row < rowCount; row++)
              Row(
                spacing: spacing,
                children: [
                  for (int index = row * columnCount; index < (row + 1) * columnCount && index < items.length; index++)
                    SizedBox.square(
                      dimension: cellSize,
                      child: GestureDetector(
                        onTap: () => onOpenItem(index),
                        child: DayFeedItemTile(item: items[index], isMindTextVisible: isMindTextVisible, size: cellSize),
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}
