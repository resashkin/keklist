part of '../../mind_collection_screen.dart';

final class _MindCollectionBody extends StatelessWidget {
  final bool isSearching;
  final List<Mind> searchResults;
  final VoidCallback hideKeyboard;
  final ValueChanged<int> onTapToDay;
  final void Function(int dayIndex, int itemIndex) onOpenItem;
  final ValueChanged<List<int>> onPlay;
  final CalendarDayFeed feed;
  final CalendarSettings settings;
  final ValueChanged<int> onColumnCountChanged;
  final bool showsWeekTitles;
  final int todayIndex;
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;

  const _MindCollectionBody({
    required this.isSearching,
    required this.searchResults,
    required this.hideKeyboard,
    required this.onTapToDay,
    required this.onOpenItem,
    required this.onPlay,
    required this.feed,
    required this.settings,
    required this.onColumnCountChanged,
    required this.showsWeekTitles,
    required this.todayIndex,
    required this.itemScrollController,
    required this.itemPositionsListener,
  });

  static const int _allDaysCount = 99999999999;

  @override
  Widget build(BuildContext context) {
    if (isSearching) {
      return MindSearchResultListWidget(
        results: searchResults,
        onTapToMind: (mind) => () {
          hideKeyboard();
          onTapToDay(mind.dayIndex);
        },
      );
    }
    return PinchColumnsDetector(
      columnCount: settings.columnCount,
      onChanged: onColumnCountChanged,
      child: GestureDetector(
        onPanDown: (_) => hideKeyboard(),
        child: ScrollablePositionedList.builder(
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + 8.0,
            bottom: MediaQuery.paddingOf(context).bottom + 96.0,
          ),
          itemCount: _allDaysCount,
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          itemBuilder: (context, dayIndex) => _buildDay(context, dayIndex),
        ),
      ),
    );
  }

  static const int _daysInWeek = 7;

  Widget _buildDay(BuildContext context, int dayIndex) {
    final DateTime date = DateUtils.getDateFromDayIndex(dayIndex);
    final int weekNumber = _getWeekNumber(date);
    final bool startsWeek = weekNumber != _getWeekNumber(DateUtils.getDateFromDayIndex(dayIndex - 1));
    final List<DayFeedItem> items = feed.itemsOf(dayIndex);
    final List<int> weekDays = [for (int offset = 0; offset < _daysInWeek; offset++) dayIndex + offset];
    final bool hasWeekItems = weekDays.any((day) => feed.itemsOf(day).isNotEmpty);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DayFeedLayout.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showsWeekTitles && startsWeek)
            CalendarWeekHeader(weekNumber: weekNumber, onPlay: hasWeekItems ? () => onPlay(weekDays) : null),
          CalendarDayPill(
            date: date,
            isToday: dayIndex == todayIndex,
            isEmpty: items.isEmpty,
            onTap: () => onTapToDay(dayIndex),
            onPlay: items.isEmpty ? null : () => onPlay([dayIndex]),
          ),
          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2.0, bottom: 8.0),
              child: DayFeedGrid(
                items: items,
                columnCount: settings.columnCount,
                isMindTextVisible: settings.isMindTextVisible,
                onOpenItem: (itemIndex) => onOpenItem(dayIndex, itemIndex),
              ),
            ),
        ],
      ),
    );
  }

  // FIXME: to not show week number in start of each year.
  int _getWeekNumber(DateTime date) {
    final DateTime firstDayOfYear = DateTime(date.year, 1, 1);
    final int dayOfYear = date.difference(firstDayOfYear).inDays;
    final int weekdayOfFirstDay = firstDayOfYear.weekday;
    return ((dayOfYear + weekdayOfFirstDay) / 7).ceil();
  }
}
