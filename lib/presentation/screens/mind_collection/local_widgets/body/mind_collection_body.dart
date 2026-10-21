part of '../../mind_collection_screen.dart';

final class _MindCollectionBody extends StatelessWidget {
  final bool isSearching;
  final List<Mind> searchResults;
  final VoidCallback hideKeyboard;
  final ValueChanged<int> onTapToDay;
  final void Function(int dayIndex, int itemIndex) onOpenItem;
  final CalendarDayFeed feed;
  final CalendarSettings settings;
  final bool showsWeekTitles;

  /// Shown days in order, or null for every day (list position == day index).
  final List<int>? dayIndexes;
  final int todayIndex;
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;

  const _MindCollectionBody({
    required this.isSearching,
    required this.searchResults,
    required this.hideKeyboard,
    required this.onTapToDay,
    required this.onOpenItem,
    required this.feed,
    required this.settings,
    required this.showsWeekTitles,
    required this.dayIndexes,
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
    final List<int>? days = dayIndexes;
    return GestureDetector(
      onPanDown: (_) => hideKeyboard(),
      child: ScrollablePositionedList.builder(
        padding: EdgeInsets.only(top: 8.0, bottom: MediaQuery.paddingOf(context).bottom + 96.0),
        itemCount: days?.length ?? _allDaysCount,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        itemBuilder: (context, position) {
          final int dayIndex = days?[position] ?? position;
          final int previousDayIndex = days == null ? dayIndex - 1 : (position > 0 ? days[position - 1] : dayIndex - 1);
          return _buildDay(context, dayIndex, previousDayIndex);
        },
      ),
    );
  }

  Widget _buildDay(BuildContext context, int dayIndex, int previousDayIndex) {
    final ThemeData theme = Theme.of(context);
    final DateTime date = DateUtils.getDateFromDayIndex(dayIndex);
    final int weekNumber = _getWeekNumber(date);
    final bool startsWeek = weekNumber != _getWeekNumber(DateUtils.getDateFromDayIndex(previousDayIndex));
    final bool isToday = dayIndex == todayIndex;
    final List<DayFeedItem> items = feed.itemsOf(dayIndex);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DayFeedLayout.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showsWeekTitles && startsWeek)
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
              child: Text(
                '${context.l10n.week} #$weekNumber',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTapToDay(dayIndex),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                DateFormatters.formatFullDate(date, Localizations.localeOf(context)),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? theme.colorScheme.primary : null,
                ),
              ),
            ),
          ),
          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
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
