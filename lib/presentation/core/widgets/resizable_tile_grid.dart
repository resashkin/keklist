import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:keklist/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:keklist/presentation/screens/mind_day_collection/widgets/day_feed/day_feed_layout.dart';
import 'package:material_ui/material_ui.dart';

/// One square cell of a [ResizableTileGrid]; [span] cells wide.
typedef TileGridCell = ({Key key, int span, Widget Function(double cellSize) builder});

/// Square tiles packed into rows of [columnCount]. When the column count changes, the tiles fly to their new places
/// or the layouts crossfade, the way the tweak sheet picked ([GridResizeAnimation]); live zoom is the pinch's job.
final class ResizableTileGrid extends StatelessWidget {
  final List<TileGridCell> cells;
  final int columnCount;
  final double spacing;

  const ResizableTileGrid({super.key, required this.cells, required this.columnCount, required this.spacing});

  static const Duration _duration = Duration(milliseconds: 320);

  @override
  Widget build(BuildContext context) {
    final GridResizeAnimation animation = context.select<SettingsBloc, GridResizeAnimation>(
      (bloc) => switch (bloc.state) {
        SettingsDataState(:final settings) => settings.gridResizeAnimation,
        _ => GridResizeAnimation.fly,
      },
    );
    final bool reducesMotion = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cellSize = (constraints.maxWidth - spacing * (columnCount - 1)) / columnCount;
        final List<List<int>> rows = DayFeedLayout.packIntoRows(
          spans: cells.map((cell) => cell.span).toList(),
          columnCount: columnCount,
        );
        final double height = rows.isEmpty ? 0.0 : rows.length * cellSize + (rows.length - 1) * spacing;
        final bool flies = animation == GridResizeAnimation.fly && !reducesMotion;
        final bool fades = animation == GridResizeAnimation.crossfade && !reducesMotion;
        final Widget grid = SizedBox(
          // A new key per column count is what the crossfade switches on; the other modes keep the tiles alive.
          key: fades ? ValueKey(columnCount) : null,
          width: constraints.maxWidth,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final (int rowIndex, List<int> row) in rows.indexed)
                ..._row(row, rowIndex * (cellSize + spacing), cellSize, flies),
            ],
          ),
        );
        if (!fades) {
          return AnimatedSize(
            duration: flies ? _duration : Duration.zero,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: grid,
          );
        }
        return AnimatedSize(
          duration: _duration,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: _duration,
            layoutBuilder: (current, previous) =>
                Stack(alignment: Alignment.topCenter, children: [...previous, ?current]),
            child: grid,
          ),
        );
      },
    );
  }

  Iterable<Widget> _row(List<int> row, double top, double cellSize, bool flies) sync* {
    double left = 0.0;
    for (final int index in row) {
      final TileGridCell cell = cells[index];
      final int span = cell.span.clamp(1, columnCount);
      final double width = cellSize * span + spacing * (span - 1);
      final Widget child = cell.builder(cellSize);
      yield flies
          ? AnimatedPositioned(
              key: cell.key,
              duration: _duration,
              curve: Curves.easeOutCubic,
              left: left,
              top: top,
              width: width,
              height: cellSize,
              child: child,
            )
          : Positioned(key: cell.key, left: left, top: top, width: width, height: cellSize, child: child);
      left += width + spacing;
    }
  }
}
