import 'package:keklist/domain/repositories/settings/settings_repository.dart';
import 'package:material_ui/material_ui.dart';

/// Title above a full-width 2–7 segmented picker; six segments do not fit beside a title.
final class ColumnCountRow extends StatelessWidget {
  final String title;
  final int selected;
  final ValueChanged<int> onChanged;

  const ColumnCountRow({super.key, required this.title, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8.0,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyLarge),
          SegmentedButton<int>(
            showSelectedIcon: false,
            segments: [
              for (final int count in DayFeedSettings.columnCountOptions)
                ButtonSegment<int>(value: count, label: Text('$count')),
            ],
            selected: {selected.clamp(DayFeedSettings.minColumnCount, DayFeedSettings.maxColumnCount)},
            onSelectionChanged: (selection) => onChanged(selection.first),
          ),
        ],
      ),
    );
  }
}
